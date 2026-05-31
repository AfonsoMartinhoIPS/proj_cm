import 'package:nutri_scan/domain/entities/product.dart';
import 'package:nutri_scan/domain/entities/saved_product.dart';

/// Contrato para operações de persistência de produtos.
///
/// Define os métodos que qualquer implementação de repositório de produtos
/// deve fornecer: pesquisa por código de barras, guardar um produto completo,
/// e gerir a lista de produtos guardados de um utilizador (incluindo notas).
abstract class ProductRepository {
  /// Obtém um [Product] completo a partir do seu [barcode].
  ///
  /// Pode devolver `null` se o produto não for encontrado.
  Future<Product?> getByBarcode(String barcode);

  /// Persiste um [Product] completo no sistema de armazenamento.
  Future<void> save(Product product);

  /// Devolve os produtos guardados do utilizador [uid], limitados a [count].
  Future<List<SavedProduct>> getSavedProducts(String uid, int count);

  /// Devolve um produto guardado específico ou `null` se não existir.
  Future<SavedProduct?> getSavedProduct(String uid, String barcode);

  /// Guarda um [SavedProduct] na lista de favoritos do utilizador [uid].
  Future<void> saveForUser(String uid, SavedProduct savedProduct);

  /// Substitui a lista de notas de um produto guardado.
  Future<void> setNotes(
      String uid, String barcode, List<SavedProductNote> notes);

  /// Remove um produto da lista de favoritos do utilizador [uid].
  Future<void> deleteSaved(String uid, String barcode);
}