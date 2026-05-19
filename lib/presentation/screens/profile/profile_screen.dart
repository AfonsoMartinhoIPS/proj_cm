import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:nutri_scan/core/theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildUserHeader(),
                  const SizedBox(height: 20),
                  _buildGoalsSection(),
                  const SizedBox(height: 30),
                  _menuButton('Definições', onPressed: () => context.push('/settings')),
                  const SizedBox(height: 15),
                  _menuButton('Créditos', onPressed: () => context.push('/credits')),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
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
                const Text('Ana Ferreira',
                    style: TextStyle(color: AppColors.onBackground, fontSize: 18, fontWeight: FontWeight.bold)),
                const Text('ana@email.com', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _tag('Perder Peso'),
                    const SizedBox(width: 8),
                    _tag('Editar Perfil', isOutlined: true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String text, {bool isOutlined = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOutlined ? Colors.transparent : AppColors.primary,
        border: isOutlined ? Border.all(color: AppColors.border) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(color: AppColors.onBackground, fontSize: 10)),
    );
  }

  Widget _buildGoalsSection() {
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
              _goalItem('1 580', 'kcal'),
              _goalItem('125g', 'proteína'),
              _goalItem('62kg', 'peso atual'),
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

  Widget _menuButton(String label, {required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
    );
  }
}
