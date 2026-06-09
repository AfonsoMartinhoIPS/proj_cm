// lib/data/repositories/product_repository_impl.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/data/datasources/open_food_facts_datasource.dart';
import 'package:nutri_scan/data/models/product_model.dart';
import 'package:nutri_scan/data/models/saved_product_model.dart';
import 'package:nutri_scan/domain/entities/product.dart';
import 'package:nutri_scan/domain/entities/saved_product.dart';
import 'package:nutri_scan/domain/repositories/product_repository.dart';

/// Implementação do [ProductRepository] que utiliza o Firestore como cache
/// e a API Open Food Facts como fonte de dados primária.
///
/// Os produtos são guardados localmente em `products/{barcode}` e servidos
/// a partir da cache durante 15 dias. Após esse período, uma nova consulta
/// à API externa é feita para obter dados atualizados.
///
/// A lista de produtos guardados por utilizador é gerida na subcoleção
/// `users/{uid}/saved_products`.
class ProductRepositoryImpl implements ProductRepository {
  final _db = FirebaseFirestore.instance;

  /// Indica se um produto em cache está desatualizado (mais de 15 dias desde
  /// a última obtenção).
  bool _isStale(Product product) {
    if (product.fetchedAt == null) return true;
    return DateTime.now().difference(product.fetchedAt!).inDays >= 15;
  }

  /// Obtém um [Product] completo a partir do seu [barcode].
  ///
  /// Consulta primeiro a cache local (Firestore). Se o produto não existir
  /// ou estiver desatualizado, pesquisa na API Open Food Facts e atualiza
  /// a cache antes de devolver o resultado.
  ///
  /// Pode devolver `null` se o produto não for encontrado em nenhuma fonte.
  @override
  Future<Product?> getByBarcode(String barcode) async {
    logger.d('getByBarcode: $barcode - checking Firestore');
    final doc = await _db.doc(FirestorePaths.product(barcode)).get();
    final cached = ProductModel.fromDoc(doc);

    if (cached != null && !_isStale(cached)) {
      logger.d('cache hit: ${cached.name}');
      return cached;
    }

    logger.d('cache miss - fetching from OpenFoodFacts');
    final product = await OpenFoodFactsDatasource.getByBarcode(barcode);
    if (product != null) {
      logger.d('fetched: ${product.name} - saving to Firestore');
      await save(product);
    }

    return product;
  }

  /// Persiste um [Product] no Firestore (cache local).
  ///
  /// Utiliza `merge: true` para preservar campos que não estejam presentes
  /// no objeto atual.
  @override
  Future<void> save(Product product) async {
    await _db
        .doc(FirestorePaths.product(product.barcode))
        .set(ProductModel.toMap(product), SetOptions(merge: true));
  }

  /// Devolve a lista de produtos guardados pelo utilizador [uid], ordenada
  /// do mais recente para o mais antigo, limitada a [count] itens.
  @override
  Future<List<SavedProduct>> getSavedProducts(String uid, int count) async {
    final snapshot = await _db
        .collection(FirestorePaths.savedProducts(uid))
        .orderBy('savedAt', descending: true)
        .limit(count)
        .get();
    return snapshot.docs
        .map((doc) => SavedProductModel.fromDoc(doc))
        .whereType<SavedProduct>()
        .toList();
  }

  /// Devolve um produto guardado específico do utilizador [uid] com o
  /// [barcode] indicado, ou `null` se não existir.
  @override
  Future<SavedProduct?> getSavedProduct(String uid, String barcode) async {
    final doc =
        await _db.doc(FirestorePaths.savedProduct(uid, barcode)).get();
    return SavedProductModel.fromDoc(doc);
  }

  /// Guarda um [SavedProduct] na lista de favoritos do utilizador [uid].
  ///
  /// Utiliza `merge: true` para não sobrescrever campos existentes (como
  /// as notas) que possam já estar no documento.
  @override
  Future<void> saveForUser(String uid, SavedProduct savedProduct) async {
    await _db
        .doc(FirestorePaths.savedProduct(uid, savedProduct.barcode))
        .set(SavedProductModel.toMap(savedProduct), SetOptions(merge: true));
  }

  /// Substitui toda a lista de notas do produto guardado identificado por
  /// [barcode], pertencente ao utilizador [uid].
  ///
  /// Cada nota em [notes] é convertida para um mapa com os campos `text`
  /// e `createdAt`.
  @override
  Future<void> setNotes(
      String uid, String barcode, List<SavedProductNote> notes) async {
    await _db.doc(FirestorePaths.savedProduct(uid, barcode)).update({
      'notes': notes
          .map((note) => {
                'text': note.text,
                'createdAt': Timestamp.fromDate(note.createdAt),
              })
          .toList(),
    });
  }

  /// Remove o produto com o [barcode] indicado da lista de favoritos do
  /// utilizador [uid].
  ///
  /// Apenas o documento em `users/{uid}/saved_products/{barcode}` é afetado.
  @override
  Future<void> deleteSaved(String uid, String barcode) async {
    await _db.doc(FirestorePaths.savedProduct(uid, barcode)).delete();
  }
}