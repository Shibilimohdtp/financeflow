import 'package:flutter/material.dart';
import '../../../core/formatting/currency_formatter.dart';
import '../../../shared/widgets/ff_card.dart';
import '../../../theme/ff.dart';
import '../../../theme/stillwater_typography.dart';

class LendingSummaryBox extends StatelessWidget {
  final String title;
  final double amount;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback onAddTap;

  const LendingSummaryBox({
    super.key,
    required this.title,
    required this.amount,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return FfCard(
      variant: FfCardVariant.standard,
      padding: const EdgeInsets.all(FfSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 16),
                  const SizedBox(width: FfSpace.xs),
                  Text(
                    title,
                    style: context.ff.text.labelSm.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onAddTap,
                borderRadius: BorderRadius.circular(FfRadius.sm),
                child: Padding(
                  padding: const EdgeInsets.all(FfSpace.x2s),
                  child: Icon(
                    Icons.add_circle_outline_rounded,
                    size: 18,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: FfSpace.sm),
          Text(
            CurrencyFormatter.format(amount),
            style: context.ff.text.titleLg.copyWith(
              fontWeight: FontWeight.w800,
              fontFeatures: StillwaterTypography.tabularFeatures,
            ),
          ),
          const SizedBox(height: FfSpace.x2s),
          Text(
            subtitle,
            style: context.ff.text.labelSm.copyWith(
              color: context.ff.color.secondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class LendingFilterChipItem extends StatelessWidget {
  final String label;
  final int? count;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const LendingFilterChipItem({
    super.key,
    required this.label,
    this.count,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? context.ff.color.actionPrimary;

    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count != null && count! > 0) ...[
            const SizedBox(width: FfSpace.x2s),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: FfSpace.x2s,
                vertical: FfSpace.x3s,
              ),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? context.ff.color.onActionPrimary.withValues(
                          alpha: FfTint.medium.alpha,
                        )
                        : activeColor.withValues(alpha: FfTint.subtle.alpha),
                borderRadius: BorderRadius.circular(FfRadius.full),
              ),
              child: Text(
                count.toString(),
                style: context.ff.text.labelSm.copyWith(
                  fontWeight: FontWeight.w700,
                  color:
                      isSelected
                          ? context.ff.color.onActionPrimary
                          : activeColor,
                ),
              ),
            ),
          ],
        ],
      ),
      onSelected: (_) => onTap(),
      selectedColor: activeColor,
      labelStyle: context.ff.text.label.copyWith(
        color:
            isSelected
                ? context.ff.color.onActionPrimary
                : context.ff.color.textPrimary,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
      backgroundColor: context.ff.color.surfaceCard,
      side: BorderSide(
        color:
            isSelected
                ? activeColor
                : context.ff.color.borderSubtle.withValues(
                  alpha: FfTint.strong.alpha,
                ),
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FfRadius.full),
      ),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(
        horizontal: FfSpace.sm,
        vertical: FfSpace.x2s,
      ),
    );
  }
}
