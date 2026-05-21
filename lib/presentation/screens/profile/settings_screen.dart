import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/core/core.dart';
//import 'package:nutri_scan/presentation/widgets/new/nutri_label.dart';
import 'package:nutri_scan/presentation/widgets/new_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // NutriToggle takes a ValueNotifier so it owns its rebuild loop.
  // Each toggle gets its own notifier; values seeded with current defaults.
  final _mealReminder = ValueNotifier<bool>(true);
  final _dailySummary = ValueNotifier<bool>(true);
  final _goalAlert    = ValueNotifier<bool>(false);
  final _metricUnits  = ValueNotifier<bool>(true);
  final _darkMode     = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _mealReminder.dispose();
    _dailySummary.dispose();
    _goalAlert.dispose();
    _metricUnits.dispose();
    _darkMode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: const NutriLabel('Definições', variant: NutriLabelVariant.display,),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _sectionTitle('NOTIFICAÇÕES'),
          NutriToggle(
            title: 'Lembrete de refeição',
            subtitle: 'Alerta antes das horas das refeições',
            controller: _mealReminder,
          ),
          NutriToggle(
            title: 'Resumo diário',
            subtitle: 'Resumo às 22h00',
            controller: _dailySummary,
          ),
          NutriToggle(
            title: 'Objetivo atingido',
            subtitle: 'Notificar quando atinges a meta',
            controller: _goalAlert,
          ),
          const SizedBox(height: 25),
          _sectionTitle('PREFERÊNCIAS'),
          NutriToggle(
            title: 'Unidades métricas',
            subtitle: 'kg e cm',
            controller: _metricUnits,
          ),
          NutriToggle(
            title: 'Modo escuro',
            subtitle: 'Tema da aplicação',
            controller: _darkMode,
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, top: 10),
      child: NutriLabel(title,
              color: AppColors.textMuted, variant: NutriLabelVariant.small, fontWeight: FontWeight.bold, letterSpacing: 1.2),
    );
  }
}
