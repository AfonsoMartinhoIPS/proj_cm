import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';

//TODO: Rever.
// Tamanho hardcoded.
class NutriBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const NutriBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed ?? () => Navigator.maybePop(context),
      child: Container(
        width: 32,
        height: 32, //só se n for filho direto do AppBar é que este tamanho é aplicado
        decoration: BoxDecoration(
          color: Colors.transparent, 
          border: Border.all(
            color: AppColors.secondary, 
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Icon(
            Icons.arrow_back_rounded,
            size: 16,
            color: AppColors.secondary,
          ),
        ),
      ),
    );
  }
}