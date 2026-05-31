/// Uma nota de texto associada a um produto guardado.
///
/// Cada nota contém o texto introduzido pelo utilizador e a data e hora em
/// que foi criada.
class SavedProductNote {
  /// O conteúdo textual da nota.
  final String text;

  /// O momento exato em que a nota foi criada.
  final DateTime createdAt;

  /// Cria uma [SavedProductNote].
  ///
  /// Ambos os parâmetros são obrigatórios.
  const SavedProductNote({
    required this.text,
    required this.createdAt,
  });
}

/// Snapshot de um produto que o utilizador guardou.
///
/// Os dados completos do produto residem em `products/{barcode}` — esta
/// classe mantém apenas a informação necessária para renderizar a lista de
/// favoritos sem necessidade de uma segunda leitura por cada item.
class SavedProduct {
  /// Código de barras do produto.
  final String barcode;

  /// Data e hora em que o produto foi guardado.
  final DateTime savedAt;

  /// Nome do produto (cópia do campo no documento original).
  final String name;

  /// Marca do produto, se disponível.
  final String? brand;

  /// URL da imagem do produto, se disponível.
  final String? imageUrl;

  /// Calorias por 100 g/ml, se disponíveis.
  final double? caloriesPer100g;

  /// Notas pessoais associadas a este produto.
  ///
  /// O valor padrão é uma lista vazia.
  final List<SavedProductNote> notes;

  /// Cria um [SavedProduct].
  ///
  /// Os parâmetros [barcode], [savedAt] e [name] são obrigatórios.
  const SavedProduct({
    required this.barcode,
    required this.savedAt,
    required this.name,
    this.brand,
    this.imageUrl,
    this.caloriesPer100g,
    this.notes = const [],
  });

  /// Cria uma cópia deste produto guardado, substituindo apenas os campos
  /// fornecidos.
  ///
  /// Útil para atualizar os dados da snapshot quando o produto original é
  /// alterado, ou para modificar as notas sem mutar o objeto original.
  SavedProduct copyWith({
    String? name,
    String? brand,
    String? imageUrl,
    double? caloriesPer100g,
    List<SavedProductNote>? notes,
  }) {
    return SavedProduct(
      barcode: barcode,
      savedAt: savedAt,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      imageUrl: imageUrl ?? this.imageUrl,
      caloriesPer100g: caloriesPer100g ?? this.caloriesPer100g,
      notes: notes ?? this.notes,
    );
  }
}