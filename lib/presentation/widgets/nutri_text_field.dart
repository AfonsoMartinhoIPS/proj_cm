import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';

/// Um campo de texto personalizado e animado para a aplicação NutriScan.
class NutriTextField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData? icon;
  final bool obscureText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool autofocus;
  final int? maxLines;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const NutriTextField({
    super.key,
    required this.label,
    required this.hint,
    this.icon,
    this.obscureText = false,
    this.controller,
    this.validator,
    this.keyboardType,
    this.autofocus = false,
    this.maxLines = 1,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  State<NutriTextField> createState() => _NutriTextFieldState();
}

class _NutriTextFieldState extends State<NutriTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  String? _errorText; // Guarda o estado do erro localmente

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
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
    final isDark = theme.brightness == Brightness.dark;

    final Color containerBg = theme.inputDecorationTheme.fillColor ?? theme.cardColor;
    final Color hintColor = theme.inputDecorationTheme.hintStyle?.color ?? theme.hintColor;
        
    // Gestão dinâmica de cor com base no foco e erros
    final Color activeColor = _errorText != null
        ? theme.colorScheme.error
        : _isFocused 
            ? theme.colorScheme.secondary 
            : theme.dividerColor;

    final Color labelColor = _errorText != null
        ? theme.colorScheme.error
        : _isFocused 
            ? theme.colorScheme.secondary 
            : (theme.inputDecorationTheme.labelStyle?.color ?? theme.hintColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          constraints: const BoxConstraints(minHeight: 64), 
          decoration: ShapeDecoration(
            color: containerBg,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 2.0,
                color: activeColor,
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md, 
              vertical: AppSizes.sm,
            ),
            child: Row(
              crossAxisAlignment: widget.maxLines != null && widget.maxLines! > 1 
                  ? CrossAxisAlignment.start 
                  : CrossAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    size: AppSizes.iconMd, // Lido do teu AppSizes (24.0)
                    color: _errorText != null
                        ? theme.colorScheme.error
                        : _isFocused 
                            ? theme.colorScheme.secondary 
                            : hintColor,
                  ),
                  const SizedBox(width: AppSizes.sm), // Usando o teu core spacing (8.0)
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
                              fontSize: AppSizes.fontXs - 2, // Ajustado dinamicamente (10.0)
                              fontWeight: FontWeight.w600,
                            ) ??
                            TextStyle(
                              color: labelColor,
                              fontSize: AppSizes.fontXs - 2,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                      ),
                      const SizedBox(height: AppSizes.xs), // Usando o teu core spacing (4.0)
                      TextFormField(
                        controller: widget.controller,
                        focusNode: _focusNode,
                        obscureText: widget.obscureText,
                        keyboardType: widget.keyboardType,
                        autofocus: widget.autofocus,
                        maxLines: widget.maxLines,
                        textInputAction: widget.textInputAction,
                        onChanged: widget.onChanged,
                        onFieldSubmitted: widget.onSubmitted,
                        cursorColor: theme.colorScheme.secondary,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: AppSizes.fontMd - 1, // Consistente com a app (15.0)
                        ),
                        validator: (value) {
                          if (widget.validator != null) {
                            final error = widget.validator!(value);
                            setState(() => _errorText = error);
                            return error;
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          hintText: widget.hint,
                          hintStyle: TextStyle(
                            color: hintColor,
                            fontSize: AppSizes.fontMd - 1,
                          ),
                          // Remove decorações extra para dar o controlo total ao Container exterior
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          errorStyle: const TextStyle(height: 0, fontSize: 0), // Esconde o texto nativo abaixo do input
                          isCollapsed: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Se existir erro, renderiza-o de forma limpa abaixo do container costumizado
        if (_errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: AppSizes.sm, top: AppSizes.xs),
            child: Text(
              _errorText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
                fontSize: AppSizes.fontXs,
              ),
            ),
          ),
      ],
    );
  }
}