import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/widgets/new_widgets.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: const Text('Créditos'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.restaurant_menu, color: AppColors.onBackground, size: 40),
                ),
                const SizedBox(height: 15),
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(text: 'Nutri',
                          style: TextStyle(color: AppColors.onBackground, fontSize: 24, fontWeight: FontWeight.bold)),
                      TextSpan(text: 'Scan',
                          style: TextStyle(color: AppColors.secondary, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const Text('versão 1.0.0 · 2025–2026',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 40),
          const Text('Unidade Curricular, Computação Móvel',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          const Text('Instituição, Instituto Politécnico de Setúbal',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          const SizedBox(height: 30),
          const NutriLabel.section('Equipa'),
          const SizedBox(height: 15),
          
          // Adicionei callbacks fictícios (ligar a um package como url_launcher mais tarde)
          _memberTile('Afonso Martinho', '202001865', 'AM', onGitTap: () {}),
          _memberTile('Daniel Pais',     '202200286', 'DP', onGitTap: () {}),
          _memberTile('Fernando Ramalho','202002203', 'FR', onGitTap: () {}),
          _memberTile('Samuel Silva',    '202200315', 'SS', onGitTap: () {}),
          
          const SizedBox(height: 30),
          
          NutriButton.transparent(
            label: 'Ver Código Fonte no GitHub',
            icon: const Icon(Icons.code, color: AppColors.secondary, size: 18),
            onPressed: () {
              // TODO: Abrir o link do repositório da equipa no GitHub
            },
          ),
          
          const SizedBox(height: 40),
          const Text('Feito com dedicação · IPS 2025/2026',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _memberTile(String name, String id, String initials, {required VoidCallback onGitTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.surface,
          child: Text(initials,
              style: const TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        title: Text(name, style: const TextStyle(color: AppColors.onBackground, fontSize: 14)),
        subtitle: Text(id, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        // Oportunidade 1: Botão de texto minimalista à direita em cada linha da equipa
        trailing: NutriButton.text(
          label: 'GitHub',
          fontSize: 11,
          onPressed: onGitTap,
        ),
      ),
    );
  }
}