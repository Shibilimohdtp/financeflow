import 'package:flutter/material.dart';

import '../../../core/formatting/currency_formatter.dart';
import '../../../core/formatting/date_formatter.dart';
import '../../../models/account.dart';
import '../../../models/ingestion/parsed_transaction.dart';
import '../../../models/transaction.dart';
import '../../../shared/widgets/ff_button.dart';
import '../../../shared/widgets/ff_category_tile.dart';
import '../../../shared/widgets/ff_source_badge.dart';
import '../../../theme/ff.dart';

/// Individual pending item card in the Needs Review queue.
class PendingTransactionCard extends StatelessWidget {
  const PendingTransactionCard({
    super.key,
    required this.item,
    required this.accounts,
    required this.busy,
    required this.onApprove,
    required this.onDismiss,
    required this.onEdit,
    required this.onMerge,
    required this.onKeepBoth,
  });

  final ParsedTransaction item;
  final List<Account> accounts;
  final bool busy;
  final VoidCallback onApprove;
  final VoidCallback onDismiss;
  final VoidCallback onEdit;
  final VoidCallback onMerge;
  final VoidCallback onKeepBoth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpense = item.type == TransactionType.expense;

    final account = accounts.where((a) => a.id == item.accountId).firstOrNull;
    final accountName = account?.name ?? (item.sourceName ?? 'Account');

    final merchantName =
        item.merchantDisplayName ??
        (item.normalizedMerchant.isNotEmpty
            ? item.normalizedMerchant
            : item.rawMerchant);

