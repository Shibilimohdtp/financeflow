import 'package:flutter/material.dart';

import '../../theme/ff.dart';
import 'ff_sheet.dart';
import 'ff_sheet_header.dart';

/// A single-choice field in Stillwater Bloom. It has the same look as an
/// `FfTextField` (outlined field, label, helper and error text, icon slot).
/// Tapping it opens a Bloom sheet with each option as a tappable row, the
/// selected one marked with a check, so long lists scroll and the choice
/// reads in one glance. The API is unchanged for existing callers.
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

  /// Usually `DropdownMenuItem(value: x, child: Text(name))`. The child is
  /// shown as the option's label, so keep it a single line of text.
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? label;
  final String? hint;
  final String? helper;
  final IconData? icon;
  final FormFieldValidator<T>? validator;
  final bool enabled;

  Widget? _selectedChild() {
    for (final item in items) {
      if (item.value == value) return item.child;
    }
    return null;
  }

  Future<void> _open(BuildContext context) async {
    final picked = await showFfSheet<_Picked<T>>(
      context,
      builder:
          (sheetContext) => FfSheet(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FfSheetHeader(title: label ?? hint ?? 'Choose', subtitle: helper),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(
                    FfSpace.lg,
                    FfSpace.xs,
                    FfSpace.lg,
                    FfSpace.lg,
                  ),
                  children: [
                    for (final item in items)
                      _OptionRow<T>(
                        selected: item.value == value,
                        onTap:
                            () => Navigator.of(
                              sheetContext,
                            ).pop(_Picked<T>(item.value)),
                        child: item.child,
                      ),
                  ],
                ),
              ),
            ],
          ),
    );
    if (picked != null) onChanged?.call(picked.value);
  }

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final active = enabled && onChanged != null;
    return FormField<T>(
      key: ValueKey<T?>(value),
      initialValue: value,
      validator: validator,
      enabled: active,
      builder: (state) {
        final selectedChild = _selectedChild();
        return InkWell(
          borderRadius: ffRadius(FfFieldTokens.radius),
          onTap: active ? () => _open(context) : null,
          child: InputDecorator(
            isEmpty: selectedChild == null,
            isFocused: false,
            decoration: InputDecoration(
              labelText: label,
              helperText: helper,
              helperMaxLines: 3,
              errorText: state.errorText,
              enabled: active,
              prefixIcon: icon == null ? null : Icon(icon, size: FfIconSize.lg),
              suffixIcon: Icon(
                Icons.unfold_more_rounded,
                size: FfIconSize.lg,
                color: ff.color.textSecondary,
              ),
            ),
            child:
                selectedChild == null
                    ? Text(
                      hint ?? '',
                      style: ff.text.bodyLg.copyWith(
                        color: ff.color.textSecondary,
                      ),
                    )
                    : DefaultTextStyle.merge(
                      style: ff.text.bodyLg,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      child: selectedChild,
                    ),
          ),
        );
      },
    );
  }
}

/// Wrapper so that picking a `null` option is distinct from dismissing the sheet.
class _Picked<T> {
  const _Picked(this.value);
  final T? value;
}

class _OptionRow<T> extends StatelessWidget {
  const _OptionRow({
    required this.child,
    required this.selected,
    required this.onTap,
  });

  final Widget child;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        borderRadius: ffRadius(FfFieldTokens.radius),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(
            horizontal: FfSpace.md,
            vertical: FfSpace.sm,
          ),
          decoration: BoxDecoration(
            color:
                selected ? ff.color.actionPrimaryContainer : Colors.transparent,
            borderRadius: ffRadius(FfFieldTokens.radius),
          ),
          child: Row(
            children: [
              Expanded(
                child: DefaultTextStyle.merge(
                  style: ff.text.bodyLg.copyWith(
                    fontWeight: selected ? FontWeight.w600 : null,
                    color:
                        selected
                            ? ff.color.onActionPrimaryContainer
                            : ff.color.textPrimary,
                  ),
                  child: child,
                ),
              ),
              if (selected)
                Icon(
                  Icons.check_rounded,
                  size: FfIconSize.lg,
                  color: ff.color.onActionPrimaryContainer,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
