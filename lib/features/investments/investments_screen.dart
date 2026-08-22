import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../models/investment.dart';
import '../../repositories/investment_repository.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../theme/stillwater_tokens.dart';
import 'add_edit_investment_sheet.dart';
import 'investment_detail_screen.dart';
import 'investments_controller.dart';

class InvestmentsScreen extends ConsumerWidget {
  const InvestmentsScreen({super.key});

  void _openAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AddEditInvestmentSheet(),
    );
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
      appBar: AppBar(
        title: const Text('Investments'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: StillwaterTokens.spaceLg),
            child: Center(child: FfPrivacyBadge(label: 'Manual-First')),
          ),
        ],
      ),
      body: invsAsync.when(
        data: (investments) {
          return ListView(
            padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
            children: [
              // Portfolio Hero Card
              FfCard(
                variant: FfCardVariant.elevated,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Portfolio Value',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: StillwaterTokens.space2Xs),
                    Text(
                      CurrencyFormatter.formatINR(summary.totalCurrentValue),
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: StillwaterTokens.spaceSm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Invested: ${CurrencyFormatter.formatINR(summary.totalInvested)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                summary.isProfitable
                                    ? context.secColors.verified.withValues(
                                      alpha: 0.15,
                                    )
                                    : context.secColors.error.withValues(
                                      alpha: 0.15,
                                    ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${summary.isProfitable ? "+" : ""}${CurrencyFormatter.formatINR(summary.absoluteReturn)} (${summary.percentageReturn.toStringAsFixed(1)}%)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color:
                                  summary.isProfitable
                                      ? context.secColors.verified
                                      : context.secColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: StillwaterTokens.spaceSm),

              // Disclaimer Badge
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: StillwaterTokens.space2Xs,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: StillwaterTokens.space2Xs),
                    Expanded(
                      child: Text(
                        'Values stay as entered by you. FinanceFlow does not fetch market prices.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: StillwaterTokens.spaceLg),

              if (investments.isEmpty)
                Center(
                  child: Padding(
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
                  ),
                )
              else ...[
                // Asset Allocation Breakdown
                if (summary.allocationSlices.isNotEmpty) ...[
                  Text('Asset Allocation', style: theme.textTheme.titleMedium),
                  const SizedBox(height: StillwaterTokens.spaceSm),
                  FfCard(
                    child: Column(
                      children: [
                        ...summary.allocationSlices.map((slice) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: StillwaterTokens.space2Xs,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    slice.label,
                                    style: theme.textTheme.titleSmall,
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    CurrencyFormatter.formatINR(
                                      slice.totalValue,
                                    ),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${slice.percentage}%',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: StillwaterTokens.spaceLg),
                ],

                // Holdings List
                Text(
                  'Holdings (${investments.length})',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: StillwaterTokens.spaceSm),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: investments.length,
                  separatorBuilder:
                      (_, __) =>
                          const SizedBox(height: StillwaterTokens.spaceSm),
                  itemBuilder: (context, index) {
                    final inv = investments[index];
                    return FfCard(
                      onTap: () => _openDetail(context, inv),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.trending_up_rounded,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: StillwaterTokens.spaceMd),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  inv.name,
                                  style: theme.textTheme.titleMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${inv.assetType.displayName} · ${inv.quantityOrUnits} units',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                CurrencyFormatter.formatINR(inv.currentValue),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${inv.isProfitable ? "+" : ""}${inv.percentageReturn.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      inv.isProfitable
                                          ? context.secColors.verified
                                          : context.secColors.error,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'investments_add_fab',
        onPressed: () => _openAddSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Investment'),
      ),
    );
  }
}
