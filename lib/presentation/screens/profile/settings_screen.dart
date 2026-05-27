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
            const _SectionLabel('TEMA'),
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
            const _SectionLabel('CONTA'),
            const SizedBox(height: AppSizes.sm),
            NutriCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _MenuItem(
                    icon: Icons.tune,
                    label: 'Editar objetivos',
                    onTap: () => context.push('/profile/goals'),
                  ),
                  const _Divider(),
                  _MenuItem(
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
              child: _MenuItem(
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

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSizes.sm),
      child: NutriLabel(
        text,
        variant: NutriLabelVariant.small,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: AppColors.textMuted,
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

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.error : AppColors.onBackground;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md, vertical: AppSizes.md,
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: NutriLabel(
                  label,
                  variant: NutriLabelVariant.body,
                  color: color,
                ),
              ),
              if (!destructive)
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textMuted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: AppColors.border);
  }
}
