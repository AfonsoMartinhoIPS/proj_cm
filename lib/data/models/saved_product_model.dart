import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projeto/domain/entities/product.dart';
import 'package:projeto/domain/entities/saved_product.dart';

class SavedProductModel {
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

  /// Defensive parse — handles three shapes:
  ///   - null / missing → []
  ///   - legacy: a single String           → one Note with that text
  ///   - current: List<Map> of {text, createdAt}
  /// Any list element that is not a Map is skipped so a corrupt doc
  /// can't crash the screen.
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
          createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    }
    return const [];
  }

  /// Build a SavedProduct snapshot from a full Product.
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
