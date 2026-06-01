import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/core/debug/debug_seeder.dart';
import 'package:nutri_scan/presentation/providers/auth_provider.dart';
import 'package:nutri_scan/presentation/providers/notification_provider.dart';
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

            if (kDebugMode) ...[
              const SizedBox(height: AppSizes.lg),
              const NutriSectionLabel('DEBUG'),
              const SizedBox(height: AppSizes.sm),
              const _DebugSection(),
            ],

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
    final colorScheme = Theme.of(context).colorScheme;
    final async = ref.watch(notificationPrefsProvider);
    final prefs = async.value;

    return NutriCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          SwitchListTile(
            title: NutriLabel(
              'Lembrete diário',
              variant: NutriLabelVariant.body,
              color: colorScheme.onSurface,
            ),
            subtitle: NutriLabel(
              'Resumo do progresso do dia',
              variant: NutriLabelVariant.small,
              color: colorScheme.onSurfaceVariant,
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
                        v ? 'Lembretes ativados' : 'Lembretes desativados',
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

/// Debug-only stress-test controls. Rendered behind `kDebugMode` so it
/// never ships in release. Seeds Firestore with fake products + meal
/// entries via [DebugSeeder]; wipes them in one tap.
class _DebugSection extends ConsumerWidget {
  const _DebugSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;
    return NutriCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          NutriMenuItem(
            icon: Icons.dataset,
            label: 'Seed (50 produtos + 100 refeições)',
            onTap: user == null
                ? () =>
                    NutriFeedback.showError(context, 'Necessita sessão ativa')
                : () async {
                    NutriFeedback.showInfo(context, 'A criar dados…');
                    final msg = await DebugSeeder.seed(user: user);
                    if (!context.mounted) return;
                    NutriFeedback.showSuccess(context, msg);
                    ref.invalidate(authProvider);
                  },
          ),
          const NutriDivider(),
          NutriMenuItem(
            icon: Icons.delete_sweep,
            label: 'Wipe dados de teste',
            destructive: true,
            onTap: user == null
                ? () =>
                    NutriFeedback.showError(context, 'Necessita sessão ativa')
                : () async {
                    NutriFeedback.showInfo(context, 'A apagar…');
                    final msg = await DebugSeeder.wipe(user: user);
                    if (!context.mounted) return;
                    NutriFeedback.showSuccess(context, msg);
                    ref.invalidate(authProvider);
                  },
          ),
        ],
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