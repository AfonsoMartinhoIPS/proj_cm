// lib/data/datasources/open_food_facts_datasource.dart

import 'package:dio/dio.dart';
import 'package:nutri_scan/core/config/app_config.dart';
import 'package:nutri_scan/core/utils/logger.dart';
import 'package:nutri_scan/domain/entities/nutriments.dart';
import 'package:nutri_scan/domain/entities/product.dart';

/// Fonte de dados remota que consulta a API Open Food Facts.
///
/// Permite obter um produto pelo código de barras e pesquisar produtos por nome.
/// Seleciona automaticamente o ambiente (produção ou staging) com base na
/// configuração [AppConfig.openFoodFactsUseStaging].
class OpenFoodFactsDatasource {
  static final String _baseUrl = AppConfig.openFoodFactsUseStaging
      ? 'https://world.openfoodfacts.net/api/v2'
      : 'https://world.openfoodfacts.org/api/v2';

  static const String _fields =
      'product_name,brands,quantity,product_quantity,serving_size,serving_quantity,'
      'image_url,image_front_small_url,ingredients_text,allergens_tags,traces_tags,'
      'labels_tags,nutriments,nutrient_levels,nova_group,nutriscore_grade';

  static final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'User-Agent': 'nutri_scan - Flutter'},
  ));

  /// Instância singleton da fonte de dados (mantida por compatibilidade).
  static OpenFoodFactsDatasource instance = OpenFoodFactsDatasource();

  /// Obtém um [Product] completo a partir do código de barras.
  ///
  /// Devolve `null` se o produto não for encontrado ou se a API devolver um
  /// estado diferente de sucesso.
  static Future<Product?> getByBarcode(String barcode) async {
    final Response<dynamic> response;
    try {
      response = await _dio.get(
        '/product/$barcode.json',
        queryParameters: {'fields': _fields},
      );
    } on DioException catch (e) {
      // OFF devolve 404 para códigos de barras desconhecidos — Dio lança por padrão em
      // respostas não-2xx. Tratar como "não encontrado" em vez de propagar rastreamento para
      // a UI. Erros de rede/timeout também são colapsos nulos; a tela
      // mostra o mesmo estado vazio "produto não encontrado" independentemente de
      // qual é a causa subjacente (o utilizador só quer saber que não funcionou).
      logger.w('OFF getByBarcode failed: ${e.type} ${e.response?.statusCode}');
      return null;
    }

    final data = response.data as Map<String, dynamic>;
    if (data['status'] != 1) return null;

    final productResponse = data['product'] as Map<String, dynamic>;
    final nutriments =
        productResponse['nutriments'] as Map<String, dynamic>? ?? {};

    return Product(
      barcode: barcode,
      name:
          (productResponse['product_name'] as String?)?.trim().isNotEmpty == true
              ? productResponse['product_name'] as String
              : 'Unknown product',
      brand: productResponse['brands'] as String?,
      displayQuantity: productResponse['quantity'] as String?,
      imageUrl: productResponse['image_url'] as String?,
      imageThumbnailUrl: productResponse['image_front_small_url'] as String?,
      ingredientsText: productResponse['ingredients_text'] as String?,
      allergenTags: List<String>.from(productResponse['allergens_tags'] ?? []),
      tracesTags: List<String>.from(productResponse['traces_tags'] ?? []),
      labelTags: List<String>.from(productResponse['labels_tags'] ?? []),
      nutriscoreGrade:
          _nullIfUnknown(productResponse['nutriscore_grade'] as String?),
      novaGroup: productResponse['nova_group'] as int?,
      nutriments: Nutriments(
        caloriesPer100g:
            (nutriments['energy-kcal_100g'] as num?)?.toDouble(),
        carbsPer100g:
            (nutriments['carbohydrates_100g'] as num?)?.toDouble(),
        sugarsPer100g: (nutriments['sugars_100g'] as num?)?.toDouble(),
        fatPer100g: (nutriments['fat_100g'] as num?)?.toDouble(),
        saturatedFatPer100g:
            (nutriments['saturated-fat_100g'] as num?)?.toDouble(),
        proteinPer100g: (nutriments['proteins_100g'] as num?)?.toDouble(),
        saltPer100g: (nutriments['salt_100g'] as num?)?.toDouble(),
        fiberPer100g: (nutriments['fiber_100g'] as num?)?.toDouble(),
      ),
      source: 'openfoodfacts',
      fetchedAt: DateTime.now(),
    );
  }

  /// Pesquisa produtos por nome na API Open Food Facts.
  ///
  /// Devolve uma lista de [Product] que correspondem à [query], limitada a
  /// [pageSize] resultados (padrão: 10). Cada produto contém apenas os campos
  /// essenciais (nome, marca, imagem, nutriments principais e Nutri‑Score).
  static Future<List<Product>> searchByName(String query,
      {int pageSize = 10}) async {
    final response = await _dio.get(
      'https://world.openfoodfacts${AppConfig.openFoodFactsUseStaging ? '.net' : '.org'}/cgi/search.pl',
      queryParameters: {
        'search_terms': query,
        'json': 1,
        'page_size': pageSize,
        'fields':
            'code,product_name,brands,image_url,nutriments,nutriscore_grade',
      },
    );

    final products = response.data['products'] as List<dynamic>? ?? [];

    return products
        .map((p) => _fromSearchResult(p as Map<String, dynamic>))
        .whereType<Product>()
        .toList();
  }

  /// Converte um item do resultado de pesquisa num [Product].
  ///
  /// Ignora produtos sem nome. Os nutriments são extraídos do sub‑mapa
  /// `nutriments` e apenas os campos principais são preenchidos.
  static Product? _fromSearchResult(Map<String, dynamic> p) {
    final name = (p['product_name'] as String?)?.trim();
    if (name == null || name.isEmpty) return null;

    final nutriments = p['nutriments'] as Map<String, dynamic>? ?? {};

    return Product(
      barcode: p['code'] as String? ?? '',
      name: name,
      brand: p['brands'] as String?,
      imageUrl: p['image_url'] as String?,
      nutriscoreGrade: _nullIfUnknown(p['nutriscore_grade'] as String?),
      nutriments: Nutriments(
        caloriesPer100g:
            (nutriments['energy-kcal_100g'] as num?)?.toDouble(),
        carbsPer100g:
            (nutriments['carbohydrates_100g'] as num?)?.toDouble(),
        fatPer100g: (nutriments['fat_100g'] as num?)?.toDouble(),
        proteinPer100g: (nutriments['proteins_100g'] as num?)?.toDouble(),
      ),
      source: 'openfoodfacts',
      fetchedAt: DateTime.now(),
    );
  }

  /// Devolve `null` para valores inválidos ou desconhecidos de Nutri‑Score.
  ///
  /// Considera inválidos os valores `null`, `"unknown"` e `"not-applicable"`.
  static String? _nullIfUnknown(String? value) {
    if (value == null || value == 'unknown' || value == 'not-applicable') {
      return null;
    }
    return value;
  }
}