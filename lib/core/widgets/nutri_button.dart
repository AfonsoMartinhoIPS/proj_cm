import 'package:flutter/material.dart';
import 'package:projeto/core/theme/app_colors.dart';
import 'package:projeto/core/constants/app_sizes.dart';

class NutriButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const NutriButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, 
      height: 45, 
      child: Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.onBackground,
                fontSize: 12, 
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w700,
                letterSpacing: 0.60,
              ),
            ),
          ),
        ),
      ),
    );
  }
}