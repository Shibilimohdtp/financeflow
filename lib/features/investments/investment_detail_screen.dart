import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/investment.dart';
import '../../repositories/account_repository.dart';
import '../../repositories/investment_repository.dart';
import '../../shared/widgets/ff_amount_field.dart';
import '../../shared/widgets/ff_amount_hero.dart';
import '../../shared/widgets/ff_amount_text.dart';
import '../../shared/widgets/ff_app_bar.dart';
import '../../shared/widgets/ff_asset_type_tiles.dart';
import '../../shared/widgets/ff_badge.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_dialog.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_icon_tile.dart';
import '../../shared/widgets/ff_row.dart';
import '../../shared/widgets/ff_section_header.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_sheet_footer.dart';
import '../../shared/widgets/ff_sheet_header.dart';
import '../../shared/widgets/ff_stat_tile.dart';
import '../../shared/widgets/ff_surfaces.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';
import 'add_edit_investment_sheet.dart';
import 'investments_controller.dart';

/// The Stillwater Bloom investment holding detail screen (Pattern D).
class InvestmentDetailScreen extends ConsumerWidget {
  const InvestmentDetailScreen({super.key, required this.investment});

  final Investment investment;

  void _edit(BuildContext context, Investment currentInv) {
    showFfSheet(
      context,
      builder: (_) => AddEditInvestmentSheet(initialInvestment: currentInv),
    );
  }

