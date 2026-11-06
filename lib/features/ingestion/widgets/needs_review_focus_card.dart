import 'package:flutter/material.dart';

import '../../../core/formatting/date_formatter.dart';
import '../../../models/account.dart';
import '../../../models/ingestion/parsed_transaction.dart';
import '../../../models/transaction.dart';
import '../../../shared/widgets/ff_amount_text.dart';
import '../../../shared/widgets/ff_badge.dart';
import '../../../shared/widgets/ff_button.dart';
import '../../../shared/widgets/ff_card.dart';
import '../../../shared/widgets/ff_category_tile.dart';
import '../../../shared/widgets/ff_source_badge.dart';
import '../../../theme/ff.dart';
import '../../../theme/ff_tone.dart';

/// The focused, single-item triage card in Needs Review Focus Mode.
class NeedsReviewFocusCard extends StatelessWidget {
  const NeedsReviewFocusCard({
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
    final ff = context.ff;
    final c = ff.color;
    final isExpense = item.type == TransactionType.expense;

    final account = accounts.where((a) => a.id == item.accountId).firstOrNull;
    final accountName = account?.name ?? (item.sourceName ?? 'Account');

    final merchantName =
        item.merchantDisplayName ??
        (item.normalizedMerchant.isNotEmpty
            ? item.normalizedMerchant
            : item.rawMerchant);

    // Trust & status cue
    Widget trustBadge;
    if (item.isDuplicate) {
      trustBadge = FfBadge(
        label: item.duplicateStatus.displayName,
        tone: FfTone.warning,
        icon: Icons.copy_rounded,
      );
    } else if (!item.isValid) {
      trustBadge = const FfBadge(
        label: 'Needs details',
        tone: FfTone.error,
        icon: Icons.error_outline_rounded,
      );
    } else if (item.categorizationConfidence < 0.7) {
      trustBadge = const FfBadge(
        label: 'Confirm category',
        tone: FfTone.warning,
        icon: Icons.lightbulb_outline_rounded,
      );
    } else {
      trustBadge = const FfBadge(
        label: 'Likely match',
        tone: FfTone.income,
        icon: Icons.verified_outlined,
      );
    }

    return Dismissible(
      key: ValueKey(item.tempId),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (busy) return false;
        if (direction == DismissDirection.startToEnd) {
          if (!item.isValid) {
            onEdit();
            return false;
          }
          if (item.isDuplicate) {
            onMerge();
          } else {
            onApprove();
          }
          return true;
        } else {
          onDismiss();
          return true;
        }
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: FfSpace.xl),
        decoration: BoxDecoration(
          color: c.statusSuccess.withValues(alpha: FfTint.subtle.alpha),
          borderRadius: BorderRadius.circular(FfRadius.lg),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: c.statusSuccess, size: 24),
            const SizedBox(width: FfSpace.xs),
            Text(
              'Approve',
              style: ff.text.title.copyWith(
                color: c.statusSuccess,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: FfSpace.xl),
        decoration: BoxDecoration(
          color: c.statusError.withValues(alpha: FfTint.subtle.alpha),
          borderRadius: BorderRadius.circular(FfRadius.lg),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Dismiss',
              style: ff.text.title.copyWith(
                color: c.statusError,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: FfSpace.xs),
            Icon(Icons.delete_outline_rounded, color: c.statusError, size: 24),
          ],
        ),
      ),
      child: FfCard(
        density: FfDensity.compact,
        variant: FfCardVariant.elevated,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Meta: Source + Date + Trust cue
            Wrap(
              spacing: FfSpace.xs,
              runSpacing: FfSpace.x2s,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FfSourceBadge(source: item.source, sourceName: item.sourceName),
                Text(
                  DateFormatter.formatShortDate(item.date),
                  style: ff.text.labelSm.copyWith(color: c.textSecondary),
                ),
                trustBadge,
              ],
            ),

            const SizedBox(height: FfSpace.sm),

            // Payee, Category & Amount Row
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
                        style: ff.text.title.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${item.categoryName.isNotEmpty ? item.categoryName : 'Uncategorized'} · $accountName',
                        style: ff.text.bodySm.copyWith(color: c.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: FfSpace.xs),
                FfAmountText(
                  amount: item.amount,
                  size: FfAmountSize.md,
                  style: FfAmountStyle.inline,
                  type:
                      isExpense
                          ? TransactionType.expense
                          : TransactionType.income,
                  showSign: true,
                ),
              ],
            ),

            // Context alerts
            if (item.isDuplicate) ...[
              const SizedBox(height: FfSpace.xs),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(FfSpace.xs),
                decoration: BoxDecoration(
                  color: c.statusWarningContainer,
                  borderRadius: BorderRadius.circular(FfRadius.sm),
                ),
                child: Text(
                  item.duplicateReasons.isNotEmpty
                      ? item.duplicateReasons.join(' · ')
                      : 'Duplicate match detected with existing transaction',
                  style: ff.text.labelSm.copyWith(color: c.statusWarning),
                ),
              ),
            ],

            if (item.warnings.isNotEmpty ||
                item.validationErrors.isNotEmpty) ...[
              const SizedBox(height: FfSpace.xs),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(FfSpace.xs),
                decoration: BoxDecoration(
                  color: c.statusErrorContainer,
                  borderRadius: BorderRadius.circular(FfRadius.sm),
                ),
                child: Text(
                  [...item.validationErrors, ...item.warnings].join('\n'),
                  style: ff.text.labelSm.copyWith(color: c.statusError),
                ),
              ),
            ],

            // Collapsible Raw Snippet
            if (item.rawSource != null) ...[
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                dense: true,
                title: Text(
                  'Original imported text',
                  style: ff.text.labelSm.copyWith(color: c.textSecondary),
                ),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(FfSpace.sm),
                    decoration: BoxDecoration(
                      color: c.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(FfRadius.sm),
                    ),
                    child: SelectableText(
                      item.rawSource!,
                      style: ff.text.labelSm.copyWith(fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: FfSpace.sm),

            // Actions: Dismiss, Edit, Approve / Merge / Keep Both / Fix
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
      ),
    );
  }
}
