import 'package:flutter/material.dart';

import '../../../services/budgets/budget_engine.dart';
import '../../../shared/widgets/ff_divider.dart';
import '../../../shared/widgets/ff_grouped_container.dart';
import '../../../shared/widgets/ff_section_header.dart';
import '../../../theme/ff.dart';
import '../budget_format.dart';
import 'budget_row.dart';

/// One group of budgets (Essentials, Lifestyle, Other, or "Other periods"):
/// a sentence-case header with the group's spent-of-plan figure, then its
/// budgets, most urgent first, in one compact card.
class BudgetGroupSection extends StatelessWidget {
  const BudgetGroupSection({
    super.key,
    required this.title,
    required this.results,
    required this.isPrivacyBlur,
    required this.onOpen,
    this.showTotals = true,
    this.showPeriod = false,
  });

  final String title;
  final List<BudgetPeriodResult> results;
  final bool isPrivacyBlur;
  final void Function(BudgetPeriodResult result) onOpen;

  /// The header's "₹9,610 of ₹16,000"; off for mixed periods.
  final bool showTotals;
  final bool showPeriod;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final spent = results.fold<int>(0, (s, r) => s + r.spentMinor);
    final limit = results.fold<int>(0, (s, r) => s + r.limitMinor);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FfSectionHeader(
          title: title,
          padding: const EdgeInsetsDirectional.fromSTEB(
            FfSpace.pageMargin,
            0,
            FfSpace.pageMargin,
            FfSpace.xs,
          ),
          trailing:
              showTotals && !isPrivacyBlur
                  ? Text(
                    '${BudgetFormat.money(spent)} of ${BudgetFormat.money(limit)}',
                    style: ff.text.label.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  )
                  : null,
        ),
        FfGroupedContainer(
          margin: const EdgeInsets.symmetric(horizontal: FfSpace.pageMargin),
          dividerInset: FfRowLeading.tile,
          children: [
            for (final r in results)
              BudgetRow(
                key: ValueKey('budget-row-${r.budget.id}'),
                result: r,
                isPrivacyBlur: isPrivacyBlur,
                showPeriod: showPeriod,
                onTap: () => onOpen(r),
              ),
          ],
        ),
      ],
    );
  }
}
