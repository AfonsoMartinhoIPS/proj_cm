import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/providers/auth_provider.dart';
import 'package:nutri_scan/presentation/providers/theme_provider.dart';
import 'package:nutri_scan/presentation/widgets/widgets_components.dart';

/// Ecrã de definições da aplicação.
///
/// Permite ao utilizador:
/// - Selecionar o tema (Sistema / Claro / Escuro).
/// - Aceder ao editor de objetivos.
/// - Navegar para os créditos.
/// - Terminar a sessão com confirmação prévia.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeMode = ref.watch(themeModeProvider).value ?? ThemeMode.system;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const NutriTopNavBar(showBackButton: true, title: 'Definições'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.lg),
          children: [
            const NutriSectionLabel('TEMA'),
            const SizedBox(height: AppSizes.sm),
            NutriCard(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
              child: Column(
                children: [
                  for (final mode in ThemeMode.values)
                    _ThemeOption(
                      mode: mode,
                      selected: themeMode == mode,
                      onTap: () => ref
                          .read(themeModeProvider.notifier)
                          .setMode(mode),
                    ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.lg),
            const NutriSectionLabel('CONTA'),
            const SizedBox(height: AppSizes.sm),
            NutriCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  NutriMenuItem(
                    icon: Icons.tune,
                    label: 'Editar objetivos',
                    onTap: () => context.push('/profile/goals'),
                  ),
                  const NutriDivider(),
                  NutriMenuItem(
                    icon: Icons.info_outline,
                    label: 'Créditos',
                    onTap: () => context.push('/credits'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.xl),
            SizedBox(
              width: double.infinity,
              child: NutriButton(
                label: 'Terminar sessão',
                onPressed: () async {
                  final ok = await showNutriConfirmDialog(
                    context,
                    title: 'Terminar sessão?',
                    body: 'Vais ter de iniciar sessão de novo.',
                    confirmLabel: 'Sair',
                  );
                  if (!ok) return;
                  await ref.read(authProvider.notifier).logout();
                  if (!context.mounted) return;
                  NutriFeedback.showInfo(context, 'Sessão terminada');
                },
              ),
            ),
            const SizedBox(height: AppSizes.lg),
          ],
        ),
      ),
    );
  }
}

/// Opção individual de tema dentro do seletor.
///
/// Exibe um ícone representativo, o nome do tema e um indicador visual
/// do estado selecionado.
class _ThemeOption extends StatelessWidget {
  /// O modo de tema que esta opção representa.
  final ThemeMode mode;

  /// Se esta opção está atualmente selecionada.
  final bool selected;

  /// Callback invocado quando o utilizador toca na opção.
  final VoidCallback onTap;

  /// Cria uma [_ThemeOption].
  ///
  /// Os parâmetros [mode], [selected] e [onTap] são obrigatórios.
  const _ThemeOption({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  /// Mapeia cada [ThemeMode] para o seu rótulo em português e ícone associado.
  static const _labels = {
    ThemeMode.system: ('Sistema', Icons.brightness_auto),
    ThemeMode.light: ('Claro', Icons.light_mode),
    ThemeMode.dark: ('Escuro', Icons.dark_mode),
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (label, icon) = _labels[mode]!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.sm,
          ),
          child: Row(
            children: [
              Icon(icon, color: colorScheme.secondary, size: 20),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: NutriLabel(
                  label,
                  variant: NutriLabelVariant.body,
                  color: colorScheme.onSurface,
                ),
              ),
              Icon(
                selected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: selected ? colorScheme.secondary : colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}