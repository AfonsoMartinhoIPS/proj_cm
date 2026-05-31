/// Tipos de refeição suportados pela aplicação.
///
/// Cada valor tem um rótulo em português associado, utilizado na interface.
enum MealType {
  /// Pequeno-almoço.
  breakfast(label: 'Pequeno-almoço'),

  /// Almoço.
  lunch(label: 'Almoço'),

  /// Jantar.
  dinner(label: 'Jantar'),

  /// Snack / lanche.
  snack(label: 'Snack');

  /// Rótulo em português do tipo de refeição.
  final String label;

  /// Cria um [MealType] com o [label] especificado.
  const MealType({required this.label});
}

/// Uma entrada individual de refeição registada num [NutritionLog] diário.
///
/// Os totais nutricionais (calorias, proteínas, hidratos, gordura) são
/// armazenados **já escalados para a porção consumida** — ou seja,
/// [calories] representa as kcal totais para [servingGrams] gramas do
/// produto, e não o valor por 100 g. Isto permite que a leitura do documento
/// nunca exija cálculos por parte de quem o consulta.
///
/// O escalonamento é feito uma única vez no momento do registo (em
/// `AddMealScreen._submit`) a partir dos [Nutriments] por 100 g do produto.
/// Os valores armazenados são congelados — não serão alterados se o produto
/// global for atualizado posteriormente.
class MealEntry {
  /// Identificador único da entrada (geralmente um timestamp em milissegundos).
  final String id;

  /// Código de barras do produto consumido.
  final String productBarcode;

  /// Nome do produto (snapshot no momento do registo).
  final String productName;

  /// URL da imagem do produto (snapshot), se disponível.
  final String? productImageUrl;

  /// Tipo de refeição a que esta entrada pertence.
  final MealType mealType;

  /// Quantidade consumida do produto, em gramas.
  final double servingGrams;

  /// Total de calorias para a porção consumida (kcal).
  final double calories;

  /// Total de proteínas para a porção consumida (g).
  final double protein;

  /// Total de hidratos de carbono para a porção consumida (g).
  final double carbs;

  /// Total de lípidos para a porção consumida (g).
  final double fat;

  /// Data e hora em que a entrada foi registada.
  final DateTime loggedAt;

  /// Cria uma [MealEntry].
  ///
  /// Os parâmetros [id], [productBarcode], [productName], [mealType],
  /// [servingGrams], [calories], [protein], [carbs], [fat] e [loggedAt]
  /// são obrigatórios.
  const MealEntry({
    required this.id,
    required this.productBarcode,
    required this.productName,
    this.productImageUrl,
    required this.mealType,
    required this.servingGrams,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.loggedAt,
  });

  /// Alias de conveniência para [calories].
  double get totalCalories => calories;

  /// Alias de conveniência para [protein].
  double get totalProtein => protein;

  /// Alias de conveniência para [carbs].
  double get totalCarbs => carbs;

  /// Alias de conveniência para [fat].
  double get totalFat => fat;
}