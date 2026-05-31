import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:nutri_scan/domain/entities/app_user.dart';
import 'package:nutri_scan/presentation/providers/auth_provider.dart';
import 'package:nutri_scan/presentation/widgets/widgets_components.dart';

/// Ecrã de perfil do utilizador.
///
/// Exibe os dados pessoais, os objetivos diários e um menu com acesso a
/// definições, créditos e envio de feedback.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = ref.watch(authProvider).value;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: NutriTopNavBar(showBackButton: true, title: 'Perfil'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: 8),
            _UserHeader(user: user),
            const SizedBox(height: 20),
            _GoalsSection(user: user),
            const SizedBox(height: 30),
            NutriCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  NutriMenuItem(
                    icon: Icons.settings,
                    label: 'Definições',
                    onTap: () => context.push('/settings'),
                  ),
                  const NutriDivider(),
                  NutriMenuItem(
                    icon: Icons.info_outline,
                    label: 'Créditos',
                    onTap: () => context.push('/credits'),
                  ),
                  const NutriDivider(),
                  NutriMenuItem(
                    icon: Icons.feedback_outlined,
                    label: 'Enviar Feedback',
                    onTap: () => _openFeedbackSheet(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Abre a folha inferior para envio de feedback.
  void _openFeedbackSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _FeedbackSheet(),
    );
  }
}

/// Folha inferior para envio de feedback.
///
/// Recolhe automaticamente informações do dispositivo (sistema operativo,
/// versão e modelo) e permite ao utilizador escrever uma mensagem de feedback.
class _FeedbackSheet extends StatefulWidget {
  const _FeedbackSheet();

  @override
  State<_FeedbackSheet> createState() => _FeedbackSheetState();
}

/// Estado da [_FeedbackSheet] que gere os campos de texto e a submissão.
class _FeedbackSheetState extends State<_FeedbackSheet> {
  late final TextEditingController _deviceController;
  late final TextEditingController _osVersionController;
  late final TextEditingController _modelController;
  late final TextEditingController _feedbackController;

  @override
  void initState() {
    super.initState();
    _deviceController = TextEditingController(
      text: Platform.operatingSystem == 'android' ? 'Android' : 'iOS',
    );
    _osVersionController = TextEditingController(
      text: Platform.operatingSystemVersion,
    );
    _modelController = TextEditingController();
    _feedbackController = TextEditingController();

    _fillDeviceInfo();
  }

  /// Preenche automaticamente o campo de marca/modelo com as informações do dispositivo.
  Future<void> _fillDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _modelController.text = '${androidInfo.brand} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _modelController.text = iosInfo.model;
      }
    } catch (e) {
      // O campo permanece vazio se a deteção falhar.
    }
  }

  @override
  void dispose() {
    _deviceController.dispose();
    _osVersionController.dispose();
    _modelController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  /// Submete o feedback (simulação).
  ///
  /// A lógica real de envio será implementada posteriormente.
  void _submit() {
    Navigator.of(context).pop();
    NutriFeedback.showSuccess(context, 'Feedback enviado (simulação)');
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, viewInsets + 24),
      child: SingleChildScrollView(
        reverse: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NutriLabel(
              'Enviar Feedback',
              variant: NutriLabelVariant.bodyLarge,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 16),
            NutriTextField(
              controller: _deviceController,
              label: 'Dispositivo',
              hint: 'Android / iOS',
              icon: Icons.phone_android,
            ),
            const SizedBox(height: 12),
            NutriTextField(
              controller: _osVersionController,
              label: 'Versão do sistema',
              hint: 'ex: Android 13',
              icon: Icons.system_update,
            ),
            const SizedBox(height: 12),
            NutriTextField(
              controller: _modelController,
              label: 'Marca / Modelo',
              hint: 'ex: Samsung Galaxy S22',
              icon: Icons.devices,
            ),
            const SizedBox(height: 12),
            NutriTextField(
              controller: _feedbackController,
              label: 'Feedback',
              hint: 'Descreve a tua sugestão ou problema…',
              icon: Icons.feedback_outlined,
              maxLines: 4,
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: 24),
            NutriButton(
              label: 'Enviar Feedback',
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

/// Cabeçalho do perfil com avatar, nome, email e objetivo.
class _UserHeader extends StatelessWidget {
  /// O utilizador cujos dados serão exibidos.
  final AppUser? user;

  /// Cria um [_UserHeader].
  ///
  /// O parâmetro [user] é obrigatório (pode ser `null`).
  const _UserHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return NutriCard(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: colorScheme.primary,
            child: Icon(Icons.person, color: colorScheme.onPrimary, size: 35),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NutriLabel(
                  user?.displayName ?? 'Sem nome',
                  color: colorScheme.onSurface,
                  variant: NutriLabelVariant.bodyLarge,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 2),
                NutriLabel(
                  user?.email ?? '-',
                  color: colorScheme.onSurfaceVariant,
                  variant: NutriLabelVariant.body,
                ),
                const SizedBox(height: 10),
                if (user?.objective != null)
                  NutriTag(
                    label: user!.objective!.label,
                    variant: NutriTagVariant.primary,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Secção que exibe os objetivos nutricionais diários do utilizador.
class _GoalsSection extends StatelessWidget {
  /// O utilizador cujos objetivos serão exibidos.
  final AppUser? user;

  /// Cria uma [_GoalsSection].
  ///
  /// O parâmetro [user] é obrigatório (pode ser `null`).
  const _GoalsSection({required this.user});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final goals = user?.nutritionGoals;
    return NutriCard(
      variant: NutriCardVariant.surfaceDark,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NutriLabel(
            'OBJETIVOS DIÁRIOS',
            color: colorScheme.onSurfaceVariant,
            variant: NutriLabelVariant.small,
            letterSpacing: 1.2,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _goalItem(goals?.calories.toStringAsFixed(0) ?? '-', 'kcal', colorScheme),
              _goalItem(
                '${goals?.protein.toStringAsFixed(0) ?? '-'}g',
                'proteína',
                colorScheme,
              ),
              _goalItem(
                '${user?.weight.toStringAsFixed(0) ?? '-'}kg',
                'peso atual',
                colorScheme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Constrói um item individual de objetivo (valor + unidade).
  Widget _goalItem(String value, String label, ColorScheme colorScheme) {
    return Column(
      children: [
        NutriLabel(
          value,
          color: colorScheme.secondary,
          variant: NutriLabelVariant.bodyLarge,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 4),
        NutriLabel(
          label,
          color: colorScheme.onSurfaceVariant,
          variant: NutriLabelVariant.small,
        ),
      ],
    );
  }
}