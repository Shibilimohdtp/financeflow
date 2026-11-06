import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting/currency_formatter.dart';
import '../../models/investment.dart';
import '../../repositories/investment_repository.dart';
import '../../services/investment_calculator.dart';
import '../../shared/widgets/ff_allocation_band.dart';
import '../../shared/widgets/ff_amount_text.dart';
import '../../shared/widgets/ff_asset_type_tiles.dart';
import '../../shared/widgets/ff_badge.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_icon_tile.dart';
import '../../shared/widgets/ff_navigation.dart';
import '../../shared/widgets/ff_progress.dart';
import '../../shared/widgets/ff_section_header.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_stat_tile.dart';
import '../../shared/widgets/ff_surfaces.dart';
import '../../shared/widgets/ff_page_scaffold.dart';
import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';
import 'add_edit_investment_sheet.dart';
import 'investment_detail_screen.dart';
import 'investments_controller.dart';

/// The Stillwater Bloom portfolio investments screen (Pattern C).
///
/// Features:
/// - Dusk [FfHeroCard] displaying total portfolio valuation with Geist split numerals,
///   signed returns badge, and [FfHeroFigures] (Invested, Returns, Holdings).
/// - [FfAllocationBand] showing asset-class distribution slices.
/// - [FfPillBar] for fast filtering across asset types.
/// - Tactile squircle holding cards with [FfAssetTypeTiles] iconography and
///   stale valuation indicators.
class InvestmentsScreen extends ConsumerStatefulWidget {
  const InvestmentsScreen({super.key});

  @override
  ConsumerState<InvestmentsScreen> createState() => _InvestmentsScreenState();
}

