import 'package:flutter/material.dart';
import 'package:projeto/core/theme/app_colors.dart';
import 'package:projeto/core/constants/app_sizes.dart';

class NutriTextField extends StatefulWidget {
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
  State<NutriTextField> createState() => _NutriTextFieldState();
}

class _NutriTextFieldState extends State<NutriTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color highlightColor = AppColors.secondary;
    final Color activeColor = _isFocused ? highlightColor : AppColors.border;
    final Color labelColor = _isFocused ? highlightColor : AppColors.textMuted;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 60,
          decoration: ShapeDecoration(
            color: AppColors.surfaceDark,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 2.5,
                color: activeColor,
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
                  widget.label.toUpperCase(),
                  style: TextStyle(
                    color: labelColor, 
                    fontSize: 10,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.60,
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: widget.controller,
                    focusNode: _focusNode, 
                    obscureText: widget.obscureText,
                    cursorColor: highlightColor,
                    style: const TextStyle(
                      color: AppColors.onBackground,
                      fontSize: 15,
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      hintText: widget.hintText,
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