import 'package:flutter/material.dart';

import '../../../core/formatting/date_formatter.dart';
import '../../../models/transaction.dart';
import '../../../shared/widgets/ff_amount_text.dart';
import '../../../shared/widgets/ff_card.dart';
import '../../../shared/widgets/ff_category_tile.dart';
import '../../../shared/widgets/ff_divider.dart';
import '../../../shared/widgets/ff_empty_state.dart';
import '../../../shared/widgets/ff_grouped_container.dart';
import '../../../shared/widgets/ff_section_header.dart';
import '../../../shared/widgets/ff_source_badge.dart';
import '../../../theme/ff.dart';
import '../../../theme/ff_tone.dart';

class HomeRecentTransactions extends StatelessWidget {
  final List<Transaction> transactions;
  final bool isPrivacyBlur;
  final VoidCallback onViewAll;
  final VoidCallback onAddTransaction;
  final ValueChanged<Transaction> onOpenDetail;

  const HomeRecentTransactions({
    super.key,
    required this.transactions,
    required this.isPrivacyBlur,
    required this.onViewAll,
    required this.onAddTransaction,
    required this.onOpenDetail,
  });

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FfSpace.pageMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FfSectionHeader(
            title: 'Recent transactions',
            padding: FfSectionHeader.sectionPadding,
            trailing: FfSectionLink(
              label: 'See all',
              semanticLabel: 'See all transactions',
              onPressed: onViewAll,
            ),
          ),
          if (transactions.isEmpty)
            FfCard(
              density: FfDensity.compact,
              padding: const EdgeInsets.all(FfSpace.lg),
              child: FfEmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No transactions yet',
                description:
                    'Add your first expense or income to start organizing your finances offline.',
                actionLabel: 'Add Transaction',
                onAction: onAddTransaction,
              ),
            )
          else
            FfGroupedContainer(
              dividerInset: FfRowLeading.tile,
              children: [
                for (final tx in transactions)
                  Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      onTap: () => onOpenDetail(tx),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: FfSpace.md,
                          vertical: FfSpace.sm,
                        ),
                        child: Row(
                          children: [
                            FfCategoryTile(
                              iconIdentifier: tx.categoryIcon,
                              colorTokenIdentifier: tx.categoryColor,
                              size: 40,
                            ),
                            const SizedBox(width: FfSpace.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    tx.merchant.isNotEmpty
                                        ? tx.merchant
                                        : tx.categoryName,
                                    style: ff.text.titleSm,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: FfSpace.x3s),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          DateFormatter.formatTransactionDate(
                                            tx.date,
                                          ),
                                          style: ff.text.labelSm.copyWith(
                                            color: ff.color.textSecondary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: FfSpace.xs),
                                      Flexible(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: FfSourceBadge(
                                            source: tx.source,
                                            sourceName: tx.sourceName,
                                            isMerged:
                                                tx.mergedSources.length > 1,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: FfSpace.sm),
                            FfAmountText(
                              amount:
                                  tx.type == TransactionType.income
                                      ? tx.amount
                                      : -tx.amount,
                              size: FfAmountSize.sm,
                              style: FfAmountStyle.inline,
                              isBlurred: isPrivacyBlur,
                              tone:
                                  tx.type == TransactionType.income
                                      ? FfTone.income
                                      : FfTone.neutral,
                              showSign: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
