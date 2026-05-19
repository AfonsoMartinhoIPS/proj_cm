// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:nutri_scan/core/utils/logger.dart';
// import 'package:nutri_scan/data/repositories/nutrition_log_repository_impl.dart';
// import 'package:nutri_scan/data/repositories/product_repository_impl.dart';
// import 'package:nutri_scan/domain/entities/app_user.dart';
// import 'package:nutri_scan/domain/entities/meal_entry.dart';
// import 'package:nutri_scan/domain/entities/nutrition_log.dart';
// import 'package:nutri_scan/domain/entities/product.dart';
// import 'package:nutri_scan/domain/entities/saved_product.dart';
// import 'package:nutri_scan/presentation/providers/auth_provider.dart';



// class ProductNotifier extends AsyncNotifier<List<SavedProduct>> {
//   final repo = ProductRepositoryImpl();
//   int _productsLoaded = 20;

//   @override
//   Future<List<SavedProduct>> build() async {
//     final user = ref.watch(authProvider).value;
//     if (user == null) {
//       logger.d('ProductProvider: no user, empty list');
//       return [];
//     }
//     return _fetch(user.uid, _productsLoaded);
//   }



//   Future<List<SavedProduct>> _fetch(String uid, int count) async {
//     return repo.getSavedProducts(uid, count);
//   }

//   Future<void> loadMore({int extraProducts = 7}) async {
//     final user = ref.read(authProvider).value;
//     if (user == null) return;
//     _productsLoaded += extraProducts;
//     logger.d('ProductProvider: loadMore → $_productsLoaded products total');
//     state = const AsyncValue.loading();
//     state = await AsyncValue.guard(() => _fetch(user.uid, _productsLoaded));
//   }

//     int get productsLoaded => _productsLoaded;

//   // --- mutations: refresh just the affected date and splice into list ---

//   Future<void> addEntry(SavedProduct savedProduct) async {
//     final user = ref.read(authProvider).value;
//     if (user == null) return;
    
//     logger.d('ProductProvider: addEntry ${savedProduct.barcode} (${savedProduct.servingGrams}g)');
//     try {
//       await repo.addEntry(user.uid, d, entry);
//       await _refreshDate(user, d);
//     } catch (e, st) {
//       logger.e('NutritionLogs: addEntry error', error: e, stackTrace: st);
//       state = AsyncValue.error(e, st);
//     }
//   }

//   Future<void> removeEntry(String entryId, {String? date}) async {
//     final user = ref.read(authProvider).value;
//     if (user == null) return;
//     final d = date ?? _todayKey();
//     logger.d('NutritionLogs: removeEntry $entryId on $d');
//     try {
//       await repo.removeEntry(user.uid, d, entryId);
//       await _refreshDate(user, d);
//     } catch (e, st) {
//       logger.e('NutritionLogs: removeEntry error', error: e, stackTrace: st);
//       state = AsyncValue.error(e, st);
//     }
//   }

//   Future<void> setWater(double ml, {String? date}) async {
//     final user = ref.read(authProvider).value;
//     if (user == null) return;
//     final d = date ?? _todayKey();
//     logger.d('NutritionLogs: setWater ${ml}ml on $d');
//     try {
//       await repo.updateWater(user.uid, d, ml);
//       await _refreshDate(user, d);
//     } catch (e, st) {
//       logger.e('NutritionLogs: setWater error', error: e, stackTrace: st);
//       state = AsyncValue.error(e, st);
//     }
//   }

//   Future<void> addWater(double ml, {String? date}) async {
//     final d = date ?? _todayKey();
//     final logs = state.value ?? [];
//     final current = logs.firstWhere(
//       (l) => l.date == d,
//       orElse: () => _emptyLog(d, ref.read(authProvider).value!),
//     );
//     await setWater(current.waterMl + ml, date: d);
//   }
// }

// final nutritionLogsProvider =
//     AsyncNotifierProvider<NutritionLogsNotifier, List<NutritionLog>>(NutritionLogsNotifier.new);
