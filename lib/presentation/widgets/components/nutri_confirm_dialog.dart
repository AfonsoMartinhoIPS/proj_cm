import 'package:flutter/material.dart';
import 'package:nutri_scan/presentation/widgets/components/nutri_label.dart';

/// Exibe um diálogo de confirmação temático e retorna a decisão do utilizador.
///
/// Mostra um [AlertDialog] com um título, corpo, e dois botões de ação.
/// Devolve `true` se o utilizador confirmar, `false` se cancelar ou fechar
/// o diálogo (tocar fora ou premir o botão de retroceder).
///
/// Por predefinição o botão de confirmação é destrutivo (cor de erro).
/// Passe `destructive: false` para confirmações não‑destrutivas (ex.: "Guardar alterações?").
Future<bool> showNutriConfirmDialog(
  BuildContext context, {
  /// Título do diálogo.
  required String title,

  /// Texto descritivo exibido no corpo do diálogo.
  required String body,

  /// Rótulo do botão de confirmação.
  ///
  /// O valor padrão é 'Apagar'.
  String confirmLabel = 'Apagar',

  /// Rótulo do botão de cancelamento.
  ///
  /// O valor padrão é 'Cancelar'.
  String cancelLabel = 'Cancelar',

  /// Se `true` (padrão), o botão de confirmação utiliza a cor de erro do tema.
  ///
  /// Defina como `false` para ações não‑destrutivas (ex.: confirmar uma gravação).
  bool destructive = true,
}) async {
  final colorScheme = Theme.of(context).colorScheme;

  final res = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: colorScheme.surface,
      title: NutriLabel(
        title,
        variant: NutriLabelVariant.title,
        color: colorScheme.onSurface,
      ),
      content: NutriLabel(
        body,
        variant: NutriLabelVariant.body,
        color: colorScheme.onSurfaceVariant,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: NutriLabel(
            cancelLabel,
            variant: NutriLabelVariant.label,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: NutriLabel(
            confirmLabel,
            variant: NutriLabelVariant.label,
            color: destructive ? colorScheme.error : colorScheme.secondary,
          ),
        ),
      ],
    ),
  );
  return res ?? false;
}