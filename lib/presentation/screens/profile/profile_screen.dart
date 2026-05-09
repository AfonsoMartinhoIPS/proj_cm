import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:projeto/core/theme/app_colors.dart';
import 'package:projeto/domain/entities/app_user.dart';
import 'package:projeto/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;
    

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            _UserHeader(user: user, onLogout: () => ref.read(authProvider.notifier).logout()),
            const SizedBox(height: 20),
            _GoalsSection(user: user),
            const SizedBox(height: 30),
            _menuButton('Definições', onPressed: () => context.push('/settings')),
            const SizedBox(height: 15),
            _menuButton('Créditos', onPressed: () => context.push('/credits')),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _menuButton(String label, {required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
    );
  }
}

class _UserHeader extends StatelessWidget {
  const _UserHeader({required this.user, required this.onLogout});

  final AppUser? user;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person, color: AppColors.onBackground, size: 35),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user?.displayName ?? 'Sem nome',
                    style: const TextStyle(color: AppColors.onBackground, fontSize: 18, fontWeight: FontWeight.bold)),
                Text(user?.email ?? '—', style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                const SizedBox(height: 8),
                if (user?.objective != null)
                  _tag(user!.objective!.label),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: onLogout,
                  child: const Text('Logout', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(color: AppColors.onBackground, fontSize: 10)),
    );
  }
}

class _GoalsSection extends StatelessWidget {
  const _GoalsSection({required this.user});

  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    final goals = user?.nutritionGoals;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('OBJETIVOS DIÁRIOS',
              style: TextStyle(color: AppColors.textMuted, fontSize: 11, letterSpacing: 1.2)),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _goalItem(goals?.calories.toStringAsFixed(0) ?? '—', 'kcal'),
              _goalItem('${goals?.protein.toStringAsFixed(0) ?? '—'}g', 'proteína'),
              _goalItem('${user?.weight.toStringAsFixed(0) ?? '—'}kg', 'peso atual'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _goalItem(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(color: AppColors.secondary, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
      ],
    );
  }
}
