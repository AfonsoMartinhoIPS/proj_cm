import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/widgets/widgets_components.dart';
import 'package:url_launcher/url_launcher.dart';

/// Ecrã de créditos da aplicação.
///
/// Exibe informações sobre a unidade curricular, a instituição, a equipa de
/// desenvolvimento e a ligação ao repositório do projeto no GitHub. Cada
/// membro da equipa é apresentado num card com avatar, nome e número de aluno.
class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  static final _repoUrl = Uri.parse('https://github.com/AfonsoMartinhoIPS/proj_cm');

  /// Abre o repositório do projeto no browser externo via [url_launcher].
  /// Falhas (sem browser instalado, URL inválido) ficam apenas no log para
  /// não interromper a navegação do utilizador.
  Future<void> _openRepo() async {
    try {
      await launchUrl(_repoUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      logger.w('CreditsScreen: failed to open repo URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: NutriTopNavBar(showBackButton: true, title: 'Créditos'),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                const NutriIcon(size: 80, fill: true),
                const SizedBox(height: 15),
                NutriLabel.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Nutri',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: 'Scan',
                        style: TextStyle(
                          color: colorScheme.secondary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                NutriLabel(
                  'versão 1.0.0 · 2025–2026',
                  color: colorScheme.onSurfaceVariant,
                  variant: NutriLabelVariant.small,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          NutriLabel(
            'Unidade Curricular, Computação Móvel',
            color: colorScheme.onSurfaceVariant,
            variant: NutriLabelVariant.small,
          ),
          NutriLabel(
            'Instituição, Instituto Politécnico de Setúbal',
            color: colorScheme.onSurfaceVariant,
            variant: NutriLabelVariant.small,
          ),
          const SizedBox(height: 30),
          NutriLabel(
            'EQUIPA',
            color: colorScheme.onSurfaceVariant,
            variant: NutriLabelVariant.small,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
          const SizedBox(height: 15),
          _memberTile('Afonso Martinho', '202001865', 'AM', colorScheme),
          _memberTile('Daniel Pais', '202200286', 'DP', colorScheme),
          _memberTile('Fernando Ramalho', '202002203', 'FR', colorScheme),
          _memberTile('Samuel Silva', '202200315', 'SS', colorScheme),
          const SizedBox(height: 30),
          NutriButton.transparent(
            label: 'Ver Código Fonte no GitHub',
            icon: Icon(Icons.code, color: colorScheme.secondary, size: 18),
            onPressed: _openRepo,
          ),
          const SizedBox(height: 40),
          NutriLabel(
            'Feito com dedicação · IPS 2025/2026',
            textAlign: TextAlign.center,
            color: colorScheme.onSurfaceVariant,
            variant: NutriLabelVariant.small,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Constrói o card de um membro da equipa.
  ///
  /// Exibe o [name], o número de aluno [id], as [initials] num avatar
  /// circular e um botão "GitHub" cuja ação é definida por [onGitTap].
  Widget _memberTile(
    String name,
    String id,
    String initials,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: NutriCard(
        child: Row(
          children: [
            NutriCircleAvatar(initials: initials, size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NutriLabel(
                    name,
                    color: colorScheme.onSurface,
                    variant: NutriLabelVariant.body,
                    fontWeight: FontWeight.w600,
                  ),
                  NutriLabel(
                    id,
                    color: colorScheme.onSurfaceVariant,
                    variant: NutriLabelVariant.small,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}