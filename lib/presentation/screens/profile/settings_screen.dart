import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projeto/core/theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _mealReminder = true;
  bool _dailySummary  = true;
  bool _goalAlert     = false;
  bool _metricUnits   = true;
  bool _darkMode      = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: const Text('Definições'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _sectionTitle('NOTIFICAÇÕES'),
          _settingTile('Lembrete de refeição', 'Alerta antes das horas das refeições',
              _mealReminder, (v) => setState(() => _mealReminder = v)),
          _settingTile('Resumo diário', 'Resumo às 22h00',
              _dailySummary, (v) => setState(() => _dailySummary = v)),
          _settingTile('Objetivo atingido', 'Notificar quando atinges a meta',
              _goalAlert, (v) => setState(() => _goalAlert = v)),
          const SizedBox(height: 25),
          _sectionTitle('PREFERÊNCIAS'),
          _settingTile('Unidades métricas', 'kg e cm',
              _metricUnits, (v) => setState(() => _metricUnits = v)),
          _settingTile('Modo escuro', 'Tema da aplicação',
              _darkMode, (v) => setState(() => _darkMode = v)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, top: 10),
      child: Text(title,
          style: const TextStyle(
              color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
    );
  }

  Widget _settingTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        title: Text(title, style: const TextStyle(color: AppColors.onBackground, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        trailing: Switch(value: value, onChanged: onChanged),
      ),
    );
  }
}
