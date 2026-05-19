import 'package:flutter/material.dart';
import 'package:nutri_scan/core/constants/app_sizes.dart';

/// Um campo de texto personalizado e animado para a aplicação NutriScan.
///
/// Apresenta um layout moderno onde o [label] fixo em maiúsculas fica posicionado
/// acima do campo de input, contido dentro de uma moldura animada que reage ao foco.
///
/// ### Exemplo de utilização:
/// ```dart
/// NutriTextField(
///   label: 'Email',
///   hint: 'insira o seu email',
///   icon: Icons.email_outlined,
///   controller: _emailController,
///   validator: (value) => value!.isEmpty ? 'Obrigatório' : null,
/// )
/// ```
class NutriTextField extends StatefulWidget {
  /// O texto de identificação fixo que aparece no topo do campo (ex: "EMAIL").
  final String label;

  /// O texto de ajuda (placeholder) que aparece quando o campo está vazio.
  final String hint;

  /// Ícone opcional exibido no início do campo.
  final IconData? icon;

  /// Se `true`, oculta o texto digitado (útil para palavras-passe). O valor por defeito é `false`.
  final bool obscureText;

  /// Controlador opcional para manipular o texto do campo.
  final TextEditingController? controller;

  /// Função de validação opcional para integrar com um widget [Form].
  final String? Function(String?)? validator;

  /// Cria um [NutriTextField].
  const NutriTextField({
    super.key,
    required this.label,
    required this.hint,
    this.icon,
    this.obscureText = false,
    this.controller,
    this.validator,
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

    final Color containerBg = theme.inputDecorationTheme.fillColor ?? theme.cardColor;
        
    final Color activeColor = _isFocused 
        ? theme.colorScheme.secondary 
        : theme.dividerColor;
    final Color labelColor = _isFocused 
        ? theme.colorScheme.secondary 
        : (theme.inputDecorationTheme.labelStyle?.color ?? theme.hintColor);
    final Color hintColor = theme.inputDecorationTheme.hintStyle?.color ?? theme.hintColor;

    return AnimatedContainer(
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
                    cursorColor: theme.colorScheme.secondary,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      hintText: widget.hint,
                      hintStyle: TextStyle(
                        color: hintColor,
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      isCollapsed: true,
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