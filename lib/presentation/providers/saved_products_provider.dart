// lib/presentation/providers/saved_products_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/data/models/saved_product_model.dart';
import 'package:nutri_scan/data/repositories/product_repository_impl.dart';
import 'package:nutri_scan/domain/entities/product.dart';
import 'package:nutri_scan/domain/entities/saved_product.dart';
import 'package:nutri_scan/presentation/providers/auth_provider.dart';

/// Tamanho de página padrão ao carregar produtos guardados.
const _defaultPageSize = 50;

/// Notifier que gere a lista de produtos guardados pelo utilizador autenticado.
///
/// Suporta guardar, remover, atualizar notas e paginação.  Utiliza o
/// [ProductRepositoryImpl] para interagir com a camada de dados e reage
/// automaticamente a alterações no [authProvider] (limpando a lista quando
/// o utilizador sai).
class SavedProductsNotifier extends AsyncNotifier<List<SavedProduct>> {
  final repo = ProductRepositoryImpl();
  int _count = _defaultPageSize;

  /// Constrói o estado inicial da lista de produtos guardados.
  ///
  /// Se o utilizador não estiver autenticado, devolve uma lista vazia.
  /// Caso contrário, carrega os primeiros [_defaultPageSize] produtos.
  @override
  Future<List<SavedProduct>> build() async {
    final user = ref.watch(authProvider).value;
    if (user == null) {
      logger.d('SavedProducts: no user, empty list');
      return [];
    }
    return _fetch(user.uid, _count);
  }

  /// Obtém os produtos guardados do utilizador com o [uid] especificado,
  /// limitados a [count] registos.
  Future<List<SavedProduct>> _fetch(String uid, int count) async {
    logger.d('SavedProducts: fetching $count saved for $uid');
    return repo.getSavedProducts(uid, count);
  }

  /// Guarda um [Product] na lista de favoritos do utilizador.
  ///
  /// Cria uma snapshot do produto para armazenamento leve; os dados
  /// completos continuam em `products/{barcode}`.
  Future<void> saveProduct(Product product) async {
    final user = ref.read(authProvider).value;
    if (user == null) return;
    logger.d('SavedProducts: saving ${product.barcode} - ${product.name}');
    try {
      await repo.saveForUser(user.uid, SavedProductModel.fromProduct(product));
      state = AsyncValue.data(await _fetch(user.uid, _count));
    } catch (e, st) {
      logger.e('SavedProducts: saveProduct error', error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
    }
  }

  /// Substitui toda a lista de notas de um produto guardado.
  ///
  /// [barcode] identifica o produto e [notes] é a nova lista completa de
  /// notas que será persistida.
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

  /// Remove um produto da lista de favoritos do utilizador.
  ///
  /// Apenas o documento em `users/{uid}/saved_products/{barcode}` é afetado;
  /// os dados originais em `products/{barcode}` permanecem inalterados.
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

  /// Aumenta o tamanho da página e recarrega os dados.
  ///
  /// Útil para implementar "scroll infinito" — por predefinição adiciona
  /// mais 50 produtos ao limite de carregamento.
  Future<void> loadMore({int extra = 50}) async {
    final user = ref.read(authProvider).value;
    if (user == null) return;
    _count += extra;
    logger.d('SavedProducts: loadMore → $_count');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch(user.uid, _count));
  }
}

/// Provider que expõe a lista de produtos guardados do utilizador atual.
///
/// Reage automaticamente a alterações no [authProvider], recarregando os
/// dados quando o utilizador muda.
final savedProductsProvider =
    AsyncNotifierProvider<SavedProductsNotifier, List<SavedProduct>>(SavedProductsNotifier.new);