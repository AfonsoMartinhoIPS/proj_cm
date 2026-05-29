import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/providers/auth_provider.dart';
import 'package:nutri_scan/presentation/providers/theme_provider.dart';
import 'package:nutri_scan/presentation/widgets/new_widgets.dart';

/// App settings: theme picker, account actions (edit goals, logout), about.
///
/// Sections are flat - no nested screens; everything fits one scroll view.
/// Logout requires confirm because it kills the session; router redirect
/// handles the bounce to `/welcome` when authProvider emits null.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider).value ?? ThemeMode.system;

    return Scaffold(
      backgroundColor: AppColors.background,
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

            const SizedBox(height: AppSizes.lg),
            NutriCard(
              padding: EdgeInsets.zero,
              child: NutriMenuItem(
                icon: Icons.logout,
                label: 'Logout',
                destructive: true,
                onTap: () async {
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
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final ThemeMode mode;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  static const _labels = {
    ThemeMode.system: ('Sistema', Icons.brightness_auto),
    ThemeMode.light: ('Claro', Icons.light_mode),
    ThemeMode.dark: ('Escuro', Icons.dark_mode),
  };

  @override
  Widget build(BuildContext context) {
    final (label, icon) = _labels[mode]!;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md, vertical: AppSizes.sm,
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.secondary, size: 20),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: NutriLabel(
                  label,
                  variant: NutriLabelVariant.body,
                  color: AppColors.onBackground,
                ),
              ),
              Icon(
                selected
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: selected ? AppColors.secondary : AppColors.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
