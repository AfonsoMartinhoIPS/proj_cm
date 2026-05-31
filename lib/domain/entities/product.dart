import 'package:nutri_scan/domain/entities/nutriments.dart';

/// Representa um produto alimentar obtido a partir de um código de barras.
///
/// Contém toda a informação descritiva e nutricional do produto, incluindo
/// alérgenos, rótulos, grupo NOVA e a fonte de onde os dados foram obtidos.
class Product {
  /// Código de barras único do produto (EAN-13, UPC, etc.).
  final String barcode;

  /// Nome comercial do produto.
  final String name;

  /// Marca do produto, se disponível.
  final String? brand;

  /// Quantidade exibida na embalagem (ex.: "250 g", "1 L").
  final String? displayQuantity;

  /// URL da imagem de alta resolução do produto.
  final String? imageUrl;

  /// URL da miniatura da imagem do produto.
  final String? imageThumbnailUrl;

  /// Texto descritivo dos ingredientes, se disponível.
  final String? ingredientsText;

  /// Lista de tags de alérgenos associados ao produto.
  ///
  /// O valor padrão é uma lista vazia.
  final List<String> allergenTags;

  /// Lista de tags de vestígios (traces) de substâncias que podem estar
  /// presentes no produto.
  ///
  /// O valor padrão é uma lista vazia.
  final List<String> tracesTags;

  /// Lista de tags de certificações ou rótulos (ex.: "Bio", "Fairtrade").
  ///
  /// O valor padrão é uma lista vazia.
  final List<String> labelTags;

  /// Nota Nutri-Score do produto (ex.: "a", "b", "c", "d", "e").
  final String? nutriscoreGrade;

  /// Grupo NOVA (1 a 4) que indica o grau de processamento do produto.
  final int? novaGroup;

  /// Informação nutricional detalhada do produto.
  final Nutriments nutriments;

  /// Fonte de onde os dados do produto foram obtidos.
  ///
  /// Valores típicos: `"openfoodfacts"`, `"usda"`, `"manual"`.
  final String source;

  /// Data e hora da última obtenção dos dados.
  final DateTime? fetchedAt;

  /// Cria um [Product].
  ///
  /// Os parâmetros [barcode], [name], [nutriments], [source] e [fetchedAt]
  /// são obrigatórios.
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