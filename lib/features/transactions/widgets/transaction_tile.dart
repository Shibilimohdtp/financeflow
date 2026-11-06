import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/formatting/currency_formatter.dart';
import '../../../core/formatting/date_formatter.dart';
import '../../../models/account.dart';
import '../../../models/transaction.dart';
import '../../../shared/widgets/ff_amount_text.dart';
import '../../../shared/widgets/ff_category_tile.dart';
import '../../../shared/widgets/ff_sheet_header.dart';
import '../transaction_list_utils.dart';
import '../../../shared/widgets/ff_dialog.dart';
import '../../../shared/widgets/ff_sheet.dart';
import '../../../shared/widgets/ff_divider.dart';
import '../../../shared/widgets/ff_row.dart';
import '../../../theme/ff_tone.dart';
import '../../../theme/ff.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final List<Account> accounts;
  final bool showDate;
  final bool isPrivacyBlur;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final Future<void> Function() onDelete;
  final VoidCallback? onDuplicate;

  /// When true, taps toggle selection and swipe actions are disabled.
  final bool selectionMode;
  final bool isSelected;

  /// Long-press handler; when null, long-press opens the action sheet.
  final VoidCallback? onToggleSelected;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.accounts,
    required this.showDate,
    required this.isPrivacyBlur,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
    this.onDuplicate,
    this.selectionMode = false,
    this.isSelected = false,
    this.onToggleSelected,
  });

  void _showActionSheet(BuildContext context) {
    HapticFeedback.mediumImpact();

    showFfSheet<void>(
      context,
      builder:
          (sheetContext) => FfSheet(
            children: [
              FfSheetHeader(
                title: transaction.merchant,
                subtitle: CurrencyFormatter.format(
                  transaction.amount,
                  isIncome: transaction.type == TransactionType.income,
                  isExpense: transaction.type == TransactionType.expense,
                ),
              ),
              const FfDivider(),
              FfRow(
                icon: Icons.info_outline_rounded,
                title: 'View details',
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  onOpen();
                },
              ),
              FfRow(
                icon: Icons.edit_outlined,
                title: 'Edit transaction',
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  onEdit();
                },
              ),
              if (onDuplicate != null)
                FfRow(
                  icon: Icons.copy_rounded,
                  title: 'Duplicate transaction',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    onDuplicate!();
                  },
                ),
              FfRow(
                icon: Icons.delete_outline_rounded,
                title: 'Delete transaction',
                destructive: true,
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  final confirmed = await FfDialog.confirm(
                    context,
                    title: 'Delete transaction?',
                    message:
                        'Are you sure you want to delete "${transaction.merchant}" (${CurrencyFormatter.format(transaction.amount)})?',
                    confirmLabel: 'Delete',
                    destructive: true,
                  );
                  if (confirmed == true) {
                    await onDelete();
                  }
                },
              ),
              const SizedBox(height: FfSpace.sm),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fromAccount =
        accounts.where((item) => item.id == transaction.accountId).firstOrNull;
    final toAccount =
        accounts
            .where((item) => item.id == transaction.toAccountId)
            .firstOrNull;

    final isTransfer = transaction.type == TransactionType.transfer;
    final timeStr =
        DateFormatter.formatTransactionDate(transaction.date).split(', ').last;
    final dateStr = DateFormatter.formatShortDate(transaction.date);

    // Title construction
    final titleText =
        isTransfer && toAccount != null
            ? '${fromAccount?.name ?? "Account"} → ${toAccount.name}'
            : transaction.merchant;

    return Dismissible(
      key: ValueKey('transaction-${transaction.id}'),
      direction:
          selectionMode ? DismissDirection.none : DismissDirection.horizontal,
      background: _SwipeActionBackground(
        icon: Icons.edit_outlined,
        label: 'Edit',
        alignment: Alignment.centerLeft,
        color: context.ff.color.actionPrimary,
        onActionTriggered: () => HapticFeedback.selectionClick(),
      ),
      secondaryBackground: _SwipeActionBackground(
        icon: Icons.delete_outline_rounded,
        label: 'Delete',
        alignment: Alignment.centerRight,
        color: context.ff.color.statusError,
        onActionTriggered: () => HapticFeedback.mediumImpact(),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onEdit();
          return false;
        }
        final confirmed = await FfDialog.confirm(
          context,
          title: 'Delete transaction?',
          message:
              'Are you sure you want to delete "${transaction.merchant}" (${CurrencyFormatter.format(transaction.amount)})?',
          confirmLabel: 'Delete',
          destructive: true,
        );
        if (confirmed == true) {
          await onDelete();
          return true;
        }
        return false;
      },
      child: Material(
        color:
            isSelected
                ? context.ff.color.actionPrimary.withValues(
                  alpha: FfTint.subtle.alpha,
                )
                : Colors.transparent,
        child: InkWell(
          onTap: selectionMode ? onToggleSelected : onOpen,
          onLongPress: onToggleSelected ?? () => _showActionSheet(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: FfRowTokens.paddingH,
              vertical: FfSpace.sm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Category icon, or a check mark while selecting
                if (selectionMode)
                  SizedBox(
                    width: FfRowTokens.iconTile,
                    height: FfRowTokens.iconTile,
                    child: Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color:
                          isSelected
                              ? context.ff.color.actionPrimary
                              : context.ff.color.borderStrong,
                    ),
                  )
                else
                  FfCategoryTile(
                    iconIdentifier: transaction.categoryIcon,
                    colorTokenIdentifier: transaction.categoryColor,
                  ),
                const SizedBox(width: FfSpace.sm),

                // Center Information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Payee / Title
                      Text(
                        titleText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.ff.text.title,
                      ),
                      const SizedBox(height: FfSpace.x3s),

                      // Metadata Row (Time/Date, Account chip, Method, Tags)
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              showDate ? dateStr : timeStr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.ff.text.label.copyWith(
                                color: context.ff.color.secondary,
                              ),
                            ),
                          ),
                          if (fromAccount != null && !isTransfer) ...[
                            Text(' · ', style: context.ff.text.label),
                            Flexible(
                              child: Text(
                                fromAccount.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.ff.text.label.copyWith(
                                  color: context.ff.color.secondary,
                                ),
                              ),
                            ),
                          ],
                          if (transaction.paymentMethod?.isNotEmpty ??
                              false) ...[
                            Text(' · ', style: context.ff.text.label),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: FfSpace.x2s,
                                vertical: FfSpace.x3s,
                              ),
                              decoration: ShapeDecoration(
                                color: context.ff.color.tint(
                                  context.ff.color.textPrimary,
                                  FfTint.faint,
                                ),
                                shape: FfShape.of(FfRadius.full),
                              ),
                              child: Text(
                                transaction.paymentMethod!,
                                style: context.ff.text.labelSm.copyWith(
                                  color: context.ff.color.textSecondary,
                                ),
                              ),
                            ),
                          ],
                          if (transaction.tags.isNotEmpty) ...[
                            const SizedBox(width: FfSpace.x2s),
                            Text(
                              '#${transaction.tags.first}',
                              style: context.ff.text.labelSm.copyWith(
                                color: context.ff.color.actionPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: FfSpace.md),

                // Amount Section
                _amount(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension on TransactionTile {
  /// Sign follows the account movement (in +, out −, between own accounts
  /// unsigned); colour follows what the totals count it as.
  Widget _amount(BuildContext context) {
    final kind = TransactionKind.of(transaction);
    if (kind == TransactionKind.transfer) {
      return FfAmountText(
        amount: transaction.amount,
        type: TransactionType.transfer,
        size: FfAmountSize.sm,
        isBlurred: isPrivacyBlur,
      );
    }
    final inflow =
        transaction.effectiveDirection == AccountMovementDirection.inflow;
    return FfAmountText(
      amount: inflow ? transaction.amount : -transaction.amount,
      size: FfAmountSize.sm,
      isBlurred: isPrivacyBlur,
      // Calm lists: spending is ink with its minus sign; income stands out
      // in green with its plus sign. Sign and colour never carry it alone.
      tone: switch (kind) {
        TransactionKind.spending => FfTone.neutral,
        TransactionKind.income => FfTone.income,
        _ => null,
      },
    );
  }
}

class _SwipeActionBackground extends StatelessWidget {
  final IconData icon;
  final String label;
  final Alignment alignment;
  final Color color;
  final VoidCallback onActionTriggered;

  const _SwipeActionBackground({
    required this.icon,
    required this.label,
    required this.alignment,
    required this.color,
    required this.onActionTriggered,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: FfSpace.lg),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: FfSpace.xs),
          Text(
            label,
            style: context.ff.text.bodySm.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
