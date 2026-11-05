import 'package:flutter/material.dart';

import '../../theme/ff.dart';

/// A single-choice dropdown field. It looks like an `FfTextField` (same
/// border, fill, label and icon slots) and its menu uses the raised surface
/// and field radius from the theme.
class FfSelect<T> extends StatelessWidget {
  const FfSelect({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.label,
    this.hint,
    this.helper,
    this.icon,
    this.validator,
    this.enabled = true,
  });

  final T? value;

  /// Usually `DropdownMenuItem(value: x, child: Text(name))`.
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? label;
  final String? hint;
  final String? helper;
  final IconData? icon;
  final FormFieldValidator<T>? validator;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: enabled ? onChanged : null,
      validator: validator,
      isExpanded: true,
      style: ff.text.bodyLg,
      dropdownColor: ff.color.surfaceRaised,
      borderRadius: ffRadius(FfFieldTokens.radius),
      icon: Icon(
        Icons.expand_more_rounded,
        size: FfIconSize.lg,
        color: ff.color.textSecondary,
      ),
      hint: hint == null ? null : Text(hint!),
      decoration: InputDecoration(
        labelText: label,
        helperText: helper,
        helperMaxLines: 3,
        prefixIcon: icon == null ? null : Icon(icon, size: FfIconSize.lg),
      ),
    );
  }
}
