import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutri_scan/data/models/nutriments_model.dart';
import 'package:nutri_scan/domain/entities/product.dart';

/// Modelo de dados para conversão entre documentos do Firestore e a entidade [Product].
///
/// Responsável por:
/// - Converter um mapa genérico ou um [DocumentSnapshot] do Firestore num [Product] (`fromMap`, `fromDoc`).
/// - Converter um [Product] de volta para um mapa adequado para escrita no Firestore (`toMap`).
/// - Tratar campos ausentes ou com tipos inesperados, aplicando valores padrão seguros.
class ProductModel {
  /// Converte um [Map<String, dynamic>] e um [barcode] explícito num [Product].
  ///
  /// Devolve `null` se o campo obrigatório `name` não estiver presente.
  /// Campos em falta são preenchidos com valores padrão (listas vazias, `source` = 'openfoodfacts', etc.).
  static Product? fromMap(String barcode, Map<String, dynamic> map) {
    if (map['name'] == null) return null;
    return Product(
      barcode: barcode,
      name: map['name'] as String,
      brand: map['brand'] as String?,
      displayQuantity: map['displayQuantity'] as String?,
      imageUrl: map['imageUrl'] as String?,
      imageThumbnailUrl: map['imageThumbnailUrl'] as String?,
      ingredientsText: map['ingredientsText'] as String?,
      allergenTags: List<String>.from(map['allergenTags'] ?? []),
      tracesTags: List<String>.from(map['tracesTags'] ?? []),
      labelTags: List<String>.from(map['labelTags'] ?? []),
      nutriscoreGrade: map['nutriscoreGrade'] as String?,
      novaGroup: map['novaGroup'] as int?,
      nutriments: NutrimentsModel.fromMap(
          map['nutriments'] as Map<String, dynamic>? ?? {}),
      source: map['source'] as String? ?? 'openfoodfacts',
      fetchedAt: (map['fetchedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Converte um [DocumentSnapshot] do Firestore num [Product].
  ///
  /// O identificador do documento é utilizado como [barcode].
  /// Devolve `null` se o documento não existir.
  static Product? fromDoc(DocumentSnapshot doc) {
    if (!doc.exists) return null;
    final map = doc.data() as Map<String, dynamic>;
    return fromMap(doc.id, map);
  }

  /// Converte um [Product] num mapa pronto para ser escrito no Firestore.
  ///
  /// O campo `fetchedAt` é sempre preenchido com [FieldValue.serverTimestamp].
  /// Os nutriments são serializados através de [NutrimentsModel.toMap].
  static Map<String, dynamic> toMap(Product product) {
    return {
      'name': product.name,
      'brand': product.brand,
      'displayQuantity': product.displayQuantity,
      'imageUrl': product.imageUrl,
      'imageThumbnailUrl': product.imageThumbnailUrl,
      'ingredientsText': product.ingredientsText,
      'allergenTags': product.allergenTags,
      'tracesTags': product.tracesTags,
      'labelTags': product.labelTags,
      'nutriscoreGrade': product.nutriscoreGrade,
      'novaGroup': product.novaGroup,
      'nutriments': NutrimentsModel.toMap(product.nutriments),
      'source': product.source,
      'fetchedAt': FieldValue.serverTimestamp(),
    };
  }
}