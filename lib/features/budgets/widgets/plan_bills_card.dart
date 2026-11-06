import 'package:flutter/material.dart';

import '../../../services/budgets/committed_bills.dart';
import '../../../shared/widgets/ff_amount_text.dart';
import '../../../shared/widgets/ff_divider.dart';
import '../../../shared/widgets/ff_grouped_container.dart';
import '../../../shared/widgets/ff_row.dart';
import '../../../shared/widgets/ff_section_header.dart';
import '../../../theme/ff.dart';
import '../../../theme/ff_tone.dart';
import '../budget_format.dart';

/// The "Bills & EMIs" line (owner decision D1): money already spoken for by
/// tracked subscriptions and loans in the viewed period. It is shown apart
/// from the budgets and never reduces "safe to spend". One row per kind,
/// each opening its own screen.
class PlanBillsCard extends StatelessWidget {
  const PlanBillsCard({
    super.key,
    required this.bills,
    required this.isPrivacyBlur,
    required this.onOpenSubscriptions,
    required this.onOpenLoans,
  });

  final CommittedBills bills;
  final bool isPrivacyBlur;
  final VoidCallback onOpenSubscriptions;
  final VoidCallback onOpenLoans;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final subs =
        bills.occurrences
            .where((o) => o.kind == BillKind.subscription)
            .toList();
    final loans =
        bills.occurrences.where((o) => o.kind == BillKind.loan).toList();
    final total = bills.occurrences.fold<int>(0, (s, o) => s + o.amountMinor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FfSectionHeader(
          title: 'Bills & EMIs',
          padding: const EdgeInsetsDirectional.fromSTEB(
            FfSpace.pageMargin,
            0,
            FfSpace.pageMargin,
            FfSpace.xs,
          ),
          trailing:
              isPrivacyBlur
                  ? null
                  : Text(
                    '${BudgetFormat.money(total)} committed',
                    style: ff.text.label.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
        ),
        FfGroupedContainer(
          margin: const EdgeInsets.symmetric(horizontal: FfSpace.pageMargin),
          dividerInset: FfRowLeading.tile,
          children: [
            if (subs.isNotEmpty)
              _row(
                title: 'Subscriptions',
                icon: Icons.autorenew_rounded,
                tone: FfTone.accent,
                items: subs,
                onTap: onOpenSubscriptions,
              ),
            if (loans.isNotEmpty)
              _row(
                title: 'Loans & EMIs',
                icon: Icons.account_balance_outlined,
                tone: FfTone.debt,
                items: loans,
                onTap: onOpenLoans,
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            FfSpace.pageMargin + FfSpace.x2s,
            FfSpace.xs,
            FfSpace.pageMargin,
            0,
          ),
          child: Text(
            'Tracked on their own, so they never count against a budget '
            'or what is safe to spend.',
            style: ff.text.label,
          ),
        ),
      ],
    );
  }

  Widget _row({
    required String title,
    required IconData icon,
    required FfTone tone,
    required List<BillOccurrence> items,
    required VoidCallback onTap,
  }) {
    final amount = items.fold<int>(0, (s, o) => s + o.amountMinor);
    return FfRow(
      title: title,
      subtitle: _subtitle(items),
      icon: icon,
      iconTone: tone,
      onTap: onTap,
      trailing: FfAmountText(
        amount: BudgetFormat.major(amount),
        size: FfAmountSize.sm,
        tone: FfTone.neutral,
        showSign: false,
        isBlurred: isPrivacyBlur,
      ),
    );
  }

  /// "All 2 paid", "Home loan paid · next 5 Dec" or "1 paid · Streaming due
  /// 24 Nov". Words carry the state; nothing relies on colour.
  static String _subtitle(List<BillOccurrence> items) {
    final paid = items.where((o) => o.isPaid).length;
    final unpaid = items.where((o) => !o.isPaid).toList();
    if (unpaid.isEmpty) {
      return items.length == 1
          ? '${items.first.name} · paid'
          : 'All ${items.length} paid';
    }
    final next = unpaid.first;
    final due = '${next.name} due ${BudgetFormat.shortDate(next.dueDate)}';
    final more = unpaid.length > 1 ? ' + ${unpaid.length - 1} more' : '';
    return paid > 0 ? '$paid paid · $due$more' : '$due$more';
  }
}
