import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';

/// Placeholder animado com shimmer para carregamento.
///
/// Mostra um efeito de brilho animado para indicar conteúdo em carregamento.
class NutriSkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const NutriSkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<NutriSkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<NutriSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(AppSizes.radiusSm),
        color: AppColors.surfaceDark,
      ),
      child: ShaderMask(
        shaderCallback: (bounds) {
          return LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppColors.surfaceDark,
              AppColors.surface,
              AppColors.surfaceDark,
            ],
            stops: [
              _controller.value - 0.3,
              _controller.value,
              _controller.value + 0.3,
            ].map((e) => e.clamp(0, 1).toDouble()).toList(),
          ).createShader(bounds);
        },
        child: Container(
          color: AppColors.surfaceDark,
        ),
      ),
    );
  }
}