class _InvestmentsScreenState extends ConsumerState<InvestmentsScreen> {
  AssetType? _selectedAssetType;

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
  Widget build(BuildContext context) {
    final summary = ref.watch(portfolioSummaryProvider);
    final invsAsync = ref.watch(allInvestmentsStreamProvider);

    return FfPageScaffold(
      onAurora: true,
      title: 'Investments',
      subtitle: 'Portfolio, on-device',
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'investments_fab',
        tooltip: 'Add investment',
        onPressed: () => _openAddSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Investment'),
      ),
      body: invsAsync.when(
        data: (investments) {
          final active = investments.where((i) => !i.isArchived).toList();

          if (active.isEmpty) {
            return ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: FfSpace.pageMargin,
                vertical: FfSpace.lg,
              ),
              children: [
                // Hero empty portfolio
                _buildEmptyHero(context),
                const SizedBox(height: FfSpace.x3l),
                FfEmptyState(
                  icon: Icons.show_chart_rounded,
                  title: 'No investments recorded',
                  description:
                      'Track stocks, mutual funds, gold, fixed deposits, and PPF with manual on-device valuations.',
                  actionLabel: 'Add Investment',
                  onAction: () => _openAddSheet(context),
                ),
              ],
            );
          }

          // Extract unique asset types present
          final presentTypes = active.map((i) => i.assetType).toSet().toList();

          // Filter holdings
          final filtered =
              _selectedAssetType == null
                  ? active
                  : active
                      .where((i) => i.assetType == _selectedAssetType)
                      .toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              FfSpace.pageMargin,
              FfSpace.sm,
              FfSpace.pageMargin,
              112,
            ),
            children: [
              // ── 1. Portfolio Value Dusk Hero ──────────────────────────────
              _buildPortfolioHero(context, summary),
              const SizedBox(height: FfSpace.lg),

              // ── 2. Asset Allocation Breakdown ─────────────────────────────
              if (summary.allocationSlices.isNotEmpty) ...[
                const FfSectionHeader(title: 'Asset Allocation'),
                const SizedBox(height: FfSpace.xs),
                FfCard(
                  padding: const EdgeInsets.all(FfSpace.md),
                  child: FfAllocationBand(
                    slices:
                        summary.allocationSlices
                            .map(
                              (s) => FfAllocationSlice(
                                label: s.label,
                                value: s.totalValue,
                                percentage: s.percentage,
                              ),
                            )
                            .toList(),
                  ),
                ),
                const SizedBox(height: FfSpace.lg),
              ],

              // ── 3. Asset Class Filter Pills ───────────────────────────────
              if (presentTypes.length > 1) ...[
                FfPillBar<AssetType?>(
                  padding: EdgeInsets.zero,
                  values: [null, ...presentTypes],
                  selected: _selectedAssetType,
                  label: (type) {
                    if (type == null) return 'All (${active.length})';
                    final count =
                        active.where((i) => i.assetType == type).length;
                    return '${type.displayName} ($count)';
                  },
                  onSelected:
                      (type) => setState(() => _selectedAssetType = type),
                ),
                const SizedBox(height: FfSpace.md),
              ],

              // ── 4. Holdings Section ───────────────────────────────────────
              FfSectionHeader(title: 'Holdings', count: filtered.length),
              const SizedBox(height: FfSpace.xs),

              if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: FfSpace.xl),
                  child: Center(
                    child: Text(
                      'No holdings in this asset class.',
                      style: context.ff.text.bodySm.copyWith(
                        color: context.ff.color.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                for (final inv in filtered) ...[
                  _HoldingCard(
                    investment: inv,
                    onTap: () => _openDetail(context, inv),
                  ),
                  const SizedBox(height: FfSpace.xs),
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
        error:
            (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(FfSpace.lg),
                child: Text(
                  'Could not load investments: $e',
                  style: context.ff.text.body,
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildEmptyHero(BuildContext context) {
    return FfHeroCard(
      tone: FfHeroTone.dusk,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PORTFOLIO VALUE',
            style: context.ff.text.labelSm.copyWith(
              letterSpacing: 1.1,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: FfSpace.xs),
          const FfAmountText(
            amount: 0,
            size: FfAmountSize.hero,
            style: FfAmountStyle.split,
          ),
          const SizedBox(height: FfSpace.sm),
          Text(
            'Add your first holding to start tracking returns',
            style: context.ff.text.bodySm,
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioHero(BuildContext context, PortfolioSummary summary) {
    final isProfit = summary.isProfitable;
    final returnSign = isProfit ? '+' : '';
    final formattedReturn =
        '$returnSign${CurrencyFormatter.formatAmount(summary.absoluteReturn)} ($returnSign${summary.percentageReturn.toStringAsFixed(1)}%)';

    return FfHeroCard(
      tone: FfHeroTone.dusk,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PORTFOLIO VALUE',
                style: context.ff.text.labelSm.copyWith(
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (summary.totalInvested > 0)
                FfBadge(
                  label: formattedReturn,
                  tone: isProfit ? FfTone.income : FfTone.error,
                  icon:
                      isProfit
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                ),
            ],
          ),
          const SizedBox(height: FfSpace.xs),
          FfAmountText(
            amount: summary.totalCurrentValue,
            size: FfAmountSize.hero,
            style: FfAmountStyle.split,
          ),
          const SizedBox(height: FfSpace.md),
          FfHeroFigures([
            FfHeroFigure(
              'Invested',
              CurrencyFormatter.formatAmount(summary.totalInvested),
            ),
            FfHeroFigure(
              'Returns',
              '$returnSign${CurrencyFormatter.formatAmount(summary.absoluteReturn)}',
            ),
            FfHeroFigure('Holdings', '${summary.totalHoldings} assets'),
          ]),
        ],
      ),
    );
  }
}

class _HoldingCard extends StatelessWidget {
  const _HoldingCard({required this.investment, required this.onTap});

  final Investment investment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final c = ff.color;
    final profit = investment.currentValue - investment.investedAmount;
    final isProfit = profit >= 0;
    final returnSign = isProfit ? '+' : '';

    final now = DateTime.now();
    final valuationDate =
        investment.lastValuationDate ?? investment.purchaseDate;
    final daysSinceValuation = now.difference(valuationDate).inDays;
    final isStale = daysSinceValuation >= 30;

    final unitInfo =
        investment.quantityOrUnits > 1.0
            ? ' · ${investment.quantityOrUnits.truncateToDouble() == investment.quantityOrUnits ? investment.quantityOrUnits.toInt() : investment.quantityOrUnits} units'
            : '';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(FfRadius.md),
      child: FfCard(
        density: FfDensity.compact,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FfIconTile(
                  icon: FfAssetTypeTiles.iconFor(investment.assetType),
                  tone: FfTone.investment,
                ),
                const SizedBox(width: FfSpace.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        investment.name,
                        style: ff.text.title.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: FfSpace.x3s),
                      Text(
                        '${investment.assetType.displayName}$unitInfo',
                        style: ff.text.bodySm.copyWith(color: c.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: FfSpace.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FfAmountText(
                      amount: investment.currentValue,
                      size: FfAmountSize.md,
                      style: FfAmountStyle.inline,
                    ),
                    const SizedBox(height: FfSpace.x3s),
                    Text(
                      '$returnSign${CurrencyFormatter.formatAmount(profit)} ($returnSign${investment.percentageReturn.toStringAsFixed(1)}%)',
                      style: ff.text.labelSm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isProfit ? c.moneyIncome : c.moneyExpense,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (isStale) ...[
              const SizedBox(height: FfSpace.xs),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: FfSpace.sm,
                  vertical: FfSpace.x2s,
                ),
                decoration: BoxDecoration(
                  color: c.statusWarningContainer,
                  borderRadius: BorderRadius.circular(FfRadius.xs),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: c.statusWarning,
                    ),
                    const SizedBox(width: FfSpace.xs),
                    Expanded(
                      child: Text(
                        'Valued ${daysSinceValuation}d ago · Tap to update',
                        style: ff.text.labelSm.copyWith(
                          color: c.statusWarning,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
