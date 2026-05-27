import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/widgets/new/nutri_label.dart';

/// Themed confirm dialog. Returns `true` when confirmed, `false` otherwise
/// (including dismissed via tap-outside / back button).
///
/// [destructive] tints the confirm action in [AppColors.error] — set to false
/// for non-destructive confirmations (e.g. "Save changes?").
Future<bool> showNutriConfirmDialog(
  BuildContext context, {
  required String title,
  required String body,
  String confirmLabel = 'Apagar',
  String cancelLabel = 'Cancelar',
  bool destructive = true,
}) async {
  final res = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: NutriLabel(
        title,
        variant: NutriLabelVariant.title,
        color: AppColors.onBackground,
      ),
      content: NutriLabel(
        body,
        variant: NutriLabelVariant.body,
        color: AppColors.textMuted,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: NutriLabel(
            cancelLabel,
            variant: NutriLabelVariant.label,
            color: AppColors.textMuted,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: NutriLabel(
            confirmLabel,
            variant: NutriLabelVariant.label,
            color: destructive ? AppColors.error : AppColors.secondary,
          ),
        ),
      ],
    ),
  );
  return res ?? false;
}
