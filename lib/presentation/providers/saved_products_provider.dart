import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projeto/core/utils/logger.dart';
import 'package:projeto/data/models/saved_product_model.dart';
import 'package:projeto/data/repositories/product_repository_impl.dart';
import 'package:projeto/domain/entities/product.dart';
import 'package:projeto/domain/entities/saved_product.dart';
import 'package:projeto/presentation/providers/auth_provider.dart';

/// Default page size when loading saved products.
const _defaultPageSize = 50;

class SavedProductsNotifier extends AsyncNotifier<List<SavedProduct>> {
  final repo = ProductRepositoryImpl();
  int _count = _defaultPageSize;

  @override
  Future<List<SavedProduct>> build() async {
    final user = ref.watch(authProvider).value;
    if (user == null) {
      logger.d('SavedProducts: no user, empty list');
      return [];
    }
    return _fetch(user.uid, _count);
  }

  Future<List<SavedProduct>> _fetch(String uid, int count) async {
    logger.d('SavedProducts: fetching $count saved for $uid');
    return repo.getSavedProducts(uid, count);
  }

  /// Save a product (from scan, search, etc) to the user's saved list.
  /// Builds a snapshot from the Product — full data stays in `products/{barcode}`.
  Future<void> saveProduct(Product product) async {
    final user = ref.read(authProvider).value;
    if (user == null) return;
    logger.d('SavedProducts: saving ${product.barcode} — ${product.name}');
    try {
      await repo.saveForUser(user.uid, SavedProductModel.fromProduct(product));
      state = AsyncValue.data(await _fetch(user.uid, _count));
    } catch (e, st) {
      logger.e('SavedProducts: saveProduct error', error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
    }
  }

  /// Replace the entire notes array for a saved product.
  Future<void> setNotes(String barcode, List<SavedProductNote> notes) async {
    final user = ref.read(authProvider).value;
    if (user == null) return;
    logger.d('SavedProducts: setNotes $barcode (${notes.length} notes)');
    try {
      await repo.setNotes(user.uid, barcode, notes);
      state = AsyncValue.data(await _fetch(user.uid, _count));
    } catch (e, st) {
      logger.e('SavedProducts: setNotes error', error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> removeProduct(String barcode) async {
    final user = ref.read(authProvider).value;
    if (user == null) return;
    logger.d('SavedProducts: removing $barcode');
    try {
      await repo.deleteSaved(user.uid, barcode);
      state = AsyncValue.data(await _fetch(user.uid, _count));
    } catch (e, st) {
      logger.e('SavedProducts: removeProduct error', error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
    }
  }

  /// Increase the page size and refetch.
  Future<void> loadMore({int extra = 50}) async {
    final user = ref.read(authProvider).value;
    if (user == null) return;
    _count += extra;
    logger.d('SavedProducts: loadMore → $_count');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch(user.uid, _count));
  }
}

final savedProductsProvider =
    AsyncNotifierProvider<SavedProductsNotifier, List<SavedProduct>>(SavedProductsNotifier.new);
