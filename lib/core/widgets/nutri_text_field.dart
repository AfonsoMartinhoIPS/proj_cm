import 'package:flutter/material.dart';
import 'package:nutri_scan/core/constants/app_sizes.dart';

/// Themed text field with floating uppercase label, animated focus border,
/// optional leading icon, and Form-compatible validation.
///
/// Colors are pulled from [Theme.of(context).inputDecorationTheme] and
/// [colorScheme.secondary] so the field stays in sync with the app theme.
class NutriTextField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData? icon;
  final bool obscureText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool autofocus;
  final void Function(String)? onSubmitted;
  final void Function(String)? onChanged;
  final TextInputAction? textInputAction;

  const NutriTextField({
    super.key,
    required this.label,
    required this.hint,
    this.icon,
    this.obscureText = false,
    this.controller,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.autofocus = false,
    this.onSubmitted,
    this.onChanged,
    this.textInputAction,
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
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final containerBg = theme.inputDecorationTheme.fillColor ?? theme.cardColor;
    final activeColor = _isFocused ? theme.colorScheme.secondary : theme.dividerColor;
    final labelColor = _isFocused
        ? theme.colorScheme.secondary
        : (theme.inputDecorationTheme.labelStyle?.color ?? theme.hintColor);
    final hintColor = theme.inputDecorationTheme.hintStyle?.color ?? theme.hintColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      constraints: const BoxConstraints(minHeight: 64),
      decoration: ShapeDecoration(
        color: containerBg,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 2.0, color: activeColor),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                size: 20,
                color: _isFocused ? theme.colorScheme.secondary : hintColor,
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.label.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                          color: labelColor,
                          letterSpacing: 1.2,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ) ??
                        TextStyle(
                          color: labelColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                  ),
                  const SizedBox(height: 2),
                  TextFormField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    obscureText: widget.obscureText,
                    validator: widget.validator,
                    keyboardType: widget.keyboardType,
                    maxLines: widget.obscureText ? 1 : widget.maxLines,
                    autofocus: widget.autofocus,
                    onFieldSubmitted: widget.onSubmitted,
                    onChanged: widget.onChanged,
                    textInputAction: widget.textInputAction,
                    cursorColor: theme.colorScheme.secondary,
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 15),
                    decoration: InputDecoration(
                      isDense: true,
                      isCollapsed: true,
                      contentPadding: EdgeInsets.zero,
                      hintText: widget.hint,
                      hintStyle: TextStyle(color: hintColor, fontSize: 15),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
