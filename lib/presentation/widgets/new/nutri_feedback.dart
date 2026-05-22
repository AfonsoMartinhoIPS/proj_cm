// lib/presentation/widgets/new/nutri_feedback.dart
import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/widgets/new/nutri_label.dart';

enum NutriFeedbackType { success, error, info }

class NutriFeedback extends StatelessWidget {
  final String message;
  final NutriFeedbackType type;

  const NutriFeedback({
    super.key,
    required this.message,
    required this.type,
  });

  // 🚀 Constructores Nomeados de Conveniência (Se quiseres instanciar o widget diretamente na UI)
  const NutriFeedback.success({super.key, required this.message}) : type = NutriFeedbackType.success;
  const NutriFeedback.error({super.key, required this.message}) : type = NutriFeedbackType.error;
  const NutriFeedback.info({super.key, required this.message}) : type = NutriFeedbackType.info;

  // --- Métodos Estáticos para Disparar Globalmente ---

  /// Dispara um feedback visual instantâneo baseado no tipo passado.
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

  // Atalhos diretos:
  
  static void showError(BuildContext context, String message) {
    showSnackBar(context, message, NutriFeedbackType.error);
  }

  static void showSuccess(BuildContext context, String message) {
    showSnackBar(context, message, NutriFeedbackType.success);
  }

  static void showInfo(BuildContext context, String message) {
    showSnackBar(context, message, NutriFeedbackType.info);
  }

  // --------------------------------------------------

  static Color _getBackgroundColor(NutriFeedbackType type) {
    switch (type) {
      case NutriFeedbackType.error:
        return AppColors.error.withOpacity(0.15);
      case NutriFeedbackType.success:
        return Colors.green.withOpacity(0.15);
      case NutriFeedbackType.info:
        return AppColors.primary.withOpacity(0.15);
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