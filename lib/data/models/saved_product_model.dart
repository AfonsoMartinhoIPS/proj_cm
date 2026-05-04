import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projeto/data/models/product_model.dart';
import 'package:projeto/domain/entities/saved_product.dart';

class SavedProductModel {
  static SavedProduct? fromDoc(DocumentSnapshot doc) {
    if (!doc.exists) return null;
    final map = doc.data() as Map<String, dynamic>;
    final product = ProductModel.fromMap(doc.id, map);
    if (product == null) return null;
    return SavedProduct(
      product: product,
      savedAt: (map['savedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notes: map['notes'] as String?,
    );
  }

  static Map<String, dynamic> toMap(SavedProduct savedProduct) {
    return {
      ...ProductModel.toMap(savedProduct.product),
      'savedAt': FieldValue.serverTimestamp(),
      'notes': savedProduct.notes,
    };
  }

  static Map<String, dynamic> notesUpdate(String? notes) {
    return {'notes': notes};
  }
}
