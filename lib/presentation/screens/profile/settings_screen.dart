import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projeto/core/theme/app_colors.dart';
import 'package:projeto/core/widgets/nutri_back_button.dart'; 
import 'package:projeto/core/widgets/nutri_toggle.dart'; 

import 'package:nutri_scan/core/theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final ValueNotifier<bool> _mealReminderController;
  late final ValueNotifier<bool> _dailySummaryController;
  late final ValueNotifier<bool> _goalAlertController;
  late final ValueNotifier<bool> _metricUnitsController;
  late final ValueNotifier<bool> _darkModeController;

  @override
  void initState() {
    super.initState();
    _mealReminderController = ValueNotifier<bool>(true);
    _dailySummaryController = ValueNotifier<bool>(true);
    _goalAlertController = ValueNotifier<bool>(false);
    _metricUnitsController = ValueNotifier<bool>(true);
    _darkModeController = ValueNotifier<bool>(true);
  }

  @override
  void dispose() {
    _mealReminderController.dispose();
    _dailySummaryController.dispose();
    _goalAlertController.dispose();
    _metricUnitsController.dispose();
    _darkModeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Center(
          child: NutriBackButton(onPressed: () => context.pop()),
        ),
        title: const Text(
          'Definições',
          style: TextStyle(color: AppColors.onBackground, fontSize: 18),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 10),
          _sectionTitle('NOTIFICAÇÕES'),
          
          NutriToggle(
            title: 'Lembrete de refeição',
            subtitle: 'Alerta antes das horas das refeições',
            controller: _mealReminderController,
          ),
          NutriToggle(
            title: 'Resumo diário',
            subtitle: 'Resumo às 22h00',
            controller: _dailySummaryController,
          ),
          NutriToggle(
            title: 'Objetivo atingido',
            subtitle: 'Notificar quando atinges a meta',
            controller: _goalAlertController,
          ),

          const SizedBox(height: 35),
          _sectionTitle('PREFERÊNCIAS'),
          
          NutriToggle(
            title: 'Unidades métricas',
            subtitle: 'kg e cm',
            controller: _metricUnitsController,
          ),
          NutriToggle(
            title: 'Modo escuro',
            subtitle: 'Tema da aplicação',
            controller: _darkModeController,
          ),
        ],
      ),
    );
  }

  // criar um widget para isto?
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}