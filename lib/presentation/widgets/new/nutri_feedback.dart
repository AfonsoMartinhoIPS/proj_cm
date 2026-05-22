// lib/presentation/widgets/new/nutri_feedback.dart
import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/widgets/new/nutri_label.dart';

/// Define os tipos de feedback visual disponíveis no sistema.
enum NutriFeedbackType { success, error, info }

/// Um widget versátil para exibir mensagens de feedback (Sucesso, Erro ou Informação).
/// 
/// Pode ser utilizado diretamente na árvore de widgets através dos seus construtores
/// ou disparado globalmente como uma [SnackBar] através dos métodos estáticos.
class NutriFeedback extends StatelessWidget {
  /// A mensagem de texto a ser exibida.
  final String message;

  /// O tipo de feedback que define as cores e o ícone do widget.
  final NutriFeedbackType type;

  /// Construtor base que requer explicitamente o [message] e o [type].
  const NutriFeedback({
    super.key,
    required this.message,
    required this.type,
  });

  /// Cria um feedback visual com o estilo de sucesso.
  const NutriFeedback.success({super.key, required this.message}) : type = NutriFeedbackType.success;

  /// Cria um feedback visual com o estilo de erro.
  const NutriFeedback.error({super.key, required this.message}) : type = NutriFeedbackType.error;

  /// Cria um feedback visual com o estilo de informação.
  const NutriFeedback.info({super.key, required this.message}) : type = NutriFeedbackType.info;

  /// Exibe instantaneamente uma [SnackBar] flutuante estilizada no ecrã.
  /// 
  /// Remove automaticamente qualquer [SnackBar] ativa antes de renderizar a nova.
  static void showSnackBar(BuildContext context, String message, NutriFeedbackType type) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _getBackgroundColor(type),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        content: NutriFeedback(message: message, type: type),
      ),
    );
  }

  /// Atalho de conveniência para exibir uma [SnackBar] de erro.
  static void showError(BuildContext context, String message) {
    showSnackBar(context, message, NutriFeedbackType.error);
  }

  /// Atalho de conveniência para exibir uma [SnackBar] de sucesso.
  static void showSuccess(BuildContext context, String message) {
    showSnackBar(context, message, NutriFeedbackType.success);
  }

  /// Atalho de conveniência para exibir uma [SnackBar] de informação.
  static void showInfo(BuildContext context, String message) {
    showSnackBar(context, message, NutriFeedbackType.info);
  }

  /// Retorna a cor de fundo suavizada (com opacidade) correspondente ao [type].
  static Color _getBackgroundColor(NutriFeedbackType type) {
    switch (type) {
      case NutriFeedbackType.error:
        return AppColors.error.withValues(alpha: 0.15);
      case NutriFeedbackType.success:
        return Colors.green.withValues(alpha: 0.15);
      case NutriFeedbackType.info:
        return AppColors.primary.withValues(alpha: 0.15);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color mainColor;
    final IconData icon;

    switch (type) {
      case NutriFeedbackType.error:
        mainColor = AppColors.error;
        icon = Icons.error_outline;
        break;
      case NutriFeedbackType.success:
        mainColor = Colors.green;
        icon = Icons.check_circle_outline;
        break;
      case NutriFeedbackType.info:
        mainColor = AppColors.primary;
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