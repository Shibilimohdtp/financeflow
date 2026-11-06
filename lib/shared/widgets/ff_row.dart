import 'package:flutter/material.dart';

import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';
import 'ff_icon_tile.dart';

enum _FfRowControl { none, toggle, checkbox, radio }

/// One row of a list: settings, navigation, choices, actions.
///
/// Leading: a plain [icon], an [icon] with an [iconTone] (drawn as a tinted
/// tile), or a custom [leading] widget. Trailing: a [detail] text (such as
/// the current value), a custom [trailing] widget, or a chevron when the row
/// opens something. Use the named constructors for rows that hold a
/// control; tapping anywhere on those rows changes the control.
///
/// Put rows in an `FfGroupedContainer`, which draws the dividers.
class FfRow extends StatelessWidget {
  const FfRow({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconTone,
    this.leading,
    this.detail,
    this.trailing,
    this.showChevron,
    this.selected,
    this.onTap,
    this.enabled = true,
    this.destructive = false,
  }) : _control = _FfRowControl.none,
       _checked = false,
       _onChanged = null;

  /// A row with a switch.
  const FfRow.toggle({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconTone,
    this.leading,
    required bool value,
    required ValueChanged<bool>? onChanged,
    this.enabled = true,
  }) : _control = _FfRowControl.toggle,
       _checked = value,
       _onChanged = onChanged,
       detail = null,
       trailing = null,
       showChevron = false,
       onTap = null,
       selected = null,
       destructive = false;

  /// A row with a checkbox. [detail] (a short value such as a suggested
  /// amount) sits just before the checkbox.
  const FfRow.checkbox({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconTone,
    this.leading,
    this.detail,
    required bool checked,
    required ValueChanged<bool>? onChanged,
    this.enabled = true,
  }) : _control = _FfRowControl.checkbox,
       _checked = checked,
       _onChanged = onChanged,
       trailing = null,
       showChevron = false,
       onTap = null,
       selected = null,
       destructive = false;

  /// One option of a single-choice list. The radio mark leads the row.
  const FfRow.radio({
    super.key,
    required this.title,
    this.subtitle,
    this.detail,
    required bool selected,
    required this.onTap,
    this.enabled = true,
  }) : _control = _FfRowControl.radio,
       _checked = selected,
       _onChanged = null,
       icon = null,
       iconTone = null,
       leading = null,
       trailing = null,
       showChevron = false,
       selected = null,
       destructive = false;

  final String title;
  final String? subtitle;
  final IconData? icon;
  final FfTone? iconTone;
  final Widget? leading;

  /// Short secondary text at the end of the row, such as the current value.
  final String? detail;
  final Widget? trailing;

  /// Defaults to showing a chevron when the row is tappable and has no
  /// [trailing] widget.
  final bool? showChevron;
  final VoidCallback? onTap;
  final bool enabled;

  /// Marks the current choice in a picker that closes on tap (a check at the
  /// end of the row). Use [FfRow.radio] for choices inside a form instead.
  final bool? selected;

  /// Draws the title and icon in the error colour (for "Delete…", "Wipe…").
  final bool destructive;

  final _FfRowControl _control;
  final bool _checked;
  final ValueChanged<bool>? _onChanged;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final c = ff.color;
    final isControl = _control != _FfRowControl.none;
    final interactive =
        enabled &&
        (isControl
            ? (_control == _FfRowControl.radio ? onTap : _onChanged) != null
            : onTap != null);
    final titleColor =
        !enabled
            ? c.textDisabled
            : destructive
            ? c.statusError
            : c.textPrimary;

    final VoidCallback? handleTap = switch (_control) {
      _FfRowControl.none || _FfRowControl.radio => interactive ? onTap : null,
      _FfRowControl.toggle || _FfRowControl.checkbox =>
        interactive ? () => _onChanged!(!_checked) : null,
    };

    Widget? leadingWidget = leading;
    if (_control == _FfRowControl.radio) {
      leadingWidget = Icon(
        _checked ? Icons.radio_button_checked : Icons.radio_button_off,
        size: FfIconSize.xl,
        color:
            !enabled
                ? c.textDisabled
                : _checked
                ? c.actionPrimary
                : c.textSecondary,
      );
    } else if (leadingWidget == null && icon != null) {
      leadingWidget =
          iconTone == null
              ? Icon(
                icon,
                size: FfRowTokens.iconSize,
                color:
                    !enabled
                        ? c.textDisabled
                        : destructive
                        ? c.statusError
                        : c.textSecondary,
              )
              : FfIconTile(icon: icon!, tone: iconTone!);
    }

    final Widget? trailingWidget = switch (_control) {
      _FfRowControl.toggle => ExcludeSemantics(
        child: Switch(
          value: _checked,
          onChanged: interactive ? _onChanged : null,
        ),
      ),
      _FfRowControl.checkbox => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (detail != null) ...[
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: FfRowTokens.detailMaxWidth,
              ),
              child: Text(
                detail!,
                style: ff.text.body.copyWith(
                  color: ff.color.textPrimary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
              ),
            ),
            const SizedBox(width: FfSpace.x2s),
          ],
          ExcludeSemantics(
            child: Checkbox(
              value: _checked,
              onChanged: interactive ? (v) => _onChanged!(v ?? false) : null,
            ),
          ),
        ],
      ),
      _ => _trailing(ff, interactive),
    };

    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: FfRowTokens.minHeight),
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: FfRowTokens.paddingH,
          end:
              isControl && _control != _FfRowControl.radio
                  ? FfRowTokens.paddingHControl
                  : FfRowTokens.paddingH,
          top: FfRowTokens.paddingV,
          bottom: FfRowTokens.paddingV,
        ),
        child: Row(
          children: [
            if (leadingWidget != null) ...[
              leadingWidget,
              const SizedBox(width: FfRowTokens.gap),
            ],
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: ff.text.titleSm.copyWith(color: titleColor),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: FfSpace.x3s),
                    Text(
                      subtitle!,
                      style: ff.text.bodySm.copyWith(
                        color: enabled ? c.textSecondary : c.textDisabled,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (trailingWidget != null) ...[
              const SizedBox(width: FfSpace.xs),
              trailingWidget,
            ],
          ],
        ),
      ),
    );

    // One node per row: the label, its state and the tap action together.
    return Semantics(
      container: true,
      button: _control == _FfRowControl.none && handleTap != null,
      toggled: _control == _FfRowControl.toggle ? _checked : null,
      checked:
          _control == _FfRowControl.checkbox || _control == _FfRowControl.radio
              ? _checked
              : null,
      selected: selected,
      inMutuallyExclusiveGroup: _control == _FfRowControl.radio ? true : null,
      enabled: isControl || onTap != null ? enabled : null,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(onTap: handleTap, child: row),
      ),
    );
  }

  Widget? _trailing(FfThemeData ff, bool interactive) {
    if (trailing != null) return trailing;
    if (selected != null) {
      return selected!
          ? Icon(
            Icons.check_rounded,
            size: FfIconSize.lg,
            color: ff.color.actionPrimary,
          )
          : null;
    }
    final chevron =
        (showChevron ?? (interactive && _control == _FfRowControl.none))
            ? Icon(
              Icons.chevron_right_rounded,
              size: FfIconSize.md,
              color: ff.color.textTertiary,
            )
            : null;
    if (detail == null) return chevron;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: FfRowTokens.detailMaxWidth,
          ),
          child: Text(
            detail!,
            style: ff.text.body.copyWith(color: ff.color.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
        if (chevron != null) ...[const SizedBox(width: FfSpace.x2s), chevron],
      ],
    );
  }
}
