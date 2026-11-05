import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../models/investment.dart';
import '../../repositories/investment_repository.dart';
import '../../shared/widgets/ff_amount_text.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_section_header.dart';
import '../../theme/stillwater_tokens.dart';
import '../../theme/stillwater_typography.dart';
import 'add_edit_investment_sheet.dart';
import 'investment_detail_screen.dart';
import 'investments_controller.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_app_bar.dart';
import '../../shared/widgets/ff_divider.dart';
import '../../shared/widgets/ff_row.dart';
import '../../shared/widgets/ff_progress.dart';

class InvestmentsScreen extends ConsumerWidget {
  const InvestmentsScreen({super.key});

  void _openAddSheet(BuildContext context) {
    showFfSheet(context, builder: (_) => const AddEditInvestmentSheet());
  }

  void _openDetail(BuildContext context, Investment inv) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => InvestmentDetailScreen(investment: inv),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final summary = ref.watch(portfolioSummaryProvider);
    final invsAsync = ref.watch(allInvestmentsStreamProvider);

    return Scaffold(
      appBar: FfAppBar(
        title: 'Investment Portfolio',
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: StillwaterTokens.spaceLg),
            child: Center(
              child: FfPrivacyBadge(label: 'Manual-First', iconOnly: true),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'investments_fab',
        tooltip: 'Add investment',
        onPressed: () => _openAddSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Investment'),
      ),
      body: invsAsync.when(
        data: (investments) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              StillwaterTokens.spaceLg,
              StillwaterTokens.spaceMd,
              StillwaterTokens.spaceLg,
              104,
            ),
            children: [
              // ── 1. Portfolio Value Hero ─────────────────────────────────
              FfCard(
                variant: FfCardVariant.elevated,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TOTAL PORTFOLIO VALUE',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.secondary,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (summary.totalInvested > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: StillwaterTokens.spaceSm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  summary.isProfitable
                                      ? context.finColors.incomeContainer
                                      : context.finColors.expenseContainer,
                              borderRadius: BorderRadius.circular(
                                StillwaterTokens.radiusFull,
                              ),
                            ),
                            child: Text(
                              '${summary.isProfitable ? '+' : ''}${summary.percentageReturn.toStringAsFixed(1)}%',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color:
                                    summary.isProfitable
                                        ? context.finColors.income
                                        : context.finColors.expense,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: StillwaterTokens.spaceXs),
                    Text(
                      CurrencyFormatter.formatAmount(summary.totalCurrentValue),
                      style: StillwaterTypography.numHero(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: StillwaterTokens.spaceSm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Invested: ${CurrencyFormatter.formatAmount(summary.totalInvested)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        Text(
                          '${summary.isProfitable ? '+' : ''}${CurrencyFormatter.formatAmount(summary.absoluteReturn)} returns',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color:
                                summary.isProfitable
                                    ? context.finColors.income
                                    : context.finColors.expense,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: StillwaterTokens.spaceLg),

              if (investments.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: StillwaterTokens.space2Xl,
                  ),
                  child: FfEmptyState(
                    icon: Icons.show_chart_rounded,
                    title: 'No investments recorded',
                    description:
                        'Track stocks, mutual funds, gold, fixed deposits, and PPF with manual on-device valuations.',
                    actionLabel: 'Add Investment',
                    onAction: () => _openAddSheet(context),
                  ),
                )
              else ...[
                // ── 2. Asset Allocation Breakdown ───────────────────────────
                if (summary.allocationSlices.isNotEmpty) ...[
                  const FfSectionHeader(title: 'Asset Allocation'),
                  FfCard(
                    padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
                    child: Column(
                      children: [
                        for (
                          int i = 0;
                          i < summary.allocationSlices.length;
                          i++
                        ) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: StillwaterTokens.space2Xs,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    summary.allocationSlices[i].label,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    CurrencyFormatter.formatAmount(
                                      summary.allocationSlices[i].totalValue,
                                    ),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: StillwaterTokens.spaceSm,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        theme
                                            .colorScheme
                                            .surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(
                                      StillwaterTokens.radiusSm,
                                    ),
                                  ),
                                  child: Text(
                                    '${summary.allocationSlices[i].percentage}%',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (i < summary.allocationSlices.length - 1)
                            const FfDivider(),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: StillwaterTokens.spaceLg),
                ],

                // ── 3. Holdings List ────────────────────────────────────────
                FfSectionHeader(title: 'Holdings (${investments.length})'),
                FfGroupedContainer(
                  children:
                      investments.map((inv) {
                        final profit = inv.currentValue - inv.investedAmount;
                        final isProfit = profit >= 0;

                        return FfRow(
                          leading: Container(
                            width: StillwaterTokens.iconTileSize,
                            height: StillwaterTokens.iconTileSize,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer
                                  .withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(
                                StillwaterTokens.radiusSm,
                              ),
                            ),
                            child: Icon(
                              _getInvestmentTypeIcon(inv.assetType),
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          title: inv.name,
                          subtitle: inv.assetType.displayName,
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              FfAmountText(
                                amount: inv.currentValue,
                                size: FfAmountSize.sm,
                                showSign: false,
                              ),
                              Text(
                                '${isProfit ? '+' : ''}${CurrencyFormatter.formatAmount(profit)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isProfit
                                          ? context.finColors.income
                                          : context.finColors.expense,
                                ),
                              ),
                            ],
                          ),
                          onTap: () => _openDetail(context, inv),
                        );
                      }).toList(),
                ),
              ],
            ],
          );
        },
        loading:
            () => const Center(
              child: Padding(
                padding: EdgeInsets.all(StillwaterTokens.space4Xl),
                child: FfLoading(),
              ),
            ),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  static IconData _getInvestmentTypeIcon(AssetType type) {
    switch (type) {
      case AssetType.stocks:
        return Icons.candlestick_chart_outlined;
      case AssetType.mutualFunds:
        return Icons.pie_chart_outline_rounded;
      case AssetType.fixedDeposits:
      case AssetType.recurringDeposits:
        return Icons.lock_clock_outlined;
      case AssetType.gold:
        return Icons.monetization_on_outlined;
      case AssetType.ppf:
      case AssetType.nps:
        return Icons.savings_outlined;
      case AssetType.crypto:
        return Icons.currency_bitcoin_rounded;
      case AssetType.realEstate:
        return Icons.home_work_outlined;
      case AssetType.other:
        return Icons.show_chart_rounded;
    }
  }
}
