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
import '../../theme/stillwater_typography.dart';
import 'add_edit_investment_sheet.dart';
import 'investment_detail_screen.dart';
import 'investments_controller.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_app_bar.dart';
import '../../shared/widgets/ff_divider.dart';
import '../../shared/widgets/ff_row.dart';
import '../../shared/widgets/ff_progress.dart';
import '../../theme/ff.dart';

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
            padding: EdgeInsets.only(right: FfSpace.lg),
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
              FfSpace.lg,
              FfSpace.md,
              FfSpace.lg,
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
                          style: context.ff.text.labelSm.copyWith(
                            color: context.ff.color.secondary,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (summary.totalInvested > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: FfSpace.sm,
                              vertical: FfSpace.x3s,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  summary.isProfitable
                                      ? context.ff.color.moneyIncomeContainer
                                      : context.ff.color.moneyExpenseContainer,
                              borderRadius: BorderRadius.circular(
                                FfRadius.full,
                              ),
                            ),
                            child: Text(
                              '${summary.isProfitable ? '+' : ''}${summary.percentageReturn.toStringAsFixed(1)}%',
                              style: context.ff.text.labelSm.copyWith(
                                color:
                                    summary.isProfitable
                                        ? context.ff.color.moneyIncome
                                        : context.ff.color.moneyExpense,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: FfSpace.xs),
                    Text(
                      CurrencyFormatter.formatAmount(summary.totalCurrentValue),
                      style: StillwaterTypography.numHero(
                        color: context.ff.color.textPrimary,
                      ),
                    ),
                    const SizedBox(height: FfSpace.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Invested: ${CurrencyFormatter.formatAmount(summary.totalInvested)}',
                          style: context.ff.text.bodySm.copyWith(
                            color: context.ff.color.secondary,
                          ),
                        ),
                        Text(
                          '${summary.isProfitable ? '+' : ''}${CurrencyFormatter.formatAmount(summary.absoluteReturn)} returns',
                          style: context.ff.text.bodySm.copyWith(
                            color:
                                summary.isProfitable
                                    ? context.ff.color.moneyIncome
                                    : context.ff.color.moneyExpense,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: FfSpace.lg),

              if (investments.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: FfSpace.x2l),
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
                    padding: const EdgeInsets.all(FfSpace.md),
                    child: Column(
                      children: [
                        for (
                          int i = 0;
                          i < summary.allocationSlices.length;
                          i++
                        ) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: FfSpace.x2s,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    summary.allocationSlices[i].label,
                                    style: context.ff.text.body.copyWith(
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
                                    style: context.ff.text.bodySm.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: FfSpace.sm,
                                    vertical: FfSpace.x3s,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        theme
                                            .colorScheme
                                            .surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(
                                      FfRadius.sm,
                                    ),
                                  ),
                                  child: Text(
                                    '${summary.allocationSlices[i].percentage}%',
                                    style: context.ff.text.labelSm.copyWith(
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
                  const SizedBox(height: FfSpace.lg),
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
                            width: FfRowTokens.iconTile,
                            height: FfRowTokens.iconTile,
                            decoration: BoxDecoration(
                              color: context.ff.color.actionPrimaryContainer
                                  .withValues(alpha: FfTint.strong.alpha),
                              borderRadius: BorderRadius.circular(FfRadius.sm),
                            ),
                            child: Icon(
                              _getInvestmentTypeIcon(inv.assetType),
                              size: 20,
                              color: context.ff.color.actionPrimary,
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
                                style: context.ff.text.labelSm.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isProfit
                                          ? context.ff.color.moneyIncome
                                          : context.ff.color.moneyExpense,
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
                padding: EdgeInsets.all(FfSpace.x4l),
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
