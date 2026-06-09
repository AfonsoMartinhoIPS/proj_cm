import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/domain/entities/nutrition_log.dart';
import 'package:nutri_scan/presentation/providers/nutrition_log_provider.dart';
import 'package:nutri_scan/presentation/widgets/widgets_components.dart';

/// Filtra uma lista de logs de acordo com um intervalo temporal.
///
/// - Se [month] for fornecido, devolve apenas os dias desse mês/ano.
/// - Caso contrário, se [daysBack] for fornecido, usa uma janela rolante
///   que termina em "hoje" com a duração indicada.
/// - Se ambos forem `null`, devolve a lista completa.
List<NutritionLog> filterLogs(
  List<NutritionLog> logs, {
  int? daysBack,
  DateTime? month,
}) {
  if (month != null) {
    return logs.where((l) {
      final d = DateTime.tryParse(l.date);
      return d != null && d.year == month.year && d.month == month.month;
    }).toList();
  }
  if (daysBack != null) {
    final today = DateTime.now();
    final cutoff = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: daysBack - 1));
    return logs.where((l) {
      final d = DateTime.tryParse(l.date);
      if (d == null) return false;
      return !d.isBefore(cutoff);
    }).toList();
  }
  return logs; // modo "Tudo"
}

/// Diálogo de confirmação + eliminação de um dia.
///
/// Mostra um diálogo de confirmação e, se o utilizador aceitar,
/// chama [nutritionLogsProvider.notifier.deleteDay]. No fim, apresenta
/// um feedback. Retorna `true` se o dia foi eliminado.
Future<bool> confirmDeleteDay(
  BuildContext context,
  NutritionLog log,
  WidgetRef ref,
) async {
  final ok = await showNutriConfirmDialog(
    context,
    title: 'Apagar dia?',
    body: 'Vai remover ${log.entries.length} '
        '${log.entries.length == 1 ? 'refeição' : 'refeições'} '
        'registadas em ${formatRelativeDate(log.date)}.',
  );
  if (!ok) return false;
  await ref.read(nutritionLogsProvider.notifier).deleteDay(log.date);
  if (context.mounted) {
    NutriFeedback.showInfo(context, 'Dia removido');
  }
  return true;
}

/// Configura um listener de scroll que dispara [loadMore] quando o
/// utilizador está perto do fim da lista, **apenas se [isActive] retornar
/// `true`** (ex.: modo "Tudo").
///
/// O estado `_loadingMore` deve ser gerido por quem chama, tipicamente
/// dentro do próprio `loadMore`.
void setupScrollPagination({
  required ScrollController controller,
  required bool Function() isActive,
  required VoidCallback onLoadMore,
}) {
  controller.addListener(() {
    if (!controller.hasClients) return;
    if (!isActive()) return;
    final pos = controller.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      onLoadMore();
    }
  });
}