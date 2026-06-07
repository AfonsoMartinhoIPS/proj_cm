// lib/presentation/widgets/nutri_text_field.dart
import 'package:flutter/material.dart';
import 'package:nutri_scan/core/core.dart';
import 'package:nutri_scan/presentation/widgets/components/nutri_label.dart';

/// Um campo de texto personalizado e animado para a aplicação NutriScan.
///
/// Este componente envolve um [TextFormField] nativo dentro de um [AnimatedContainer]
/// para fornecer feedback visual dinâmico quando o campo ganha foco ou quando
/// ocorrem erros de validação, mantendo a consistência com o design system da app.
class NutriTextField extends StatefulWidget {
  /// O texto de identificação fixo que aparece no topo do campo (ex: "EMAIL").
  final String label;

  /// O texto de ajuda (placeholder) que aparece quando o campo está vazio.
  /// Opcional: passa `null` para esconder o placeholder em campos onde o
  /// rótulo + tipo de teclado já comunicam o formato esperado (passwords,
  /// numéricos com unidade no label, etc.).
  final String? hint;

  /// O texto inicial
  final String? value;

  /// Ícone opcional exibido no início do campo.
  final IconData? icon;

  /// Se `true`, oculta o texto digitado (útil para palavras-passe).
  final bool obscureText;

  /// Controlador opcional para manipular o texto do campo.
  final TextEditingController? controller;

  /// Função de validação opcional para integrar com um widget [Form].
  final String? Function(String?)? validator;

  /// O tipo de teclado a exibir (ex: numérico, email, etc.).
  final TextInputType? keyboardType;

  /// Se o campo deve focar automaticamente ao ser renderizado.
  final bool autofocus;

  /// O número máximo de linhas (útil para campos de texto longos/notas).
  final int? maxLines;

  /// A ação do teclado (ex: concluir, seguinte, nova linha).
  final TextInputAction? textInputAction;

  /// Callback chamado sempre que o texto do campo é alterado.
  final ValueChanged<String>? onChanged;

  /// Callback chamado quando o utilizador submete a ação do teclado.
  final ValueChanged<String>? onSubmitted;

  /// Cria um [NutriTextField].
  const NutriTextField({
    super.key,
    required this.label,
    this.hint,
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
    this.value,
  });

  @override
  State<NutriTextField> createState() => _NutriTextFieldState();
}

class _NutriTextFieldState extends State<NutriTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  String? _errorText;

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
    final Color hintColor = theme.inputDecorationTheme.hintStyle?.color ?? theme.hintColor;
        
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
        GestureDetector(
          onTap: () {
            if (!_focusNode.hasFocus) {
              _focusNode.requestFocus();
            }
          },
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
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
                      size: AppSizes.iconMd,
                      color: _errorText != null
                          ? theme.colorScheme.error
                          : _isFocused 
                              ? theme.colorScheme.secondary 
                              : hintColor,
                    ),
                    const SizedBox(width: AppSizes.sm),
                  ],
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        NutriLabel(
                          widget.label.toUpperCase(),
                          variant: NutriLabelVariant.label,
                          color: labelColor,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w600,
                        ),
                        const SizedBox(height: AppSizes.xs),
                        TextFormField(
                          controller: widget.controller,
                          initialValue: widget.controller == null
                              ? widget.value
                              : null,
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
                            fontSize: AppSizes.fontMd - 1,
                          ),
                          validator: (value) {
                            if (widget.validator == null) return null;
                            final error = widget.validator!(value);
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (!mounted) return;
                              if (_errorText != error) {
                                setState(() => _errorText = error);
                              }
                            });
                            return error;
                          },
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            hintText: widget.hint,
                            hintStyle: TextStyle(
                              // Lighter + italic so hints read as placeholder
                              // examples ("ex. 62") instead of pre-filled
                              // values. 0.4 alpha keeps them legible without
                              // competing with real input text.
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.4),
                              fontSize: AppSizes.fontMd - 1,
                              fontStyle: FontStyle.italic,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            errorStyle: const TextStyle(height: 0, fontSize: 0),
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
        ),
        if (_errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: AppSizes.sm, top: AppSizes.xs),
            child: NutriLabel(
              _errorText!,
              variant: NutriLabelVariant.small,
              color: theme.colorScheme.error,
            ),
          ),
      ],
    );
  }
}