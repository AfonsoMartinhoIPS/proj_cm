import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';

//TODO: Rever.
class NutriButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool darkTheme;
  final String secondaryText;

  const NutriButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.darkTheme = false,
    this.secondaryText = "",
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: Material(
        color: darkTheme ? AppColors.border : AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          side: darkTheme
              ? const BorderSide(color: AppColors.secondary, width: 2.0)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: darkTheme
                      ? AppColors.secondary
                      : AppColors.onBackground,
                  fontSize: 15,
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.60,
                ),
              ),
              if (secondaryText.isNotEmpty) ...[
                Text(
                  secondaryText,
                  style: TextStyle(
                    color: darkTheme
                        ? AppColors.secondary
                        : AppColors.onBackground,
                    fontSize: 15,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.60,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
