import 'package:flutter/material.dart';
import 'package:projeto/core/theme/app_colors.dart';
import 'package:projeto/core/constants/app_sizes.dart';


class NutriTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final bool obscureText;

  const NutriTextField({
    super.key,
    required this.label,
    this.hintText = "Text_Input",
    this.controller,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 60,
          decoration: ShapeDecoration(
            color: AppColors.surfaceDark,
            shape: RoundedRectangleBorder(
              side: const BorderSide(
                width: 2.5,
                color: AppColors.border,
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.60,
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    obscureText: obscureText,
                    cursorColor: AppColors.onBackground,
                    style: const TextStyle(
                      color: AppColors.onBackground,
                      fontSize: 15,
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      hintText: hintText,
                      hintStyle: const TextStyle(
                        color: AppColors.textMuted, 
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isCollapsed: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}