import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/domain/entities/nutrition_log.dart';
import 'package:nutri_scan/presentation/screens/meals/widgets/day_summary_card.dart';
import 'package:nutri_scan/presentation/widgets/widgets_components.dart';

/// Timeline plana de refeições — uma `DaySummaryCard` por dia, ordenadas
/// do mais recente para o mais antigo.
///
/// Filtragem por janela temporal é feita pelo chamador (chips do
/// `MealsScreen`); aqui só ordenamos + filtramos dias sem entradas.
/// Cada cartão é compacto (data relativa + kcal + nº entradas + %
/// objetivo) e abre o detalhe do dia ao toque, com botão de apagar
/// inline para limpar registos antigos.
class MealsTimeline extends StatelessWidget {
  final List<NutritionLog> logs;

  /// Toca no cartão → abrir detalhe do dia (`/meals/day/:date`).
  final void Function(NutritionLog log) onDayTap;

  /// Toca no ícone de apagar → invocado pelo chamador para confirmar
  /// e remover o dia via `nutritionLogsProvider.deleteDay`.
  final void Function(NutritionLog log) onDayDelete;

  const MealsTimeline({
    super.key,
    required this.logs,
    required this.onDayTap,
    required this.onDayDelete,
  });

  @override
  Widget build(BuildContext context) {
    final withEntries = [
      for (final l in logs) if (l.entries.isNotEmpty) l,
    ]..sort((a, b) => b.date.compareTo(a.date));

    if (withEntries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSizes.xl),
        child: NutriEmptyState(
          icon: Icons.restaurant_outlined,
          title: 'Sem refeições registadas',
          subtitle: 'Toca em + para começar a registar.',
        ),
      );
    }

    return Column(
      children: [
        for (final log in withEntries)
          DaySummaryCard(
            log: log,
            onTap: () => onDayTap(log),
            onDelete: () => onDayDelete(log),
          ),
      ],
    );
  }
}
