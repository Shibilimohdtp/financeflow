import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/investment.dart';
import '../../shared/widgets/ff_amount_field.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_confirm_dialog.dart';
import '../../shared/widgets/ff_snackbar.dart';
import '../../theme/stillwater_tokens.dart';
import 'add_edit_investment_sheet.dart';
import 'investments_controller.dart';

class InvestmentDetailScreen extends ConsumerWidget {
  final Investment investment;

  const InvestmentDetailScreen({super.key, required this.investment});

  void _edit(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddEditInvestmentSheet(initialInvestment: investment),
    );
  }

  Future<void> _updateValue(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(
      text: investment.currentValue.toStringAsFixed(2),
    );
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Update Current Valuation'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter the latest valuation for "${investment.name}".',
                  style: Theme.of(ctx).textTheme.bodySmall,
                ),
                const SizedBox(height: StillwaterTokens.spaceMd),
                FfAmountField(
                  controller: controller,
                  labelText: 'Current Value (₹)',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Update'),
              ),
            ],
          ),
    );

    if (confirmed == true && context.mounted) {
      final newVal =
          double.tryParse(controller.text.trim()) ?? investment.currentValue;
      await ref
          .read(investmentsControllerProvider.notifier)
          .updateValuation(investment.id, newVal);
      if (context.mounted) {
        Navigator.of(context).pop();
        FfSnackbar.show(context, message: 'Valuation updated.');
      }
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await FfConfirmDialog.show(
      context,
      title: 'Delete Investment?',
      message:
          'Are you sure you want to remove "${investment.name}" from your portfolio?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      await ref
          .read(investmentsControllerProvider.notifier)
          .deleteInvestment(investment.id);
      if (context.mounted) {
        Navigator.of(context).pop();
        FfSnackbar.show(context, message: 'Investment deleted.');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(
        title: Text(investment.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () => _edit(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Delete',
            onPressed: () => _delete(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
        children: [
          // Current Value Hero Card
          FfCard(
            variant: FfCardVariant.elevated,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Current Valuation (User Entered)',
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
                            investment.isProfitable
                                ? context.secColors.verified.withValues(
                                  alpha: 0.15,
                                )
                                : context.secColors.error.withValues(
                                  alpha: 0.15,
                                ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${investment.isProfitable ? "+" : ""}${investment.percentageReturn.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color:
                              investment.isProfitable
                                  ? context.secColors.verified
                                  : context.secColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: StillwaterTokens.spaceXs),
                Text(
                  CurrencyFormatter.formatINR(investment.currentValue),
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: StillwaterTokens.spaceXs),
                Text(
                  'Returns: ${investment.isProfitable ? "+" : ""}${CurrencyFormatter.formatINR(investment.absoluteReturn)} · Invested: ${CurrencyFormatter.formatINR(investment.investedAmount)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color:
                        investment.isProfitable
                            ? context.secColors.verified
                            : context.secColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.spaceLg),

          // Details List
          FfCard(
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Asset Class'),
                  trailing: Text(
                    investment.assetType.displayName,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Units / Quantity'),
                  trailing: Text(
                    '${investment.quantityOrUnits}',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Purchase Price per Unit'),
                  trailing: Text(
                    CurrencyFormatter.formatINR(investment.purchasePrice),
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Purchase Date'),
                  trailing: Text(
                    DateFormatter.formatFullDate(investment.purchaseDate),
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                if (investment.lastValuationDate != null) ...[
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Last Valuation Updated'),
                    trailing: Text(
                      DateFormatter.formatTransactionDate(
                        investment.lastValuationDate!,
                      ),
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.spaceLg),

          // Honest Pricing Notice
          FfCard(
            variant: FfCardVariant.tinted,
            child: Row(
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 18,
                  color: context.secColors.verified,
                ),
                const SizedBox(width: StillwaterTokens.spaceSm),
                Expanded(
                  child: Text(
                    'Values stay as entered by you. FinanceFlow does not fetch market prices.',
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: StillwaterTokens.space2Xl),

          FfButton(
            label: 'Update Current Valuation',
            variant: FfButtonVariant.filled,
            onPressed: () => _updateValue(context, ref),
          ),
        ],
      ),
    );
  }
}