  Future<void> _updateValuation(
    BuildContext context,
    WidgetRef ref,
    Investment currentInv,
  ) async {
    final controller = TextEditingController(
      text: FfAmountField.formatInput(currentInv.currentValue),
    );

    final confirmed = await showFfSheet<bool>(
      context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final parsedNewVal =
                CurrencyFormatter.parse(controller.text) ??
                currentInv.currentValue;
            final delta = parsedNewVal - currentInv.currentValue;
            final isGain = delta >= 0;
            final pctDelta =
                currentInv.currentValue > 0
                    ? (delta / currentInv.currentValue) * 100.0
                    : 0.0;
            final deltaSign = isGain ? '+' : '';

            String consequence;
            if (delta == 0) {
              consequence =
                  'Valuation unchanged at ${CurrencyFormatter.formatAmount(currentInv.currentValue)}';
            } else {
              consequence =
                  'Valuation shifts by $deltaSign${CurrencyFormatter.formatAmount(delta)} ($deltaSign${pctDelta.toStringAsFixed(1)}%)';
            }

            return FfSheet(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FfSheetHeader(
                  title: 'Update value',
                  subtitle: 'What ${currentInv.name} is worth today',
                ),
                FfSheetBody(
                  children: [
                    FfAmountHero(
                      controller: controller,
                      autofocus: true,
                      label: 'Current value',
                      tone: FfTone.investment,
                      groupDigits: true,
                      consequence: consequence,
                      consequenceIcon:
                          delta == 0
                              ? Icons.horizontal_rule_rounded
                              : (isGain
                                  ? Icons.trending_up_rounded
                                  : Icons.trending_down_rounded),
                      onChanged: (_) => setSheetState(() {}),
                    ),
                  ],
                ),
                FfSheetFooter(
                  primaryLabel: 'Save value',
                  onPrimaryPressed: () => Navigator.of(ctx).pop(true),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed == true && context.mounted) {
      final newVal =
          CurrencyFormatter.parse(controller.text) ?? currentInv.currentValue;
      await ref
          .read(investmentsControllerProvider.notifier)
          .updateValuation(currentInv.id, newVal);
      if (context.mounted) {
        FfToast.show(context, message: 'Valuation updated on this device.');
      }
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Investment currentInv,
  ) async {
    final confirmed = await FfDialog.confirm(
      context,
      title: 'Delete Investment?',
      message:
          'Remove "${currentInv.name}" from your local portfolio? Linked ledger entries will be kept as unlinked historical investment movements.',
      confirmLabel: 'Delete',
      destructive: true,
    );

    if (confirmed == true && context.mounted) {
      await ref
          .read(investmentsControllerProvider.notifier)
          .deleteInvestment(currentInv.id);
      if (context.mounted) {
        Navigator.of(context).pop();
        FfToast.show(context, message: 'Investment removed.');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allInvsAsync = ref.watch(allInvestmentsStreamProvider);
    final currentInv =
        allInvsAsync.value?.firstWhere(
          (i) => i.id == investment.id,
          orElse: () => investment,
        ) ??
        investment;

    final accountsAsync = ref.watch(allAccountsStreamProvider);
    final linkedAccount =
        accountsAsync.value
            ?.where((a) => a.id == currentInv.accountId)
            .firstOrNull;

    final isProfit = currentInv.isProfitable;
    final returnSign = isProfit ? '+' : '';
    final formattedReturn =
        '$returnSign${CurrencyFormatter.formatAmount(currentInv.absoluteReturn)} ($returnSign${currentInv.percentageReturn.toStringAsFixed(1)}%)';

    final unitStr =
        currentInv.quantityOrUnits.truncateToDouble() ==
                currentInv.quantityOrUnits
            ? currentInv.quantityOrUnits.toInt().toString()
            : currentInv.quantityOrUnits.toString();

    final valuationDate =
        currentInv.lastValuationDate ?? currentInv.purchaseDate;

    return Scaffold(
      appBar: FfAppBar(
        title: currentInv.name,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Investment',
            onPressed: () => _edit(context, currentInv),
          ),
          const SizedBox(width: FfSpace.sm),
        ],
      ),
      body: FfAurora(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: FfSpace.pageMargin,
            vertical: FfSpace.sm,
          ),
          children: [
            // ── 1. Valuation Dusk Hero Card ─────────────────────────────────
            FfHeroCard(
              tone: FfHeroTone.dusk,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CURRENT VALUATION',
                        style: context.ff.text.labelSm.copyWith(
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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
                    amount: currentInv.currentValue,
                    size: FfAmountSize.hero,
                    style: FfAmountStyle.split,
                  ),
                  const SizedBox(height: FfSpace.md),
                  FfHeroFigures([
                    FfHeroFigure(
                      'Invested',
                      CurrencyFormatter.formatAmount(currentInv.investedAmount),
                    ),
                    FfHeroFigure('Units', unitStr),
                    FfHeroFigure(
                      'Avg Price',
                      CurrencyFormatter.formatAmount(currentInv.purchasePrice),
                    ),
                  ]),
                ],
              ),
            ),

            const SizedBox(height: FfSpace.md),

            // Quick Action to update value
            FfButton(
              label: 'Update Current Valuation',
              leadingIcon: const Icon(Icons.refresh_rounded, size: 18),
              onPressed: () => _updateValuation(context, ref, currentInv),
            ),

            const SizedBox(height: FfSpace.xl),

            // ── 2. Holding Details Group ────────────────────────────────────
            const FfSectionHeader(title: 'Holding Details'),
            const SizedBox(height: FfSpace.xs),
            FfGroupedContainer(
              children: [
                FfRow(
                  leading: FfIconTile(
                    icon: FfAssetTypeTiles.iconFor(currentInv.assetType),
                    tone: FfTone.investment,
                  ),
                  title: 'Asset Class',
                  detail: currentInv.assetType.displayName,
                ),
                FfRow(
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: 'Purchase Date',
                  detail: DateFormatter.formatFullDate(currentInv.purchaseDate),
                ),
                FfRow(
                  leading: const Icon(Icons.history_toggle_off_rounded),
                  title: 'Last Valued',
                  detail: DateFormatter.formatShortDate(valuationDate),
                ),
                FfRow(
                  leading: const Icon(Icons.account_balance_outlined),
                  title: 'Source Account',
                  detail: linkedAccount?.name ?? 'Not specified',
                ),
                if (currentInv.notes?.isNotEmpty ?? false)
                  FfRow(
                    leading: const Icon(Icons.notes_rounded),
                    title: 'Notes',
                    detail: currentInv.notes!,
                  ),
              ],
            ),

            const SizedBox(height: FfSpace.xl),

            // ── 3. Manage Holding Actions ───────────────────────────────────
            const FfSectionHeader(title: 'Manage Holding'),
            const SizedBox(height: FfSpace.xs),
            Row(
              children: [
                Expanded(
                  child: FfButton(
                    label: 'Edit Details',
                    variant: FfButtonVariant.outlined,
                    leadingIcon: const Icon(Icons.edit_outlined, size: 16),
                    onPressed: () => _edit(context, currentInv),
                  ),
                ),
                const SizedBox(width: FfSpace.md),
                Expanded(
                  child: FfButton(
                    label: 'Delete Holding',
                    variant: FfButtonVariant.destructive,
                    leadingIcon: const Icon(
                      Icons.delete_outline_rounded,
                      size: 16,
                    ),
                    onPressed: () => _delete(context, ref, currentInv),
                  ),
                ),
              ],
            ),

            const SizedBox(height: FfSpace.x4l),
          ],
        ),
      ),
    );
  }
}
