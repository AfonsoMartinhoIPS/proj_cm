import 'package:flutter/material.dart';
import 'package:nutri_scan/presentation/widgets/components/nutri_label.dart';

/// Tipos de feedback visual suportados pelo sistema.
enum NutriFeedbackType {
  /// Indica uma operação bem‑sucedida (verde).
  success,

  /// Indica um erro ou falha (vermelho).
  error,

  /// Indica uma mensagem informativa (cor primária).
  info,
}

/// Widget versátil para exibir mensagens de feedback (sucesso, erro ou informação).
///
/// Pode ser usado diretamente na árvore de widgets ou através dos atalhos
/// estáticos que disparam uma [SnackBar] estilizada.
class NutriFeedback extends StatelessWidget {
  /// A mensagem de texto exibida.
  final String message;

  /// O tipo de feedback que define a cor e o ícone do widget.
  final NutriFeedbackType type;

  /// Cria um [NutriFeedback] com o [message] e [type] especificados.
  const NutriFeedback({
    super.key,
    required this.message,
    required this.type,
  });

  /// Cria um feedback visual de sucesso.
  const NutriFeedback.success({super.key, required this.message})
      : type = NutriFeedbackType.success;

  /// Cria um feedback visual de erro.
  const NutriFeedback.error({super.key, required this.message})
      : type = NutriFeedbackType.error;

  /// Cria um feedback visual informativo.
  const NutriFeedback.info({super.key, required this.message})
      : type = NutriFeedbackType.info;

  /// Exibe uma [SnackBar] flutuante estilizada.
  ///
  /// Remove automaticamente qualquer snackbar ativa antes de mostrar a nova.
  static void showSnackBar(
      BuildContext context, String message, NutriFeedbackType type) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _getBackgroundColor(context, type),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        content: NutriFeedback(message: message, type: type),
      ),
    );
  }

  /// Atalho para exibir uma [SnackBar] de erro.
  static void showError(BuildContext context, String message) {
    showSnackBar(context, message, NutriFeedbackType.error);
  }

  /// Atalho para exibir uma [SnackBar] de sucesso.
  static void showSuccess(BuildContext context, String message) {
    showSnackBar(context, message, NutriFeedbackType.success);
  }

  /// Atalho para exibir uma [SnackBar] informativa.
  static void showInfo(BuildContext context, String message) {
    showSnackBar(context, message, NutriFeedbackType.info);
  }

  /// Cor de fundo suavizada para a snackbar, de acordo com o [type].
  static Color _getBackgroundColor(BuildContext context, NutriFeedbackType type) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (type) {
      case NutriFeedbackType.error:
        return colorScheme.error.withValues(alpha: 0.15);
      case NutriFeedbackType.success:
        return Colors.green.withValues(alpha: 0.15);
      case NutriFeedbackType.info:
        return colorScheme.primary.withValues(alpha: 0.15);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color mainColor;
    final IconData icon;

    switch (type) {
      case NutriFeedbackType.error:
        mainColor = colorScheme.error;
        icon = Icons.error_outline;
        break;
      case NutriFeedbackType.success:
        mainColor = Colors.green;
        icon = Icons.check_circle_outline;
        break;
      case NutriFeedbackType.info:
        mainColor = colorScheme.primary;
        icon = Icons.info_outline;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: mainColor, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: NutriLabel(
            message,
            variant: NutriLabelVariant.small,
            color: mainColor,
          ),
        ),
      ],
    );
  }
}