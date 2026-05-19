import 'package:flutter/material.dart';
import 'package:nutri_scan/core/theme/app_colors.dart';

/// Settings-row toggle. Title + subtitle on the left, Switch on the right.
/// Caller owns a [ValueNotifier<bool>] so the widget stays stateless.
class NutriToggle extends StatelessWidget {
  final String title;
  final String subtitle;
  final ValueNotifier<bool> controller;

  const NutriToggle({
    super.key,
    required this.title,
    required this.subtitle,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: controller,
      builder: (context, currentValue, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.onBackground,
                        fontSize: 14,
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: currentValue,
                  onChanged: (newValue) => controller.value = newValue,
                  activeThumbColor: AppColors.onBackground,
                  activeTrackColor: AppColors.primary,
                  inactiveThumbColor: AppColors.textMuted,
                  inactiveTrackColor: AppColors.surfaceDark,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
