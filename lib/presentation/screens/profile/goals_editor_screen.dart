import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/domain/entities/app_user.dart';
import 'package:nutri_scan/presentation/providers/auth_provider.dart';
import 'package:nutri_scan/presentation/widgets/widgets_components.dart';

/// Ecrã de edição dos objetivos nutricionais diários.
///
/// Permite ajustar calorias, proteínas, hidratos, gordura e água.
/// A gravação é feita diretamente no documento do utilizador através
/// do [authProvider]. Os valores atuais são pré‑preenchidos a partir
/// dos dados do utilizador autenticado.
class GoalsEditorScreen extends ConsumerStatefulWidget {
  const GoalsEditorScreen({super.key});

  @override
  ConsumerState<GoalsEditorScreen> createState() => _GoalsEditorScreenState();
}

/// Estado do [GoalsEditorScreen] que gere os controladores de texto e a submissão.
class _GoalsEditorScreenState extends ConsumerState<GoalsEditorScreen> {
  late final TextEditingController _caloriesController;
  late final TextEditingController _proteinController;
  late final TextEditingController _carbsController;
  late final TextEditingController _fatController;
  late final TextEditingController _waterController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final goals = ref.read(authProvider).value?.nutritionGoals;
    _caloriesController = TextEditingController(
      text: goals?.calories.toStringAsFixed(0) ?? '',
    );
    _proteinController = TextEditingController(
      text: goals?.protein.toStringAsFixed(0) ?? '',
    );
    _carbsController = TextEditingController(
      text: goals?.carbs.toStringAsFixed(0) ?? '',
    );
    _fatController = TextEditingController(
      text: goals?.fat.toStringAsFixed(0) ?? '',
    );
    _waterController = TextEditingController(
      text: goals?.water.toStringAsFixed(0) ?? '',
    );
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _waterController.dispose();
    super.dispose();
  }

  /// Lê os valores dos campos e envia a atualização para o utilizador autenticado.
  ///
  /// Se as calorias forem inválidas (≤ 0), exibe uma mensagem de erro.
  /// Caso contrário, inicia o estado de carregamento, chama o provider e,
  /// após sucesso, fecha o ecrã.
  Future<void> _submit() async {
    final calories = double.tryParse(_caloriesController.text.trim()) ?? 0;
    final protein = double.tryParse(_proteinController.text.trim()) ?? 0;
    final carbs = double.tryParse(_carbsController.text.trim()) ?? 0;
    final fat = double.tryParse(_fatController.text.trim()) ?? 0;
    final water = double.tryParse(_waterController.text.trim()) ?? 0;

    if (calories <= 0) {
      NutriFeedback.showError(context, 'Calorias têm de ser maiores que 0');
      return;
    }

    setState(() => _saving = true);
    await ref.read(authProvider.notifier).updateGoals(
          NutritionGoals(
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            water: water,
          ),
        );
    if (!mounted) return;
    setState(() => _saving = false);
    NutriFeedback.showSuccess(context, 'Objetivos atualizados');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const NutriTopNavBar(
        showBackButton: true,
        title: 'Editar objetivos',
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.lg),
          children: [
            NutriLabel(
              'Ajusta os teus objetivos diários. As entradas históricas não vão ser alteradas.',
              variant: NutriLabelVariant.small,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSizes.lg),
            NutriCard(
              child: Column(
                children: [
                  NutriTextField(
                    controller: _caloriesController,
                    label: 'Calorias (kcal)',
                    hint: '2000',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  NutriTextField(
                    controller: _proteinController,
                    label: 'Proteína (g)',
                    hint: '150',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  NutriTextField(
                    controller: _carbsController,
                    label: 'Hidratos (g)',
                    hint: '250',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  NutriTextField(
                    controller: _fatController,
                    label: 'Gordura (g)',
                    hint: '65',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  NutriTextField(
                    controller: _waterController,
                    label: 'Água (ml)',
                    hint: '2500',
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.xl),
            NutriButton(
              label: 'Guardar',
              onPressed: _saving ? null : _submit,
              isLoading: _saving,
            ),
          ],
        ),
      ),
    );
  }
}