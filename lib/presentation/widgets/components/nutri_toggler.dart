import 'package:flutter/material.dart';
import 'package:nutri_scan/presentation/widgets/components/nutri_label.dart';

/// Um widget de seleção interativo (toggle) estilizado para o ecossistema NutriScan.
///
/// Pode funcionar como um elemento de uma lista de seleção múltipla ou como um
/// interruptor de configurações isolado. Apresenta uma transição visual suave
/// baseada no estado [isSelected].
class NutriToggler extends StatelessWidget {
  /// O título principal exibido no card.
  final String title;

  /// Um texto descritivo opcional exibido logo abaixo do [title].
  final String? subtitle;

  /// Define se o componente está visualmente selecionado ou ativo.
  final bool isSelected;

  /// Callback invocado sempre que o utilizador pressiona o componente.
  final VoidCallback onTap;

  /// Construtor base. Ideal para iterações de listas, loops dinâmicos e cenários
  /// onde o estado é gerido de forma centralizada.
  ///
  /// Exemplo de uso:
  /// ```dart
  /// NutriToggler(
  ///   title: 'Criar hábitos mais saudáveis',
  ///   isSelected: _selectedObjectives.contains('habitos'),
  ///   onTap: () => _toggleObjective('habitos'),
  /// )
  /// ```
  const NutriToggler({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.subtitle,
  });

  /// Construtor nomeado que encapsula um [ValueListenableBuilder] para reagir
  /// e modificar um [ValueNotifier] de forma isolada, sem reconstruir a árvore
  /// de widgets superior.
  ///
  /// Perfeito para ecrãs de preferências independentes (ex.: SettingsScreen).
  ///
  /// Exemplo de uso:
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
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.surface : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? colorScheme.secondary : colorScheme.outline,
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
                    color: isSelected ? colorScheme.secondary : colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    NutriLabel(
                      subtitle!,
                      variant: NutriLabelVariant.small,
                      color: colorScheme.onSurfaceVariant,
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
                color: isSelected ? colorScheme.primary : colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}