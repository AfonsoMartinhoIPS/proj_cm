import 'package:flutter/material.dart';

import 'package:nutri_scan/core/theme/app_colors.dart';

//TODO: Rever.
class AppStepIndicator extends StatelessWidget {
  final String title;
  final bool isDone;

  const AppStepIndicator({
    super.key,
    required this.title,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isDone ? AppColors.secondary : AppColors.border,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDone ? AppColors.onBackground : AppColors.textMuted,
                  )),
        ],
      ),
    );
  }
}