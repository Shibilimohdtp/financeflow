import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/formatting/currency_formatter.dart';
import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';
import 'ff_amount_text.dart';
import 'ff_field_label.dart';

/// Money entry. Digits use the money type roles (tabular figures) and the
/// currency symbol is coloured by [tone] (for example income or expense).
///
/// The currency symbol is always visible, also while the field is empty and
/// unfocused. The hint is `0`; never put an example amount in it.
///
/// With [groupDigits] the digits group as you type in the app's convention
/// (Indian: 1,00,000.50). Read the value back with [FfAmountField.parse] and
/// fill an edit form with [FfAmountField.formatInput]. Callers that still
/// read the controller with `double.tryParse` must leave [groupDigits] off.
///
/// The default constructor is a form field with its label above the box,
/// like `FfTextField`. [FfAmountField.bare] is borderless, for amount heroes.
class FfAmountField extends StatelessWidget {
  const FfAmountField({
    super.key,
    required this.controller,
    this.label,
    this.hint = '0',
    this.helper,
    this.errorText,
    this.tone = FfTone.primary,
    this.size = FfAmountSize.lg,
    this.validator,
    this.onChanged,
    this.autofocus = false,
    this.focusNode,
    this.groupDigits = false,
    this.textInputAction,
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
    this.groupDigits = false,
    this.textInputAction,
  }) : _bare = true,
       label = null,
       helper = null,
       errorText = null;

  final TextEditingController controller;
  final String? label;
  final String hint;
  final String? helper;

  /// An error shown under the field without a `Form` validator.
  final String? errorText;
  final FfTone tone;
  final FfAmountSize size;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final FocusNode? focusNode;
  final bool groupDigits;
  final TextInputAction? textInputAction;
  final bool _bare;

  /// Digits with at most two decimals (no grouping).
  static final List<TextInputFormatter> formatters = [
    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
  ];

  /// Reads an amount typed in an [FfAmountField], grouped or not.
  static double? parse(String text) => CurrencyFormatter.parse(text);

  /// The text to put in a grouped field for [amount]: grouped, no symbol,
  /// paise only when there are any ("3,246.32", "5,000").
  static String formatInput(double amount) =>
      CurrencyFormatter.format(amount.abs(), includeSymbol: false);

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

    // A prefix *icon* stays visible when the field is empty and unfocused,
    // unlike `prefixText`, so the currency is never missing.
    final symbol = Padding(
      padding: EdgeInsetsDirectional.only(
        start: _bare ? 0 : FfFieldTokens.paddingH,
        end: FfSpace.x2s,
      ),
      child: Text(
        CurrencyFormatter.currencySymbol,
        style: digits.copyWith(color: symbolColor),
      ),
    );
    const symbolConstraints = BoxConstraints();

    final decoration =
        _bare
            ? InputDecoration(
              hintText: hint,
              hintStyle: digits.copyWith(color: c.textTertiary),
              prefixIcon: symbol,
              prefixIconConstraints: symbolConstraints,
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
              hintText: hint,
              hintStyle: digits.copyWith(color: c.textTertiary),
              helperText: helper,
              helperMaxLines: 3,
              errorText: errorText,
              prefixIcon: symbol,
              prefixIconConstraints: symbolConstraints,
              errorMaxLines: 2,
            );

    // Large amounts keep their layout under big system text sizes.
    final field = MediaQuery.withClampedTextScaling(
      maxScaleFactor: FfAmountTokens.maxTextScale,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textInputAction: textInputAction,
        inputFormatters: groupDigits ? [FfAmountInputFormatter()] : formatters,
        style: digits.copyWith(color: c.textPrimary),
        decoration: decoration,
        validator: validator,
        onChanged: onChanged,
      ),
    );
    if (_bare || label == null) return field;
    return MergeSemantics(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FfFieldLabel(label!),
          const SizedBox(height: FfSheetTokens.labelGap),
          field,
        ],
      ),
    );
  }
}

/// Keeps digits and at most two decimals, and groups the whole part in the
/// app's convention as the user types (Indian 1,00,000; others 100,000).
/// The cursor stays after the same digit it was after.
class FfAmountInputFormatter extends TextInputFormatter {
  static final _allowed = RegExp(r'^\d*\.?\d{0,2}$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text.replaceAll(',', '');
    if (!_allowed.hasMatch(raw)) return oldValue;
    if (raw.isEmpty) return newValue.copyWith(text: '');

    // Characters (not commas) before the cursor in the new text.
    final cursor = newValue.selection.baseOffset.clamp(0, newValue.text.length);
    final kept = newValue.text.substring(0, cursor).replaceAll(',', '').length;

    final dot = raw.indexOf('.');
    final whole = dot < 0 ? raw : raw.substring(0, dot);
    final fraction = dot < 0 ? '' : raw.substring(dot);
    final grouped = '${group(whole)}$fraction';

    var offset = 0;
    var seen = 0;
    while (offset < grouped.length && seen < kept) {
      if (grouped[offset] != ',') seen++;
      offset++;
    }
    return TextEditingValue(
      text: grouped,
      selection: TextSelection.collapsed(offset: offset),
    );
  }

  /// Groups a run of digits: "1234567" → "12,34,567" (Indian) or
  /// "1,234,567".
  static String group(String digits) {
    if (digits.length <= 3) return digits;
    final indian = CurrencyFormatter.current.usesIndianGrouping;
    final last3 = digits.substring(digits.length - 3);
    var rest = digits.substring(0, digits.length - 3);
    final size = indian ? 2 : 3;
    final parts = <String>[];
    while (rest.length > size) {
      parts.insert(0, rest.substring(rest.length - size));
      rest = rest.substring(0, rest.length - size);
    }
    if (rest.isNotEmpty) parts.insert(0, rest);
    return '${parts.join(',')},$last3';
  }
}
