import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/ff.dart';

/// A text input. Borders, fill, padding and text styles come from the theme;
/// callers describe the field with semantic slots ([label], [hint], [icon],
/// [prefixText], [helper], [suffix]) instead of an `InputDecoration`.
///
/// Use [FfTextField.search] for in-page search boxes and `FfAmountField` for
/// money entry.
class FfTextField extends StatelessWidget {
  const FfTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.label,
    this.hint,
    this.helper,
    this.errorText,
    this.icon,
    this.prefixText,
    this.suffixText,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.autofocus = false,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.autofillHints,
  }) : _search = false;

  /// A rounded, borderless search box with a leading search icon and a clear
  /// button once there is text (needs [controller]).
  const FfTextField.search({
    super.key,
    this.controller,
    this.focusNode,
    required String this.hint,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
  }) : _search = true,
       initialValue = null,
       label = null,
       helper = null,
       errorText = null,
       icon = Icons.search_rounded,
       prefixText = null,
       suffixText = null,
       suffix = null,
       keyboardType = TextInputType.text,
       textInputAction = TextInputAction.search,
       textCapitalization = TextCapitalization.none,
       inputFormatters = null,
       validator = null,
       onTap = null,
       maxLines = 1,
       minLines = null,
       maxLength = null,
       enabled = true,
       readOnly = false,
       obscureText = false,
       autofillHints = null;

  final TextEditingController? controller;
  final String? initialValue;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final String? helper;
  final String? errorText;
  final IconData? icon;
  final String? prefixText;
  final String? suffixText;

  /// A trailing widget inside the field, such as a clear or calendar button.
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool autofocus;
  final bool enabled;
  final bool readOnly;
  final bool obscureText;
  final Iterable<String>? autofillHints;
  final bool _search;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final c = ff.color;
    final decoration =
        _search
            ? InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, size: FfIconSize.lg),
              suffixIcon: controller == null ? null : _ClearButton(this),
              filled: true,
              fillColor: c.surfaceContainerLow,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: FfFieldTokens.paddingH,
                vertical: FfSpace.sm,
              ),
              border: OutlineInputBorder(
                borderRadius: ffRadius(FfRadius.full),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: ffRadius(FfRadius.full),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: ffRadius(FfRadius.full),
                borderSide: BorderSide(
                  color: c.focusRing,
                  width: FfBorderWidth.focus,
                ),
              ),
            )
            : InputDecoration(
              labelText: label,
              hintText: hint,
              helperText: helper,
              helperMaxLines: 3,
              errorText: errorText,
              errorMaxLines: 3,
              prefixIcon: icon == null ? null : Icon(icon, size: FfIconSize.lg),
              prefixText: prefixText,
              suffixText: suffixText,
              suffixIcon: suffix,
              counterText: maxLength == null ? null : '',
            );

    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      focusNode: focusNode,
      decoration: decoration,
      style: ff.text.bodyLg,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      onTap: onTap,
      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      maxLength: maxLength,
      autofocus: autofocus,
      enabled: enabled,
      readOnly: readOnly,
      obscureText: obscureText,
      autofillHints: autofillHints,
    );
  }
}

class _ClearButton extends StatelessWidget {
  const _ClearButton(this.field);
  final FfTextField field;

  @override
  Widget build(BuildContext context) {
    final controller = field.controller!;
    return ListenableBuilder(
      listenable: controller,
      builder:
          (context, _) =>
              controller.text.isEmpty
                  ? const SizedBox.shrink()
                  : IconButton(
                    icon: const Icon(Icons.clear_rounded, size: FfIconSize.md),
                    tooltip: 'Clear search',
                    onPressed: () {
                      controller.clear();
                      field.onChanged?.call('');
                    },
                  ),
    );
  }
}
