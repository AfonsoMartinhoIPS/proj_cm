import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:projeto/core/theme/app_colors.dart';

class ObjectivesScreen extends StatefulWidget {
  const ObjectivesScreen({super.key});

  @override
  State<ObjectivesScreen> createState() => _ObjectivesScreenState();
}

class _ObjectivesScreenState extends State<ObjectivesScreen> {
  String _objetivoPeso = 'Perder';
  final Set<String> _outrosObjetivos = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
        title: _stepIndicator('2 / 4'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text('Quais os teus\nobjetivos?',
                  style: TextStyle(color: AppColors.onBackground, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text('Usamos estas informações para elaborar recomendações personalizadas.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
              const SizedBox(height: 30),
              const Text('PESO',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 10),
              _buildWeightSelector(),
              const SizedBox(height: 30),
              const Text('OUTROS',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 15),
              _buildOptionTile('Melhorar desempenho desportivo'),
              _buildOptionTile('Criar hábitos mais saudáveis'),
              _buildOptionTile('Prevenir doenças relacionadas ao estilo de vida'),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => context.push('/onboarding/calculation'),
                child: const Text('Próximo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeightSelector() {
    return Container(
      decoration: BoxDecoration(color: AppColors.surfaceDark, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: ['Perder', 'Manter', 'Ganhar'].map((option) {
          final selected = _objetivoPeso == option;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _objetivoPeso = option),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(option,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: selected ? AppColors.onBackground : AppColors.textMuted,
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    )),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOptionTile(String title) {
    final isSelected = _outrosObjetivos.contains(title);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _outrosObjetivos.remove(title);
          } else {
            _outrosObjetivos.add(title);
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isSelected ? AppColors.secondary : AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(title,
                  style: TextStyle(
                    color: isSelected ? AppColors.secondary : AppColors.onBackground,
                    fontSize: 14,
                  )),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _stepIndicator(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: const TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.bold)),
  );
}
