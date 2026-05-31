import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/providers/auth_provider.dart';
import 'package:nutri_scan/presentation/providers/notification_provider.dart';
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
            const NutriSectionLabel('NOTIFICAÇÕES'),
            const SizedBox(height: AppSizes.sm),
            const _NotificationSection(),

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

/// Daily-reminder controls: enable toggle + time picker.
///
/// Both rows persist via [notificationPrefsProvider] → NotificationCoordinator.
/// Toggling on triggers the OS permission prompt; denial reverts the switch
/// and shows a snackbar. The time row is only interactive while enabled so
/// users don't accidentally tweak a schedule that won't fire.
class _NotificationSection extends ConsumerWidget {
  const _NotificationSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(notificationPrefsProvider);
    final prefs = async.value;

    return NutriCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          SwitchListTile(
            title: const NutriLabel(
              'Lembrete diário',
              variant: NutriLabelVariant.body,
              color: AppColors.onBackground,
            ),
            subtitle: const NutriLabel(
              'Resumo do progresso do dia',
              variant: NutriLabelVariant.small,
              color: AppColors.textMuted,
            ),
            value: prefs?.enabled ?? false,
            onChanged: prefs == null
                ? null
                : (v) async {
                    final ok = await ref
                        .read(notificationPrefsProvider.notifier)
                        .setEnabled(v);
                    if (!context.mounted) return;
                    if (v && !ok) {
                      NutriFeedback.showError(
                        context,
                        'Permissão de notificações recusada',
                      );
                    } else {
                      NutriFeedback.showInfo(
                        context,
                        v
                            ? 'Lembretes ativados'
                            : 'Lembretes desativados',
                      );
                    }
                  },
          ),
          const NutriDivider(),
          NutriMenuItem(
            icon: Icons.access_time,
            label: prefs == null
                ? 'Hora do lembrete'
                : 'Hora do lembrete · ${prefs.time.format(context)}',
            onTap: prefs == null || !prefs.enabled
                ? () => NutriFeedback.showInfo(
                      context,
                      'Ativa o lembrete primeiro',
                    )
                : () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: prefs.time,
                    );
                    if (picked == null || !context.mounted) return;
                    await ref
                        .read(notificationPrefsProvider.notifier)
                        .setTime(picked);
                    if (!context.mounted) return;
                    NutriFeedback.showSuccess(
                      context,
                      'Hora atualizada para ${picked.format(context)}',
                    );
                  },
          ),
        ],
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
