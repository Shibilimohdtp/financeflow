import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/formatting/currency_formatter.dart';
import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';
import 'ff_amount_text.dart';

/// Money entry. Digits use the money type roles (tabular figures) and the
/// currency symbol is coloured by [tone] (for example income or expense).
///
/// The default constructor is an outlined form field like `FfTextField`.
/// [FfAmountField.bare] is borderless, for screens that place the amount in
/// their own panel (the Add transaction header).
class FfAmountField extends StatelessWidget {
  const FfAmountField({
    super.key,
    required this.controller,
    this.label,
    this.hint = '0',
    this.tone = FfTone.primary,
    this.size = FfAmountSize.lg,
    this.validator,
    this.onChanged,
    this.autofocus = false,
    this.focusNode,
  }) : _bare = false;

  const FfAmountField.bare({
    super.key,
    required this.controller,
    this.hint = '0',
    this.tone = FfTone.neutral,
    this.size = FfAmountSize.hero,
    this.validator,
    this.onChanged,
    this.autofocus = false,
    this.focusNode,
  }) : _bare = true,
       label = null;

  final TextEditingController controller;
  final String? label;
  final String hint;
  final FfTone tone;
  final FfAmountSize size;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final FocusNode? focusNode;
  final bool _bare;

  /// Digits with at most two decimals.
  static final List<TextInputFormatter> formatters = [
    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
  ];

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final c = ff.color;
    final digits = switch (size) {
      FfAmountSize.hero => ff.text.moneyHero,
      FfAmountSize.lg => ff.text.moneyLg,
      FfAmountSize.md => ff.text.moneyMd,
      FfAmountSize.sm => ff.text.moneySm,
    };
    final symbolColor =
        tone == FfTone.neutral ? c.textSecondary : tone.foreground(c);

    final decoration =
        _bare
            ? InputDecoration(
              hintText: hint,
              hintStyle: digits.copyWith(color: c.textTertiary),
              prefixText: '${CurrencyFormatter.currencySymbol} ',
              prefixStyle: digits.copyWith(color: symbolColor),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              filled: false,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            )
            : InputDecoration(
              labelText: label,
              hintText: hint,
              hintStyle: digits.copyWith(color: c.textTertiary),
              prefixText: '${CurrencyFormatter.currencySymbol} ',
              prefixStyle: digits.copyWith(color: symbolColor),
              errorMaxLines: 2,
            );

    // Large amounts keep their layout under big system text sizes.
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: FfAmountTokens.maxTextScale,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: formatters,
        style: digits.copyWith(color: c.textPrimary),
        decoration: decoration,
        validator: validator,
        onChanged: onChanged,
      ),
    );
  }
}
