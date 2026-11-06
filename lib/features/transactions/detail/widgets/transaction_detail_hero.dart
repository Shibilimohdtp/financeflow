import 'package:flutter/material.dart';

import '../../../../core/formatting/date_formatter.dart';
import '../../../../models/account.dart';
import '../../../../models/transaction.dart';
import '../../../../shared/widgets/ff_amount_text.dart';
import '../../../../shared/widgets/ff_category_tile.dart';
import '../../../../shared/widgets/ff_icon_tile.dart';
import '../../../../shared/widgets/ff_stat_tile.dart';
import '../../../../shared/widgets/ff_surfaces.dart';
import '../../../../theme/ff.dart';
import '../../../../theme/ff_tone.dart';

/// The Pattern D type-reactive Hero card for [TransactionDetailScreen].
///
/// Dynamically adapts to:
/// - Expense: Sand hero with neutral/ink split amount.
/// - Income: Sand hero with spark green income tinting.
/// - Transfer: Dusk hero with account flow representation.
class TransactionDetailHero extends StatelessWidget {
  final Transaction transaction;
  final Account? account;
  final Account? toAccount;
  final bool isPrivacyBlur;

  const TransactionDetailHero({
    super.key,
    required this.transaction,
    this.account,
    this.toAccount,
    this.isPrivacyBlur = false,
  });

  String _formatOverline() {
    if (transaction.type == TransactionType.transfer) {
      return 'ACCOUNT TRANSFER';
    }
    if (transaction.linkedSubscriptionId != null) {
      return 'SUBSCRIPTION PAYMENT';
    }
    if (transaction.linkedLoanId != null) {
      return 'LOAN REPAYMENT';
    }
    if (transaction.linkedMoneyRecordId != null) {
      return 'PERSONAL DEBT LEDGER';
    }
    if (transaction.type == TransactionType.income) {
      return 'INCOME · ${transaction.categoryName.toUpperCase()}';
    }
    return 'EXPENSE · ${transaction.categoryName.toUpperCase()}';
  }

  Widget _buildLeading(BuildContext context) {
    if (transaction.type == TransactionType.transfer) {
      return const FfIconTile(
        icon: Icons.swap_horiz_rounded,
        tone: FfTone.transfer,
      );
    }

    if (transaction.categoryIcon.isNotEmpty &&
        transaction.categoryColor.isNotEmpty) {
      return FfCategoryTile(
        iconIdentifier: transaction.categoryIcon,
        colorTokenIdentifier: transaction.categoryColor,
        size: 48,
      );
    }

    return FfIconTile(
      icon:
          transaction.type == TransactionType.income
              ? Icons.south_west_rounded
              : Icons.north_east_rounded,
      tone:
          transaction.type == TransactionType.income
              ? FfTone.income
              : FfTone.expense,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final isTransfer = transaction.type == TransactionType.transfer;
    final isIncome = transaction.type == TransactionType.income;

    final heroTone =
        isTransfer
            ? FfHeroTone.dusk
            : (isIncome ? FfHeroTone.sand : FfHeroTone.sand);

    return FfHeroCard(
      tone: heroTone,
      leading: _buildLeading(context),
      title: _formatOverline(),
      subtitle: DateFormatter.formatDetailDate(transaction.date),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Main Hero Amount ───────────────────────────────────────
          FfAmountText(
            amount: transaction.amount,
            type: transaction.type,
            size: FfAmountSize.hero,
            style: FfAmountStyle.split,
            showSign: !isTransfer,
            isBlurred: isPrivacyBlur,
          ),

          if (isTransfer && account != null && toAccount != null) ...[
            const SizedBox(height: FfSpace.xs),
            Row(
              children: [
                Text(
                  account!.name,
                  style: ff.text.bodySm.copyWith(
                    color: ff.color.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: FfSpace.xs),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 14,
                  color: ff.color.textTertiary,
                ),
                const SizedBox(width: FfSpace.xs),
                Text(
                  toAccount!.name,
                  style: ff.text.bodySm.copyWith(
                    color: ff.color.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: FfSpace.md),

          // ── Hero Figures Row ───────────────────────────────────────
          FfHeroFigures([
            FfHeroFigure(
              'Account',
              account != null
                  ? '${account!.name} ${account!.maskedIdentifier ?? ''}'.trim()
                  : 'Main Account',
            ),
            if (isTransfer)
              FfHeroFigure(
                'Destination',
                toAccount != null
                    ? '${toAccount!.name} ${toAccount!.maskedIdentifier ?? ''}'
                        .trim()
                    : 'Account',
              )
            else
              FfHeroFigure('Category', transaction.categoryName),
            FfHeroFigure(
              'Verification',
              transaction.isReviewed ? 'Verified' : 'On-device',
            ),
          ]),
        ],
      ),
    );
  }
}
