// lib/domain/entities/nutriments.dart

/// Composição nutricional por 100 g ou 100 ml de um produto.
///
/// Fornece os valores típicos por 100 unidades e métodos auxiliares para
/// escalar esses valores para uma porção específica (em gramas).
class Nutriments {
  /// Calorias (kcal) por 100 g/ml.
  final double? caloriesPer100g;

  /// Hidratos de carbono (g) por 100 g/ml.
  final double? carbsPer100g;

  /// Açúcares (g) por 100 g/ml.
  final double? sugarsPer100g;

  /// Lípidos totais (g) por 100 g/ml.
  final double? fatPer100g;

  /// Ácidos gordos saturados (g) por 100 g/ml.
  final double? saturatedFatPer100g;

  /// Proteínas (g) por 100 g/ml.
  final double? proteinPer100g;

  /// Sal (g) por 100 g/ml.
  final double? saltPer100g;

  /// Fibra alimentar (g) por 100 g/ml.
  final double? fiberPer100g;

  /// Cria uma [Nutriments] com os valores indicados.
  ///
  /// Todos os campos são opcionais e podem ser `null` se a informação não
  /// estiver disponível.
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

  /// Calcula as calorias para uma porção de [grams] gramas.
  ///
  /// Multiplica o valor por 100 g/ml pela fração correspondente à porção.
  double calories({required double grams}) =>
      (caloriesPer100g ?? 0) / 100 * grams;

  /// Calcula os hidratos de carbono para uma porção de [grams] gramas.
  double carbs({required double grams}) =>
      (carbsPer100g ?? 0) / 100 * grams;

  /// Calcula os lípidos para uma porção de [grams] gramas.
  double fat({required double grams}) => (fatPer100g ?? 0) / 100 * grams;

  /// Calcula as proteínas para uma porção de [grams] gramas.
  double protein({required double grams}) =>
      (proteinPer100g ?? 0) / 100 * grams;

  /// Calcula os açúcares para uma porção de [grams] gramas.
  double sugars({required double grams}) =>
      (sugarsPer100g ?? 0) / 100 * grams;

  /// Calcula o sal para uma porção de [grams] gramas.
  double salt({required double grams}) => (saltPer100g ?? 0) / 100 * grams;
}