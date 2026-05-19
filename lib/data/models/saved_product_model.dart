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
      notes: ((map['notes'] as List?) ?? []).map((raw) {
        final note = raw as Map<String, dynamic>;
        return SavedProductNote(
          text: note['text'] as String? ?? '',
          createdAt: (note['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList(),
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