    Widget? statusBadge;
    if (item.isDuplicate) {
      statusBadge = Container(
        padding: const EdgeInsets.symmetric(
          horizontal: FfSpace.x2s,
          vertical: FfSpace.x3s,
        ),
        decoration: BoxDecoration(
          color: context.ff.color.statusWarningContainer,
          borderRadius: BorderRadius.circular(FfRadius.xs),
        ),
        child: Text(
          item.duplicateStatus.displayName,
          style: context.ff.text.labelSm.copyWith(
            color: context.ff.color.statusWarning,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (!item.isValid) {
      statusBadge = Container(
        padding: const EdgeInsets.symmetric(
          horizontal: FfSpace.x2s,
          vertical: FfSpace.x3s,
        ),
        decoration: BoxDecoration(
          color: context.ff.color.statusErrorContainer,
          borderRadius: BorderRadius.circular(FfRadius.xs),
        ),
        child: Text(
          'Needs details',
          style: context.ff.text.labelSm.copyWith(
            color: context.ff.color.statusError,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (item.categorizationConfidence < 0.7) {
      statusBadge = Container(
        padding: const EdgeInsets.symmetric(
          horizontal: FfSpace.x2s,
          vertical: FfSpace.x3s,
        ),
        decoration: BoxDecoration(
          color: context.ff.color.statusWarningContainer,
          borderRadius: BorderRadius.circular(FfRadius.xs),
        ),
        child: Text(
          'Confirm category',
          style: context.ff.text.labelSm.copyWith(
            color: context.ff.color.statusWarning,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: FfSpace.md),
      padding: const EdgeInsets.all(FfSpace.md),
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
          // Row 1: Source badge, date, and status tag
          Wrap(
            spacing: FfSpace.sm,
            runSpacing: FfSpace.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FfSourceBadge(source: item.source, sourceName: item.sourceName),
              Text(
                DateFormatter.formatTransactionDate(item.date),
                style: context.ff.text.labelSm.copyWith(
                  color: context.ff.color.secondary,
                ),
              ),
              if (statusBadge != null) statusBadge,
            ],
          ),
          const SizedBox(height: FfSpace.sm),

          // Row 2: Category Icon Tile + Merchant Name/Category & Account Subtitle + Amount
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FfCategoryTile(
                iconIdentifier: item.categoryIcon,
                colorTokenIdentifier: item.categoryColor,
                size: 40,
              ),
              const SizedBox(width: FfSpace.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      merchantName,
                      style: context.ff.text.title.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: FfSpace.x3s),
                    Text(
                      '${item.categoryName.isNotEmpty ? item.categoryName : 'Uncategorized'} • $accountName',
                      style: context.ff.text.label.copyWith(
                        color: context.ff.color.secondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: FfSpace.sm),
              Text(
                CurrencyFormatter.format(
                  item.amount,
                  showSign: true,
                  isExpense: isExpense,
                  isIncome: !isExpense,
                ),
                style: context.ff.text.title.copyWith(
                  color:
                      isExpense
                          ? context.ff.color.moneyExpense
                          : context.ff.color.moneyIncome,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Row 3: Review Reason Callout Boxes
          if (item.isDuplicate) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: FfSpace.sm),
              padding: const EdgeInsets.all(FfSpace.sm),
              decoration: BoxDecoration(
                color: context.ff.color.statusError.withValues(
                  alpha: FfTint.faint.alpha,
                ),
                borderRadius: BorderRadius.circular(FfRadius.sm),
                border: Border.all(
                  color: context.ff.color.statusError.withValues(
                    alpha: FfTint.medium.alpha,
                  ),
                  width: FfBorderWidth.hairline,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.copy_all_outlined,
                        size: 14,
                        color: context.ff.color.statusError,
                      ),
                      const SizedBox(width: FfSpace.xs),
                      Text(
                        '${item.duplicateStatus.displayName} with existing transaction',
                        style: context.ff.text.labelSm.copyWith(
                          color: context.ff.color.statusError,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (item.duplicateReasons.isNotEmpty) ...[
                    const SizedBox(height: FfSpace.x3s),
                    Text(
                      item.duplicateReasons.join(' · '),
                      style: context.ff.text.labelSm.copyWith(
                        color: context.ff.color.secondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: FfSpace.x3s),
                  Text(
                    'Merge to update the existing ledger entry, or Keep Both to record as separate.',
                    style: context.ff.text.labelSm.copyWith(
                      color: context.ff.color.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (item.warnings.isNotEmpty || item.validationErrors.isNotEmpty) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: FfSpace.sm),
              padding: const EdgeInsets.all(FfSpace.sm),
              decoration: BoxDecoration(
                color: context.ff.color.statusError.withValues(
                  alpha: FfTint.faint.alpha,
                ),
                borderRadius: BorderRadius.circular(FfRadius.sm),
                border: Border.all(
                  color: context.ff.color.statusError.withValues(
                    alpha: FfTint.medium.alpha,
                  ),
                  width: FfBorderWidth.hairline,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 14,
                    color: context.ff.color.statusError,
                  ),
                  const SizedBox(width: FfSpace.xs),
                  Expanded(
                    child: Text(
                      [...item.validationErrors, ...item.warnings].join('\n'),
                      style: context.ff.text.labelSm.copyWith(
                        color: context.ff.color.statusError,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (item.categorizationConfidence < 0.7 && !item.isDuplicate) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: FfSpace.sm),
              padding: const EdgeInsets.all(FfSpace.sm),
              decoration: BoxDecoration(
                color: context.ff.color.statusWarningContainer.withValues(
                  alpha: 0.25,
                ),
                borderRadius: BorderRadius.circular(FfRadius.sm),
                border: Border.all(
                  color: context.ff.color.statusWarning.withValues(
                    alpha: FfTint.strong.alpha,
                  ),
                  width: FfBorderWidth.hairline,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 14,
                    color: context.ff.color.statusWarning,
                  ),
                  const SizedBox(width: FfSpace.xs),
                  Expanded(
                    child: Text(
                      'Suggested category: ${item.categoryName.isNotEmpty ? item.categoryName : 'Uncategorized'}. Confirm or tap Edit to change.',
                      style: context.ff.text.labelSm.copyWith(
                        color: context.ff.color.statusWarning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (item.normalizedMerchant == 'Bank Transaction') ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: FfSpace.sm),
              padding: const EdgeInsets.all(FfSpace.sm),
              decoration: BoxDecoration(
                color: context.ff.color.statusWarningContainer.withValues(
                  alpha: 0.25,
                ),
                borderRadius: BorderRadius.circular(FfRadius.sm),
                border: Border.all(
                  color: context.ff.color.statusWarning.withValues(
                    alpha: FfTint.strong.alpha,
                  ),
                  width: FfBorderWidth.hairline,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.help_outline_rounded,
                    size: 14,
                    color: context.ff.color.statusWarning,
                  ),
                  const SizedBox(width: FfSpace.xs),
                  Expanded(
                    child: Text(
                      'Payee not identified — please edit before approving.',
                      style: context.ff.text.labelSm.copyWith(
                        color: context.ff.color.statusWarning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Collapsible original SMS snippet
          if (item.rawSource != null) ...[
            Theme(
              data: theme.copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                dense: true,
                title: Text(
                  'Original imported text',
                  style: context.ff.text.labelSm.copyWith(
                    color: context.ff.color.secondary,
                  ),
                ),
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: FfSpace.xs),
                    padding: const EdgeInsets.all(FfSpace.sm),
                    decoration: BoxDecoration(
                      color: context.ff.color.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(FfRadius.sm),
                    ),
                    child: SelectableText(
                      item.rawSource!,
                      style: context.ff.text.labelSm.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: FfSpace.sm),

          // Action Buttons: Dismiss, Edit, Approve / Merge / Keep Both / Fix
          Wrap(
            alignment: WrapAlignment.end,
            spacing: FfSpace.xs,
            runSpacing: FfSpace.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TextButton(
                onPressed: busy ? null : onDismiss,
                child: const Text('Dismiss'),
              ),
              TextButton(
                onPressed: busy ? null : onEdit,
                child: const Text('Edit'),
              ),
              if (item.isDuplicate &&
                  (item.matchedTransaction != null ||
                      item.matchedTransactionId != null)) ...[
                TextButton(
                  onPressed: busy || !item.isValid ? null : onKeepBoth,
                  child: const Text('Keep Both'),
                ),
                FfButton(
                  label: 'Merge',
                  variant: FfButtonVariant.secondary,
                  size: FfButtonSize.sm,
                  onPressed: busy || !item.isValid ? null : onMerge,
                ),
              ] else if (!item.isValid)
                FfButton(
                  label: 'Fix Details',
                  size: FfButtonSize.sm,
                  onPressed: busy ? null : onEdit,
                )
              else
                FfButton(
                  label: 'Approve',
                  size: FfButtonSize.sm,
                  onPressed: busy ? null : onApprove,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
