import 'package:nutri_scan/domain/entities/nutriments.dart';

enum MealType { breakfast, lunch, dinner, snack }

class MealEntry {
  final String id;
  final String productBarcode;
  final String productName;
  final String? productImageUrl;
  final MealType mealType;
  final double servingGrams;
  final Nutriments nutriments; // pre-computed for this serving
  final DateTime loggedAt;

  const MealEntry({
    required this.id,
    required this.productBarcode,
    required this.productName,
    this.productImageUrl,
    required this.mealType,
    required this.servingGrams,
    required this.nutriments,
    required this.loggedAt,
  });
}
