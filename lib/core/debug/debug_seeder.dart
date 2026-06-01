import 'dart:math';

import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/data/repositories/nutrition_log_repository_impl.dart';
import 'package:nutri_scan/data/repositories/product_repository_impl.dart';
import 'package:nutri_scan/domain/entities/app_user.dart';
import 'package:nutri_scan/domain/entities/meal_entry.dart';
import 'package:nutri_scan/domain/entities/nutriments.dart';
import 'package:nutri_scan/domain/entities/product.dart';
import 'package:nutri_scan/domain/entities/saved_product.dart';

/// Debug-only utility that bulk-writes fake meal entries + saved products to
/// Firestore for the current user.
///
/// Use to stress-test list pagination, scroll perf, search latency and the
/// notification-reschedule cost. Numbers are wired through the same repos
/// the production paths use, so the data shape exactly mirrors a real user.
///
/// Run via a debug-only button (`if (kDebugMode) ...`) in Settings. **Not**
/// production code — never call from a release build.
class DebugSeeder {
  DebugSeeder._();

  static final _rng = Random(42);

  static const _sampleProducts = [
    ('5601234567890', 'Iogurte Natural Mimosa', 'Mimosa', 60.0),
    ('5602345678901', 'Pão de forma Bimbo', 'Bimbo', 245.0),
    ('5603456789012', 'Atum em água Bom Petisco', 'Bom Petisco', 110.0),
    ('5604567890123', 'Coca-Cola lata', 'Coca-Cola', 42.0),
    ('5605678901234', 'Banana', null, 89.0),
    ('5606789012345', 'Frango grelhado', null, 165.0),
    ('5607890123456', 'Arroz Cigala cozido', 'Cigala', 130.0),
    ('5608901234567', 'Salmão fumado', null, 117.0),
    ('5609012345678', 'Queijo da ilha', null, 380.0),
    ('5600123456789', 'Maçã golden', null, 52.0),
  ];

  /// Writes [productCount] saved products and [mealCount] meal entries
  /// spread across the last [daysSpan] days. Returns a summary string with
  /// the operation counts and elapsed wall time.
  ///
  /// All writes go through the real repositories, so this also exercises
  /// the cache + auto-cleanup + provider reschedule paths.
  static Future<String> seed({
    required AppUser user,
    int productCount = 50,
    int mealCount = 100,
    int daysSpan = 30,
  }) async {
    final sw = Stopwatch()..start();
    final productRepo = ProductRepositoryImpl();
    final logRepo = NutritionLogRepositoryImpl();

    logger.d(
      'DebugSeeder: starting — '
      'products=$productCount, meals=$mealCount, days=$daysSpan',
    );

    // 1. Seed products (cache + user's saved list).
    final savedProducts = <SavedProduct>[];
    for (var i = 0; i < productCount; i++) {
      final sample = _sampleProducts[i % _sampleProducts.length];
      // Suffix the barcode so collisions don't auto-merge entries.
      final barcode = '${sample.$1}-${i.toString().padLeft(3, '0')}';
      final product = Product(
        barcode: barcode,
        name: '${sample.$2} #$i',
        brand: sample.$3,
        nutriments: Nutriments(caloriesPer100g: sample.$4),
        source: 'manual',
        fetchedAt: DateTime.now(),
      );
      await productRepo.save(product);
      savedProducts.add(
        SavedProduct(
          barcode: barcode,
          savedAt: DateTime.now().subtract(Duration(minutes: i)),
          name: product.name,
          brand: product.brand,
          caloriesPer100g: product.nutriments.caloriesPer100g,
        ),
      );
      await productRepo.saveForUser(user.uid, savedProducts.last);
    }

    // 2. Seed meal entries scattered across past days.
    final goals = user.nutritionGoals;
    for (var i = 0; i < mealCount; i++) {
      final daysAgo = _rng.nextInt(daysSpan);
      final date = dateKey(DateTime.now().subtract(Duration(days: daysAgo)));
      final sample = _sampleProducts[i % _sampleProducts.length];
      final grams = 50 + _rng.nextInt(250).toDouble();
      final calsPer100 = sample.$4;
      final entry = MealEntry(
        id: 'seed-${DateTime.now().microsecondsSinceEpoch}-$i',
        productBarcode: sample.$1,
        productName: sample.$2,
        productImageUrl: null,
        mealType: MealType.values[_rng.nextInt(MealType.values.length)],
        servingGrams: grams,
        calories: calsPer100 / 100 * grams,
        protein: _rng.nextDouble() * 30,
        carbs: _rng.nextDouble() * 60,
        fat: _rng.nextDouble() * 20,
        loggedAt: DateTime.now().subtract(Duration(days: daysAgo, hours: i % 24)),
      );
      await logRepo.addEntry(
        user.uid,
        date,
        entry,
        goalsSnapshot: goals,
      );
    }

    sw.stop();
    final msg =
        'Seeded $productCount products + $mealCount meals across $daysSpan '
        'days in ${sw.elapsedMilliseconds}ms';
    logger.d('DebugSeeder: $msg');
    return msg;
  }

  /// Removes every saved product and nutrition log for the user. Useful for
  /// resetting state between stress-test runs. Skips the global products
  /// cache — those are shared across users.
  static Future<String> wipe({required AppUser user}) async {
    final sw = Stopwatch()..start();
    final productRepo = ProductRepositoryImpl();
    final logRepo = NutritionLogRepositoryImpl();

    final saved = await productRepo.getSavedProducts(user.uid, 500);
    for (final p in saved) {
      await productRepo.deleteSaved(user.uid, p.barcode);
    }

    // Wipe last 365 days of logs — overkill but covers anything the seeder
    // could have written.
    for (var d = 0; d < 365; d++) {
      final date = dateKey(DateTime.now().subtract(Duration(days: d)));
      await logRepo.deleteLog(user.uid, date);
    }

    sw.stop();
    final msg = 'Wiped ${saved.length} saved products + 365 days of logs '
        'in ${sw.elapsedMilliseconds}ms';
    logger.d('DebugSeeder: $msg');
    return msg;
  }
}
