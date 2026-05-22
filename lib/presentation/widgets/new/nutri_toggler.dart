import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/widgets/new/nutri_label.dart';

/// Um widget de seleção interativo (toggle) estilizado para o ecossistema NutriScan.
///
/// O [NutriToggler] pode funcionar como um elemento de uma lista de seleção múltipla
/// ou como um interruptor de configurações isolado. Apresenta uma transição visual suave
/// baseada no estado [isSelected].
/// 
/// 
/// * [title] O rótulo da definição.
/// * [subtitle] A descrição opcional da funcionalidade.
/// * [isSelected] Define se o componente está visualmente selecionado ou ativo.
/// * [onTap] Callback invocado sempre que o utilizador pressiona o componente.
///
/// ### Exemplo de Uso Padrão (State Management clássico / Listas):
/// ```dart
/// NutriToggler(
///   title: 'Criar hábitos mais saudáveis',
///   isSelected: _selectedObjectives.contains('habitos'),
///   onTap: () => _toggleObjective('habitos'),
/// )
/// ```
///

class NutriToggler extends StatelessWidget {
  /// O título principal exibido no card.
  final String title;

  /// Um texto descritivo opcional exibido logo abaixo do [title].
  final String? subtitle;

  /// Define se o componente está visualmente selecionado ou ativo.
  final bool isSelected;

  /// Callback invocado sempre que o utilizador pressiona o componente.
  final VoidCallback onTap;

  /// Construtor Base: Ideal para iterações de listas, loops dinâmicos e cenários
  /// onde o estado é gerido de forma centralizada (ex: ObjectivesScreen com setState ou Riverpod).
  const NutriToggler({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.subtitle,
  });

  /// Construtor Nomeado: Encapsula um [ValueListenableBuilder] para reagir e modificar
  /// um [ValueNotifier] de forma isolada, sem reconstruir a árvore de widgets superior.
  ///
  /// Perfeito para ecrãs de preferências independentes (ex: SettingsScreen).
  ///
  /// * [title] O rótulo da definição.
  /// * [subtitle] A descrição opcional da funcionalidade.
  /// * [controller] O [ValueNotifier] que guarda e controla o estado do toggle.
  ///
  /// ### Exemplo de Uso:
  /// ```dart
  /// NutriToggler.notifier(
  ///   title: 'Modo escuro',
  ///   subtitle: 'Tema visual da aplicação',
  ///   controller: _darkModeNotifier,
  /// )
  /// ```

  static Widget notifier({
    Key? key,
    required String title,
    String? subtitle,
    required ValueNotifier<bool> controller,
  }) {
    return ValueListenableBuilder<bool>(
      valueListenable: controller,
      builder: (context, selected, _) {
        return NutriToggler(
          key: key,
          title: title,
          subtitle: subtitle,
          isSelected: selected,
          onTap: () => controller.value = !controller.value,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? AppColors.secondary : AppColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NutriLabel(
                    title,
                    variant: NutriLabelVariant.body,
                    color: isSelected
                        ? AppColors.secondary
                        : AppColors.onBackground,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    NutriLabel(
                      subtitle!,
                      variant: NutriLabelVariant.small,
                      color: AppColors.textMuted,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                key: ValueKey<bool>(isSelected),
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
