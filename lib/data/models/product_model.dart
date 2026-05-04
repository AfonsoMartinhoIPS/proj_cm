import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projeto/data/models/nutriments_model.dart';
import 'package:projeto/domain/entities/product.dart';

class ProductModel {
  static Product? fromDoc(DocumentSnapshot doc) {
    if (!doc.exists) return null;
    final map = doc.data() as Map<String, dynamic>;
    return Product(
      barcode: doc.id,
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
      nutriments: NutrimentsModel.fromMap(map['nutriments'] as Map<String, dynamic>? ?? {}),
      source: map['source'] as String? ?? 'openfoodfacts',
      fetchedAt: (map['fetchedAt'] as Timestamp?)?.toDate(),
    );
  }

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
