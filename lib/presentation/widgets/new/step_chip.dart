import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';

/// Small pill-shaped chip used in onboarding AppBar titles, e.g. "2 / 4".
/// Centralises what was duplicated as `_stepIndicator(...)` in four screens.
class StepChip extends StatelessWidget {
  final String label;

  const StepChip(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.secondary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
