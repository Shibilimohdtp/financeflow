import 'package:flutter/material.dart';

import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';
import 'ff_amount_field.dart';
import 'ff_amount_text.dart';

/// The hero container for financial amount entry in Stillwater Bloom.
///
/// Archetype A of the sheet recipe (amount first): a card with a faint wash
/// of [tone] (`FfRadius.xl`), large light Geist numerals (`moneyHero`
/// 44/300) with the currency always shown, an optional clear button, a quiet
/// live consequence line below, and inline error text. The wash is faint and
/// the border neutral so the card reads as active, never as disabled.
class FfAmountHero extends StatelessWidget {
  final TextEditingController controller;
  final FfTone tone;
  final String label;
  final String? consequence;
  final IconData? consequenceIcon;
  final String? errorText;
  final bool autofocus;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final Widget? trailing;

  /// Group digits as the user types; read back with `FfAmountField.parse`.
  final bool groupDigits;

  const FfAmountHero({
    super.key,
    required this.controller,
    this.tone = FfTone.expense,
    this.label = 'Amount',
    this.consequence,
    this.consequenceIcon,
    this.errorText,
    this.autofocus = false,
    this.focusNode,
    this.onChanged,
    this.onClear,
    this.trailing,
    this.groupDigits = false,
  });

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final c = ff.color;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final toneColor = tone.foreground(c);
    final surfaceColor =
        isDark
            ? Color.alphaBlend(c.tint(toneColor, FfTint.whisper), c.surfaceCard)
            : Color.alphaBlend(c.tint(toneColor, FfTint.faint), c.surfaceCard);

    final borderColor = errorText != null ? c.statusError : c.borderSubtle;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(FfRadius.xl),
        border: Border.all(
          color: borderColor,
          width:
              errorText != null ? FfBorderWidth.focus : FfBorderWidth.regular,
        ),
        boxShadow:
            isDark ? const [] : FfElevation.card(c.shadow, Brightness.light),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: FfSpace.lg,
        vertical: FfSpace.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header: label + clear/trailing ───────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: ff.text.label.copyWith(color: c.textSecondary),
              ),
              if (trailing != null)
                trailing!
              else if (controller.text.isNotEmpty && onClear != null)
                Semantics(
                  button: true,
                  label: 'Clear amount',
                  child: InkWell(
                    onTap: onClear,
                    borderRadius: BorderRadius.circular(FfRadius.full),
                    child: Padding(
                      padding: const EdgeInsets.all(FfSpace.x3s),
                      child: Icon(
                        Icons.close_rounded,
                        size: FfIconSize.sm,
                        color: c.textSecondary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: FfSpace.xs),

          // ── Main Hero Amount Input ────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: FfAmountField.bare(
                  controller: controller,
                  focusNode: focusNode,
                  autofocus: autofocus,
                  tone: tone,
                  size: FfAmountSize.hero,
                  onChanged: onChanged,
                  groupDigits: groupDigits,
                ),
              ),
            ],
          ),

          // ── Consequence Line or Error ────────────────────────────────────
          if (errorText != null) ...[
            const SizedBox(height: FfSpace.xs),
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: FfIconSize.xs,
                  color: c.statusError,
                ),
                const SizedBox(width: FfSpace.x2s),
                Expanded(
                  child: Text(
                    errorText!,
                    style: ff.text.bodySm.copyWith(
                      color: c.statusError,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ] else if (consequence != null && consequence!.isNotEmpty) ...[
            const SizedBox(height: FfSpace.xs),
            Row(
              children: [
                Icon(
                  consequenceIcon ?? Icons.account_balance_wallet_outlined,
                  size: FfIconSize.xs,
                  color: c.textSecondary,
                ),
                const SizedBox(width: FfSpace.x2s),
                Expanded(
                  child: Text(
                    consequence!,
                    style: ff.text.bodySm.copyWith(color: c.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
