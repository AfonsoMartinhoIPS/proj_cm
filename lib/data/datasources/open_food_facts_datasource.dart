import 'package:dio/dio.dart';
import 'package:nutri_scan/core/config/app_config.dart';
import 'package:nutri_scan/domain/entities/nutriments.dart';
import 'package:nutri_scan/domain/entities/product.dart';

class OpenFoodFactsDatasource {
  static final String _baseUrl = AppConfig.openFoodFactsUseStaging
      ? 'https://world.openfoodfacts.net/api/v2' // staging
      : 'https://world.openfoodfacts.org/api/v2'; // production

  static const String _fields =
      'product_name,brands,quantity,product_quantity,serving_size,serving_quantity,'
      'image_url,image_front_small_url,ingredients_text,allergens_tags,traces_tags,'
      'labels_tags,nutriments,nutrient_levels,nova_group,nutriscore_grade';

  static final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'User-Agent': 'NutriScan - Flutter'},
  ));

  static OpenFoodFactsDatasource instance = OpenFoodFactsDatasource();

  static Future<Product?> getByBarcode(String barcode) async {
    final response = await _dio.get(
      '/product/$barcode.json',
      queryParameters: {'fields': _fields},
    );

    final data = response.data as Map<String, dynamic>;
    if (data['status'] != 1) return null; // product not found

    final productResponse = data['product'] as Map<String, dynamic>;
    final nutriments = productResponse['nutriments'] as Map<String, dynamic>? ?? {};

    return Product(
      barcode: barcode,
      name: (productResponse['product_name'] as String?)?.trim().isNotEmpty == true
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
      nutriscoreGrade: _nullIfUnknown(productResponse['nutriscore_grade'] as String?),
      novaGroup: productResponse['nova_group'] as int?,
      nutriments: Nutriments(
        caloriesPer100g: (nutriments['energy-kcal_100g'] as num?)?.toDouble(),
        carbsPer100g: (nutriments['carbohydrates_100g'] as num?)?.toDouble(),
        sugarsPer100g: (nutriments['sugars_100g'] as num?)?.toDouble(),
        fatPer100g: (nutriments['fat_100g'] as num?)?.toDouble(),
        saturatedFatPer100g: (nutriments['saturated-fat_100g'] as num?)?.toDouble(),
        proteinPer100g: (nutriments['proteins_100g'] as num?)?.toDouble(),
        saltPer100g: (nutriments['salt_100g'] as num?)?.toDouble(),
        fiberPer100g: (nutriments['fiber_100g'] as num?)?.toDouble(),
      ),
      source: 'openfoodfacts',
      fetchedAt: DateTime.now(),
    );
  }

  static Future<List<Product>> searchByName(String query, {int pageSize = 10}) async {
    final response = await _dio.get(
      'https://world.openfoodfacts${AppConfig.openFoodFactsUseStaging ? '.net' : '.org'}/cgi/search.pl',
      queryParameters: {
        'search_terms': query,
        'json': 1,
        'page_size': pageSize,
        'fields': 'code,product_name,brands,image_url,nutriments,nutriscore_grade',
      },
    );

    final products = response.data['products'] as List<dynamic>? ?? [];

    return products
        .map((p) => _fromSearchResult(p as Map<String, dynamic>))
        .whereType<Product>()
        .toList();
  }

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
        caloriesPer100g: (nutriments['energy-kcal_100g'] as num?)?.toDouble(),
        carbsPer100g: (nutriments['carbohydrates_100g'] as num?)?.toDouble(),
        fatPer100g: (nutriments['fat_100g'] as num?)?.toDouble(),
        proteinPer100g: (nutriments['proteins_100g'] as num?)?.toDouble(),
      ),
      source: 'openfoodfacts',
      fetchedAt: DateTime.now(),
    );
  }

  static String? _nullIfUnknown(String? value) {
    if (value == null || value == 'unknown' || value == 'not-applicable') return null;
    return value;
  }
}
