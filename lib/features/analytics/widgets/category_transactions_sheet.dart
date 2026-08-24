import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/formatting/currency_formatter.dart';
import '../../../core/formatting/date_formatter.dart';
import '../../../models/transaction.dart';
import '../../../shared/widgets/ff_amount_text.dart';
import '../../../shared/widgets/ff_category_tile.dart';
import '../../../shared/widgets/ff_empty_state.dart';
import '../../../shared/widgets/ff_grouped_container.dart';
import '../../../shared/widgets/ff_sheet_header.dart';
import '../../../shared/widgets/ff_source_badge.dart';
import '../../../theme/stillwater_tokens.dart';
import '../../transactions/transaction_detail_screen.dart';

/// Bottom sheet displaying all individual transactions for a category in a filtered period.
class CategoryTransactionsSheet extends StatelessWidget {
  final String categoryName;
  final String categoryIcon;
  final String categoryColor;
  final double totalAmount;
  final String periodLabel;
  final List<Transaction> transactions;

  const CategoryTransactionsSheet({
    super.key,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.totalAmount,
    required this.periodLabel,
    required this.transactions,
  });

  static Future<void> show(
    BuildContext context, {
    required String categoryName,
    required String categoryIcon,
    required String categoryColor,
    required double totalAmount,
    required String periodLabel,
    required List<Transaction> transactions,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(StillwaterTokens.radius2Xl),
        ),
      ),
      builder:
          (_) => CategoryTransactionsSheet(
            categoryName: categoryName,
            categoryIcon: categoryIcon,
            categoryColor: categoryColor,
            totalAmount: totalAmount,
            periodLabel: periodLabel,
            transactions: transactions,
          ),
    );
  }

  void _openDetail(BuildContext context, Transaction tx) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TransactionDetailScreen(transaction: tx),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            FfSheetHeader(
              title: categoryName,
              subtitle:
                  '$periodLabel · ${transactions.length} ${transactions.length == 1 ? "transaction" : "transactions"}',
              trailing: FfCategoryTile(
                iconIdentifier: categoryIcon,
                colorTokenIdentifier: categoryColor,
                size: 40,
              ),
            ),
            // Total spent summary chip
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: StillwaterTokens.spaceLg,
                vertical: StillwaterTokens.spaceXs,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: StillwaterTokens.spaceMd,
                  vertical: StillwaterTokens.spaceSm,
                ),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(
                    StillwaterTokens.radiusLg,
                  ),
                  border: Border.all(
                    color: theme.dividerColor,
                    width: StillwaterTokens.borderWidthHairline,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Spent in Period',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.formatINR(totalAmount),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: StillwaterTokens.spaceSm),
            Expanded(
              child:
                  transactions.isEmpty
                      ? Center(
                        child: FfEmptyState(
                          icon: Icons.receipt_long_outlined,
                          title: 'No transactions found',
                          description:
                              'No payments were recorded for $categoryName during this time period.',
                        ),
                      )
                      : ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(
                          StillwaterTokens.spaceLg,
                          StillwaterTokens.spaceXs,
                          StillwaterTokens.spaceLg,
                          StillwaterTokens.space3Xl,
                        ),
                        children: [
                          FfGroupedContainer(
                            children:
                                transactions.map((tx) {
                                  return InkWell(
                                    onTap: () => _openDetail(context, tx),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: StillwaterTokens.spaceMd,
                                        vertical: StillwaterTokens.spaceSm,
                                      ),
                                      child: Row(
                                        children: [
                                          FfCategoryTile(
                                            iconIdentifier: tx.categoryIcon,
                                            colorTokenIdentifier:
                                                tx.categoryColor,
                                            size: 36,
                                          ),
                                          const SizedBox(
                                            width: StillwaterTokens.spaceSm,
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  tx.merchant,
                                                  style: theme
                                                      .textTheme
                                                      .titleSmall
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(
                                                  height:
                                                      StillwaterTokens.space3Xs,
                                                ),
                                                Row(
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        DateFormatter.formatTransactionDate(
                                                          tx.date,
                                                        ),
                                                        style: theme
                                                            .textTheme
                                                            .bodySmall
                                                            ?.copyWith(
                                                              fontSize: 11,
                                                              color:
                                                                  theme
                                                                      .colorScheme
                                                                      .secondary,
                                                            ),
                                                        maxLines: 1,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width:
                                                          StillwaterTokens
                                                              .spaceXs,
                                                    ),
                                                    Flexible(
                                                      child: FfSourceBadge(
                                                        source: tx.source,
                                                        sourceName:
                                                            tx.sourceName,
                                                        isMerged:
                                                            tx
                                                                .mergedSources
                                                                .length >
                                                            1,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            width: StillwaterTokens.spaceSm,
                                          ),
                                          FfAmountText(
                                            amount: tx.amount,
                                            type: tx.type,
                                            size: FfAmountSize.md,
                                            showSign: true,
                                          ),
                                          const SizedBox(
                                            width: StillwaterTokens.space2Xs,
                                          ),
                                          Icon(
                                            Icons.chevron_right_rounded,
                                            size: 16,
                                            color: theme.colorScheme.outline,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ],
                      ),
            ),
          ],
        );
      },
    );
  }
}
