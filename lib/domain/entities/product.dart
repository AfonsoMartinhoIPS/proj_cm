import 'package:projeto/domain/entities/nutriments.dart';

class Product {
  final String barcode;
  final String name;
  final String? brand;
  final String? displayQuantity;
  final String? imageUrl;
  final String? imageThumbnailUrl;
  final String? ingredientsText;
  final List<String> allergenTags;
  final List<String> tracesTags;
  final List<String> labelTags;
  final String? nutriscoreGrade;
  final int? novaGroup;
  final Nutriments nutriments;
  final String source; // "openfoodfacts" | "usda" | "manual"
  final DateTime? fetchedAt;

  const Product({
    required this.barcode,
    required this.name,
    this.brand,
    this.displayQuantity,
    this.imageUrl,
    this.imageThumbnailUrl,
    this.ingredientsText,
    this.allergenTags = const [],
    this.tracesTags = const [],
    this.labelTags = const [],
    this.nutriscoreGrade,
    this.novaGroup,
    required this.nutriments,
    required this.source,
    required this.fetchedAt,
  });
}
