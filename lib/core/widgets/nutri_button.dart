import 'package:flutter/material.dart';
//import 'package:projeto/core/theme/app_colors.dart';

enum NutriButtonStyle { primary, outline }

class NutriButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final NutriButtonStyle style;
  final Widget? icon;

  const NutriButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.style = NutriButtonStyle.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (style == NutriButtonStyle.outline) {
      return OutlinedButton(
        onPressed: onPressed,
        child: _buildChild(),
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      child: _buildChild(),
    );
  }

  Widget _buildChild() {
    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon!,
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      );
    }
    return Text(text, style: const TextStyle(fontSize: 16));
  }
}