import 'package:flutter/material.dart';
import 'package:nutri_scan/domain/entities/meal_entry.dart';
import 'package:nutri_scan/presentation/widgets/widgets_components.dart';

/// Secção superior do [AddMealScreen] com a informação genérica da refeição.
///
/// Permite ao utilizador escolher o tipo de refeição (pequeno‑almoço, almoço,
/// jantar ou snack) e a data em que foi consumida. Estes dados não dependem
/// do produto selecionado e são guardados diretamente no estado do ecrã pai.
class AddMealGeneralInfo extends StatelessWidget {
  /// O tipo de refeição atualmente selecionado.
  final MealType mealType;

  /// A data em que a refeição foi (ou será) consumida.
  ///
  /// Por defeito, no ecrã pai, é inicializada com a data atual.
  final DateTime date;

  /// Callback invocado quando o utilizador seleciona um tipo de refeição
  /// diferente.
  final ValueChanged<MealType> onMealTypeChanged;

  /// Callback invocado quando o utilizador escolhe uma nova data no seletor.
  final ValueChanged<DateTime> onDateChanged;

  /// Cria um [AddMealGeneralInfo].
  ///
  /// Todos os parâmetros são obrigatórios.
  const AddMealGeneralInfo({
    super.key,
    required this.mealType,
    required this.date,
    required this.onMealTypeChanged,
    required this.onDateChanged,
  });

  /// Abre o seletor de data nativo.
  ///
  /// A data está limitada aos últimos 365 dias, permitindo registar refeições
  /// passadas mas impedindo datas futuras.
  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) onDateChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NutriLabel(
          'TIPO DE REFEIÇÃO',
          variant: NutriLabelVariant.small,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 8),
        NutriChipSelector(
          items: MealType.values,
          selected: mealType,
          onChanged: onMealTypeChanged,
          label: (mealType) => mealType.label,
        ),
        const SizedBox(height: 20),
        NutriLabel(
          'DATA',
          variant: NutriLabelVariant.small,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 8),
        NutriDateField(date: date, onTap: () => _pickDate(context)),
      ],
    );
  }
}