import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutri_scan/domain/entities/product.dart';
import 'package:nutri_scan/domain/entities/saved_product.dart';

/// Modelo de dados para conversão entre documentos do Firestore e a entidade [SavedProduct].
///
/// Responsável por:
/// - Converter um [DocumentSnapshot] do Firestore num [SavedProduct] (`fromDoc`).
/// - Converter um [SavedProduct] num mapa pronto para ser escrito no Firestore (`toMap`).
/// - Criar uma snapshot de [SavedProduct] a partir de um [Product] completo (`fromProduct`).
/// - Analisar o campo `notes` de forma defensiva, suportando formatos legados (string única)
///   e o formato atual (lista de mapas).
class SavedProductModel {
  /// Converte um [DocumentSnapshot] do Firestore num [SavedProduct].
  ///
  /// Devolve `null` se o documento não existir.
  /// Os campos ausentes ou com tipos inesperados são tratados com valores padrão.
  static SavedProduct? fromDoc(DocumentSnapshot doc) {
    if (!doc.exists) return null;
    final map = doc.data() as Map<String, dynamic>;
    return SavedProduct(
      barcode: doc.id,
      savedAt: (map['savedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      name: map['name'] as String? ?? '',
      brand: map['brand'] as String?,
      imageUrl: map['imageUrl'] as String?,
      caloriesPer100g: (map['caloriesPer100g'] as num?)?.toDouble(),
      notes: _parseNotes(map['notes']),
    );
  }

  /// Converte um [SavedProduct] num mapa adequado para escrita no Firestore.
  ///
  /// O campo `savedAt` é sempre preenchido com [FieldValue.serverTimestamp].
  /// As notas são serializadas como uma lista de mapas com `text` e `createdAt`.
  static Map<String, dynamic> toMap(SavedProduct saved) {
    return {
      'savedAt': FieldValue.serverTimestamp(),
      'name': saved.name,
      'brand': saved.brand,
      'imageUrl': saved.imageUrl,
      'caloriesPer100g': saved.caloriesPer100g,
      'notes': saved.notes
          .map((note) => {
                'text': note.text,
                'createdAt': Timestamp.fromDate(note.createdAt),
              })
          .toList(),
    };
  }

  /// Analisa o campo `notes` de forma defensiva, suportando três formatos:
  ///
  /// - `null` ou ausente → lista vazia.
  /// - Formato legado: uma única `String` → uma nota com esse texto e data atual.
  /// - Formato atual: `List<Map>` com as chaves `text` e `createdAt`.
  ///
  /// Qualquer elemento da lista que não seja um `Map` é ignorado para evitar
  /// que um documento corrompido quebre o ecrã.
  static List<SavedProductNote> _parseNotes(dynamic raw) {
    if (raw == null) return const [];
    if (raw is String) {
      if (raw.isEmpty) return const [];
      return [SavedProductNote(text: raw, createdAt: DateTime.now())];
    }
    if (raw is List) {
      return raw.whereType<Map>().map((entry) {
        final map = Map<String, dynamic>.from(entry);
        return SavedProductNote(
          text: map['text'] as String? ?? '',
          createdAt:
              (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    }
    return const [];
  }

  /// Cria uma snapshot de [SavedProduct] a partir de um [Product] completo.
  ///
  /// Utilizado quando o utilizador guarda um produto pela primeira vez,
  /// extraindo apenas os campos necessários para a lista de favoritos.
  static SavedProduct fromProduct(Product product) {
    return SavedProduct(
      barcode: product.barcode,
      savedAt: DateTime.now(),
      name: product.name,
      brand: product.brand,
      imageUrl: product.imageThumbnailUrl ?? product.imageUrl,
      caloriesPer100g: product.nutriments.caloriesPer100g,
    );
  }
}