import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/investment.dart';
import '../../repositories/account_repository.dart';
import '../../repositories/investment_repository.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_sheet_footer.dart';
import '../../shared/widgets/ff_sheet_header.dart';
import 'add_edit_investment_sheet.dart';
import 'investments_controller.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../shared/widgets/ff_dialog.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_app_bar.dart';
import '../../shared/widgets/ff_divider.dart';
import '../../shared/widgets/ff_text_field.dart';
import '../../shared/widgets/ff_key_value_row.dart';
import '../../theme/ff.dart';

class InvestmentDetailScreen extends ConsumerWidget {
  final Investment investment;

  const InvestmentDetailScreen({super.key, required this.investment});

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
      text:
          currentInv.currentValue.truncateToDouble() == currentInv.currentValue
              ? currentInv.currentValue.toInt().toString()
              : currentInv.currentValue.toString(),
    );

    final confirmed = await showFfSheet<bool>(
      context,
      builder: (ctx) {
        return FfSheet(
          children: [
            FfSheetHeader(
              title: 'Update Valuation',
              subtitle:
                  'Enter current market valuation for "${currentInv.name}"',
            ),
            const FfDivider(),
            Padding(
              padding: EdgeInsets.only(
                left: FfSpace.lg,
                right: FfSpace.lg,
                top: FfSpace.md,
                bottom: FfSpace.md,
              ),
              child: FfTextField(
                controller: controller,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                label: 'Current Value',
                prefixText: '${CurrencyFormatter.currencySymbol} ',
              ),
            ),
            FfSheetFooter(
              secondaryLabel: 'Cancel',
              primaryLabel: 'Update Value',
              onSecondaryPressed: () => Navigator.of(ctx).pop(false),
              onPrimaryPressed: () => Navigator.of(ctx).pop(true),
            ),
          ],
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
    // Watch live stream
    final allInvsAsync = ref.watch(allInvestmentsStreamProvider);
    final currentInv =
        allInvsAsync.value?.firstWhere(
          (i) => i.id == investment.id,
          orElse: () => investment,
        ) ??
        investment;

    final accountsAsync = ref.watch(allAccountsStreamProvider);
    final linkedAccount = accountsAsync.value?.firstWhere(
      (a) => a.id == currentInv.accountId,
      orElse: () => null as dynamic,
    );

    return Scaffold(
      appBar: FfAppBar(
        title: currentInv.name,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Investment',
            onPressed: () => _edit(context, currentInv),
          ),
          const Padding(
            padding: EdgeInsets.only(right: FfSpace.md),
            child: Center(
              child: FfPrivacyBadge(label: '100% Local', iconOnly: true),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: FfSpace.lg,
          vertical: FfSpace.md,
        ),
        children: [
          // ── 1. Valuation Hero Card ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(FfSpace.lg),
            decoration: BoxDecoration(
              color: context.ff.color.surfaceCard,
              borderRadius: BorderRadius.circular(FfRadius.lg),
              border: Border.all(
                color: context.ff.color.borderSubtle,
                width: FfBorderWidth.hairline,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CURRENT VALUATION',
                      style: context.ff.text.labelSm.copyWith(
                        letterSpacing: 0.8,
                        color: context.ff.color.secondary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: FfSpace.sm,
                        vertical: FfSpace.x3s,
                      ),
                      decoration: BoxDecoration(
                        color:
                            currentInv.isProfitable
                                ? context.ff.color.statusSuccess.withValues(
                                  alpha: 0.15,
                                )
                                : context.ff.color.statusError.withValues(
                                  alpha: 0.15,
                                ),
                        borderRadius: BorderRadius.circular(FfRadius.full),
                      ),
                      child: Text(
                        '${currentInv.isProfitable ? "+" : ""}${CurrencyFormatter.formatAmount(currentInv.absoluteReturn)} (${currentInv.percentageReturn.toStringAsFixed(1)}%)',
                        style: context.ff.text.labelSm.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              currentInv.isProfitable
                                  ? context.ff.color.statusSuccess
                                  : context.ff.color.statusError,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: FfSpace.xs),
                Text(
                  CurrencyFormatter.formatAmount(currentInv.currentValue),
                  style: context.ff.text.headlineLg.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.ff.color.actionPrimary,
                  ),
                ),
                const SizedBox(height: FfSpace.x3s),
                Text(
                  'Cost basis: ${CurrencyFormatter.formatAmount(currentInv.investedAmount)} · Manual Entry',
                  style: context.ff.text.bodySm.copyWith(
                    color: context.ff.color.secondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: FfSpace.lg),

          // Quick Action to update value
          FfButton(
            label: 'Update Current Valuation',
            leadingIcon: const Icon(Icons.refresh_rounded, size: 18),
            onPressed: () => _updateValuation(context, ref, currentInv),
          ),

          const SizedBox(height: FfSpace.x2l),

          // ── 2. Holding Details Group ────────────────────────────────────
          _SectionLabel(label: 'Holding Details'),
          const SizedBox(height: FfSpace.xs),
          Container(
            decoration: BoxDecoration(
              color: context.ff.color.surfaceCard,
              borderRadius: BorderRadius.circular(FfRadius.lg),
              border: Border.all(
                color: context.ff.color.borderSubtle,
                width: FfBorderWidth.hairline,
              ),
            ),
            child: Column(
              children: [
                _DetailRow(
                  icon: Icons.category_outlined,
                  label: 'Asset Class',
                  value: currentInv.assetType.displayName,
                ),
                _DetailDivider(),
                _DetailRow(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Invested Cost',
                  value: CurrencyFormatter.formatAmount(
                    currentInv.investedAmount,
                  ),
                ),
                _DetailDivider(),
                _DetailRow(
                  icon: Icons.numbers_rounded,
                  label: 'Units / Quantity',
                  value:
                      currentInv.quantityOrUnits.truncateToDouble() ==
                              currentInv.quantityOrUnits
                          ? currentInv.quantityOrUnits.toInt().toString()
                          : currentInv.quantityOrUnits.toString(),
                ),
                _DetailDivider(),
                _DetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Purchase Date',
                  value: DateFormatter.formatFullDate(currentInv.purchaseDate),
                ),
                _DetailDivider(),
                _DetailRow(
                  icon: Icons.account_balance_outlined,
                  label: 'Source Account',
                  value: linkedAccount?.name ?? 'Not specified',
                  isLast: (currentInv.notes?.isEmpty ?? true),
                ),
                if (currentInv.notes?.isNotEmpty ?? false) ...[
                  _DetailDivider(),
                  _DetailRow(
                    icon: Icons.notes_rounded,
                    label: 'Notes',
                    value: currentInv.notes!,
                    isLast: true,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: FfSpace.x2l),

          // ── 3. Actions ──────────────────────────────────────────────────
          _SectionLabel(label: 'Manage Holding'),
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
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return FfKeyValueRow(icon: icon, label: label, value: value);
  }
}

class _DetailDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const FfDivider.inset(after: FfRowLeading.icon);
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: FfSpace.x2s),
      child: Text(
        label.toUpperCase(),
        style: context.ff.text.labelSm.copyWith(
          letterSpacing: 0.8,
          color: context.ff.color.secondary,
        ),
      ),
    );
  }
}
