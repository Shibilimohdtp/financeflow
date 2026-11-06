import 'package:flutter/material.dart';
import '../../../shared/widgets/ff_card.dart';
import '../../../core/formatting/date_formatter.dart';
import '../../../models/transaction.dart';
import '../../../shared/widgets/ff_amount_text.dart';
import '../../../shared/widgets/ff_category_tile.dart';
import '../../../shared/widgets/ff_empty_state.dart';
import '../../../shared/widgets/ff_source_badge.dart';
import '../../../shared/widgets/ff_divider.dart';
import '../../../theme/ff.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FfSpace.pageMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Recent Transactions',
                  style: context.ff.text.titleSm.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: onViewAll,
                child: const Text('View all'),
              ),
            ],
          ),
          const SizedBox(height: FfSpace.xs),
          if (transactions.isEmpty)
            Container(
              padding: const EdgeInsets.all(FfSpace.lg),
              decoration: FfCard.decorationOf(
                context,
                density: FfDensity.compact,
              ),
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
            Container(
              decoration: FfCard.decorationOf(
                context,
                density: FfDensity.compact,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                separatorBuilder: (context, index) => const FfDivider(),
                itemBuilder: (context, index) {
                  final tx = transactions[index];
                  return InkWell(
                    onTap: () => onOpenDetail(tx),
                    borderRadius: BorderRadius.vertical(
                      top:
                          index == 0
                              ? const Radius.circular(FfRadius.lg)
                              : Radius.zero,
                      bottom:
                          index == transactions.length - 1
                              ? const Radius.circular(FfRadius.lg)
                              : Radius.zero,
                    ),
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
                            size: 36,
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
                                  style: context.ff.text.titleSm.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
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
                                        style: context.ff.text.bodySm.copyWith(
                                          fontSize: 11,
                                          color: context.ff.color.secondary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: FfSpace.xs),
                                    Flexible(
                                      child: FfSourceBadge(
                                        source: tx.source,
                                        sourceName: tx.sourceName,
                                        isMerged: tx.mergedSources.length > 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: FfSpace.sm),
                          FfAmountText(
                            amount: tx.amount,
                            type: tx.type,
                            size: FfAmountSize.md,
                            isBlurred: isPrivacyBlur,
                            showSign: true,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
