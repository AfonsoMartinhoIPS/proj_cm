import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';

/// Standard surface card used across the app — rounded corners, bordered,
/// fills with [AppColors.surface] by default. Pick a `variant` to switch
/// to the darker surface used inside other cards.
enum NutriCardVariant { surface, surfaceDark }

class NutriCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final NutriCardVariant variant;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry? margin;

  const NutriCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSizes.md),
    this.variant = NutriCardVariant.surface,
    this.borderRadius,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = variant == NutriCardVariant.surfaceDark
        ? AppColors.surfaceDark
        : AppColors.surface;

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: borderRadius ?? BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}
