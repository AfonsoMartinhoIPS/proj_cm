import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/presentation/widgets/widgets_components.dart';
import 'package:nutri_scan/data/repositories/product_repository_impl.dart';
import 'package:nutri_scan/domain/entities/product.dart';
import 'package:nutri_scan/domain/entities/saved_product.dart';
import 'package:nutri_scan/presentation/providers/saved_products_provider.dart';

/// Provider que carrega um [Product] a partir de um código de barras.
///
/// Utiliza o [ProductRepositoryImpl] para obter o produto, seja da cache
/// local (Firestore) ou da API externa (Open Food Facts). Como é um
/// [FutureProvider.family], cada código de barras tem a sua própria
/// entrada em cache.
final productByBarcodeProvider = FutureProvider.family<Product?, String>(
  (ref, barcode) => ProductRepositoryImpl().getByBarcode(barcode),
);

/// Ecrã de detalhes de um produto.
///
/// Mostra a imagem do produto, a tabela nutricional e botões de ação
/// (guardar/remover e adicionar a uma refeição). Se o produto já estiver
/// guardado, exibe também a secção de notas associadas.
class ProductDetailsScreen extends ConsumerWidget {
  /// O código de barras do produto a exibir.
  final String barcode;

  /// Cria um [ProductDetailsScreen].
  ///
  /// O parâmetro [barcode] é obrigatório.
  const ProductDetailsScreen({super.key, required this.barcode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final asyncProduct = ref.watch(productByBarcodeProvider(barcode));

    final SavedProduct? savedProduct = ref
        .watch(savedProductsProvider)
        .value
        ?.cast<SavedProduct?>()
        .firstWhere((s) => s!.barcode == barcode, orElse: () => null);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: NutriTopNavBar(
        showBackButton: true,
        title: 'Detalhes do Produto',
      ),
      body: asyncProduct.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        // Errors thrown by the repo (network, parse) and the "not found"
        // null case both end up here visually — same friendly empty state
        // with actions, no stacktrace leaks to the UI.
        error: (e, _) => _NotFoundState(barcode: barcode),
        data: (product) {
          if (product == null) return _NotFoundState(barcode: barcode);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NutriProductThumbnail(
                  url: product.imageUrl ?? product.imageThumbnailUrl,
                  size: 90,
                ),
                const SizedBox(height: 24),
                NutriProductNutritionTable(product: product),
                const SizedBox(height: 24),
                _ActionButtons(product: product, isSaved: savedProduct != null),
                if (savedProduct != null) ...[
                  const SizedBox(height: 24),
                  _NotesSection(savedProduct: savedProduct),
                ],
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Estado de produto-não-encontrado. Cobre tanto o caso de o repositório
/// devolver `null` (404 do OFF, código inválido) como qualquer outro erro
/// de rede — colapsados na mesma mensagem para evitar expor stacktraces.
///
/// Inclui o código que foi tentado para o utilizador confirmar à vista
/// que digitalizou o que esperava, e um botão "Voltar" para regressar ao
/// scanner sem ter que carregar na seta da AppBar.
class _NotFoundState extends StatelessWidget {
  final String barcode;

  const _NotFoundState({required this.barcode});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            NutriLabel(
              'Produto não encontrado',
              variant: NutriLabelVariant.bodyLarge,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            NutriLabel(
              'Não conseguimos encontrar nada na base de dados para o código $barcode.',
              variant: NutriLabelVariant.body,
              color: colorScheme.onSurfaceVariant,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 220,
              child: NutriButton(
                label: 'Voltar',
                onPressed: () => context.pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botões de ação do ecrã de detalhes do produto.
///
/// Apresenta dois botões lado a lado:
/// - Guardar / Remover o produto dos favoritos.
/// - Adicionar o produto a uma refeição.
class _ActionButtons extends ConsumerWidget {
  /// O produto em exibição.
  final Product product;

  /// Indica se o produto já está guardado nos favoritos.
  final bool isSaved;

  /// Cria os [_ActionButtons].
  ///
  /// Os parâmetros [product] e [isSaved] são obrigatórios.
  const _ActionButtons({required this.product, required this.isSaved});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: NutriButton.transparent(
            label: isSaved ? 'Remover' : 'Guardar',
            icon: Icon(
              isSaved ? Icons.bookmark : Icons.bookmark_outline,
              color: colorScheme.secondary,
              size: 18,
            ),
            onPressed: () {
              final notifier = ref.read(savedProductsProvider.notifier);
              if (isSaved) {
                notifier.removeProduct(product.barcode);
                NutriFeedback.showInfo(context, 'Produto removido');
              } else {
                notifier.saveProduct(product);
                NutriFeedback.showSuccess(context, 'Produto guardado');
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: NutriButton(
            label: 'Add refeição',
            icon: Icon(
              Icons.restaurant,
              color: colorScheme.onSurface,
              size: 18,
            ),
            onPressed: () => context.push('/meals/add', extra: product),
          ),
        ),
      ],
    );
  }
}

/// Secção de notas de um produto guardado.
///
/// Exibe a lista de notas existentes (com data) e permite adicionar novas
/// notas ou remover notas antigas.
class _NotesSection extends ConsumerWidget {
  /// O produto guardado cujas notas serão geridas.
  final SavedProduct savedProduct;

  /// Cria uma [_NotesSection].
  ///
  /// O parâmetro [savedProduct] é obrigatório.
  const _NotesSection({required this.savedProduct});

  /// Abre a folha inferior para adicionar uma nova nota.
  void _openAddSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddNoteSheet(
        onSubmit: (text) {
          final updated = [
            ...savedProduct.notes,
            SavedProductNote(text: text, createdAt: DateTime.now()),
          ];
          ref
              .read(savedProductsProvider.notifier)
              .setNotes(savedProduct.barcode, updated);
        },
      ),
    );
  }

  /// Remove a nota na posição [index] da lista de notas do produto.
  void _removeNote(WidgetRef ref, int index) {
    final updated = [...savedProduct.notes]..removeAt(index);
    ref
        .read(savedProductsProvider.notifier)
        .setNotes(savedProduct.barcode, updated);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    return NutriCard(
      variant: NutriCardVariant.surfaceDark,
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NutriLabel(
                'NOTAS',
                color: colorScheme.onSurfaceVariant,
                variant: NutriLabelVariant.small,
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
              ),
              NutriLabel(
                'Guardado em ${_fmt(savedProduct.savedAt)}',
                color: colorScheme.onSurfaceVariant,
                variant: NutriLabelVariant.small,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (savedProduct.notes.isEmpty)
            NutriLabel(
              'Ainda não adicionaste notas a este produto.',
              color: colorScheme.onSurfaceVariant,
              variant: NutriLabelVariant.body,
            )
          else
            ...List.generate(savedProduct.notes.length, (i) {
              final note = savedProduct.notes[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          NutriLabel(
                            note.text,
                            color: colorScheme.onSurface,
                            variant: NutriLabelVariant.body,
                          ),
                          const SizedBox(height: 2),
                          NutriLabel(
                            _fmt(note.createdAt),
                            color: colorScheme.onSurfaceVariant,
                            variant: NutriLabelVariant.small,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: colorScheme.onSurfaceVariant,
                        size: 18,
                      ),
                      onPressed: () => _removeNote(ref, i),
                      tooltip: 'Remover nota',
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 8),
          NutriButton.text(
            label: 'Adicionar nota',
            fontSize: 13,
            icon: Icon(Icons.add, color: colorScheme.secondary, size: 16),
            onPressed: () => _openAddSheet(context, ref),
          ),
        ],
      ),
    );
  }

  /// Formata uma data no formato DD/MM/AAAA.
  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

/// Folha inferior para adicionar uma nova nota a um produto guardado.
///
/// Contém um campo de texto multilinha e um botão para guardar a nota.
class _AddNoteSheet extends StatefulWidget {
  /// Callback invocado quando o utilizador submete uma nota válida.
  final void Function(String text) onSubmit;

  /// Cria uma [_AddNoteSheet].
  ///
  /// O parâmetro [onSubmit] é obrigatório.
  const _AddNoteSheet({required this.onSubmit});

  @override
  State<_AddNoteSheet> createState() => _AddNoteSheetState();
}

/// Estado da [_AddNoteSheet] que gere o campo de texto e a submissão.
class _AddNoteSheetState extends State<_AddNoteSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Valida e submete a nota introduzida.
  ///
  /// Se o campo estiver vazio, exibe uma mensagem de erro.
  /// Caso contrário, fecha a folha e invoca [onSubmit].
  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      NutriFeedback.showError(context, 'Escreve algo na nota');
      return;
    }
    Navigator.of(context).pop();
    widget.onSubmit(text);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + viewInsets),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NutriLabel(
            'Nova nota',
            color: colorScheme.onSurface,
            variant: NutriLabelVariant.bodyLarge,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 12),
          NutriTextField(
            controller: _controller,
            label: 'Nota',
            hint: 'Ex. Continente 2.49€, bom para pós-treino',
            icon: Icons.note_alt_outlined,
            autofocus: true,
            maxLines: 3,
            textInputAction: TextInputAction.newline,
          ),
          const SizedBox(height: 16),
          NutriButton(label: 'Guardar Nota', onPressed: _submit),
        ],
      ),
    );
  }
}