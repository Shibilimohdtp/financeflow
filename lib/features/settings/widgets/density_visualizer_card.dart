import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/app_settings.dart';
import '../../../shared/widgets/ff_amount_text.dart';
import '../../../shared/widgets/ff_card.dart';
import '../../../shared/widgets/ff_icon_tile.dart';
import '../../../shared/widgets/ff_segmented_pill.dart';
import '../../../theme/ff.dart';
import '../../../theme/ff_tone.dart';
import '../settings_controller.dart';

/// An interactive Stillwater Bloom card demonstrating row density
/// (Comfortable vs Compact Ledger View) with live miniature transaction rows.
class DensityVisualizerCard extends ConsumerWidget {
  final AppSettings settings;

  const DensityVisualizerCard({super.key, required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ff = context.ff;
    final isDense = settings.isDenseMode;

    return FfCard(
      padding: const EdgeInsets.all(FfSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.density_medium_rounded,
                size: 20,
                color: ff.color.textSecondary,
              ),
              const SizedBox(width: FfSpace.xs),
              Text(
                'Row Density',
                style: ff.text.titleSm.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: FfSpace.xs),
          Text(
            'Adjust list row heights and spacing across money, accounts, and ledger screens.',
            style: ff.text.bodySm.copyWith(color: ff.color.textSecondary),
          ),
          const SizedBox(height: FfSpace.md),

          // Segmented selector
          FfSegmentedPill<bool>(
            options: const [
              FfSegmentOption(value: false, label: 'Comfortable'),
              FfSegmentOption(value: true, label: 'Ledger View'),
            ],
            selectedValue: isDense,
            onSelected: (val) {
              HapticFeedback.selectionClick();
              ref.read(settingsControllerProvider.notifier).setDenseMode(val);
            },
          ),

          const SizedBox(height: FfSpace.md),

          // Live Miniature Preview Container
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            decoration: ShapeDecoration(
              color: ff.color.surfacePage,
              shape: FfShape.of(
                FfRadius.md,
                side: BorderSide(
                  color: ff.color.borderSubtle,
                  width: FfBorderWidth.hairline,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: FfSpace.sm,
              vertical: FfSpace.xs,
            ),
            child: Column(
              children: [
                _buildMockRow(
                  context,
                  icon: Icons.restaurant_rounded,
                  tone: FfTone.expense,
                  title: 'Swiggy',
                  category: 'Food & Dining',
                  amount: -450.0,
                  isDense: isDense,
                ),
                Divider(
                  height: 1,
                  thickness: FfBorderWidth.hairline,
                  color: ff.color.borderSubtle,
                ),
                _buildMockRow(
                  context,
                  icon: Icons.payments_rounded,
                  tone: FfTone.income,
                  title: 'Acme Corp',
                  category: 'Salary Credit',
                  amount: 85000.0,
                  isDense: isDense,
                ),
              ],
            ),
          ),

          const SizedBox(height: FfSpace.xs),
          Text(
            isDense
                ? 'Compact: ~8 rows visible per viewport on a typical phone.'
                : 'Comfortable: ~6 rows visible with maximum touch comfort.',
            style: ff.text.labelSm.copyWith(
              color: ff.color.textTertiary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockRow(
    BuildContext context, {
    required IconData icon,
    required FfTone tone,
    required String title,
    required String category,
    required double amount,
    required bool isDense,
  }) {
    final ff = context.ff;
    final rowPadding =
        isDense
            ? const EdgeInsets.symmetric(vertical: 6)
            : const EdgeInsets.symmetric(vertical: 12);

    return Padding(
      padding: rowPadding,
      child: Row(
        children: [
          FfIconTile(icon: icon, tone: tone),
          const SizedBox(width: FfSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: ff.text.body.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  category,
                  style: ff.text.labelSm.copyWith(
                    color: ff.color.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          FfAmountText(
            amount: amount,
            tone: tone,
            size: isDense ? FfAmountSize.sm : FfAmountSize.md,
          ),
        ],
      ),
    );
  }
}
