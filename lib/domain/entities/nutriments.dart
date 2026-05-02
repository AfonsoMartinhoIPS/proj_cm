class Nutriments {
  final double? caloriesPer100g;
  final double? carbsPer100g;
  final double? sugarsPer100g;
  final double? fatPer100g;
  final double? saturatedFatPer100g;
  final double? proteinPer100g;
  final double? saltPer100g;
  final double? fiberPer100g;

  const Nutriments({
    this.caloriesPer100g,
    this.carbsPer100g,
    this.sugarsPer100g,
    this.fatPer100g,
    this.saturatedFatPer100g,
    this.proteinPer100g,
    this.saltPer100g,
    this.fiberPer100g,
  });

  double calories({required double grams}) => (caloriesPer100g ?? 0) / 100 * grams;
  double carbs({required double grams}) => (carbsPer100g ?? 0) / 100 * grams;
  double fat({required double grams}) => (fatPer100g ?? 0) / 100 * grams;
  double protein({required double grams}) => (proteinPer100g ?? 0) / 100 * grams;
  double sugars({required double grams}) => (sugarsPer100g ?? 0) / 100 * grams;
  double salt({required double grams}) => (saltPer100g ?? 0) / 100 * grams;
}
