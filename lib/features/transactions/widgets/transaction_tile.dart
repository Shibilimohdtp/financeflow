import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/formatting/currency_formatter.dart';
import '../../../core/formatting/date_formatter.dart';
import '../../../models/account.dart';
import '../../../models/transaction.dart';
import '../../../shared/widgets/ff_amount_text.dart';
import '../../../shared/widgets/ff_category_tile.dart';
import '../../../shared/widgets/ff_sheet_header.dart';
import '../../../theme/stillwater_tokens.dart';
import '../transaction_list_utils.dart';
import '../../../shared/widgets/ff_dialog.dart';
import '../../../shared/widgets/ff_sheet.dart';

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
    final finColors = context.finColors;

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
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: const Text('View details'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  onOpen();
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit transaction'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  onEdit();
                },
              ),
              if (onDuplicate != null)
                ListTile(
                  leading: const Icon(Icons.copy_rounded),
                  title: const Text('Duplicate transaction'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    onDuplicate!();
                  },
                ),
              ListTile(
                leading: Icon(
                  Icons.delete_outline_rounded,
                  color: finColors.expense,
                ),
                title: Text(
                  'Delete transaction',
                  style: TextStyle(color: finColors.expense),
                ),
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
              const SizedBox(height: StillwaterTokens.spaceSm),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isDark = context.isDarkMode;

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
        color: theme.colorScheme.primary,
        onActionTriggered: () => HapticFeedback.selectionClick(),
      ),
      secondaryBackground: _SwipeActionBackground(
        icon: Icons.delete_outline_rounded,
        label: 'Delete',
        alignment: Alignment.centerRight,
        color: theme.colorScheme.error,
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
                ? theme.colorScheme.primary.withValues(alpha: 0.10)
                : Colors.transparent,
        child: InkWell(
          onTap: selectionMode ? onToggleSelected : onOpen,
          onLongPress: onToggleSelected ?? () => _showActionSheet(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: StillwaterTokens.spaceLg,
              vertical: StillwaterTokens.spaceSm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Category icon, or a check mark while selecting
                if (selectionMode)
                  SizedBox(
                    width: 42,
                    height: 42,
                    child: Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color:
                          isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline,
                    ),
                  )
                else
                  FfCategoryTile(
                    iconIdentifier: transaction.categoryIcon,
                    colorTokenIdentifier: transaction.categoryColor,
                    size: 42,
                  ),
                const SizedBox(width: StillwaterTokens.spaceMd),

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
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: StillwaterTokens.space3Xs),

                      // Metadata Row (Time/Date, Account chip, Method, Tags)
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              showDate ? dateStr : timeStr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.secondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          if (fromAccount != null && !isTransfer) ...[
                            Text(
                              ' · ',
                              style: TextStyle(
                                color: theme.colorScheme.secondary.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                fromAccount.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.secondary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                          if (transaction.paymentMethod?.isNotEmpty ??
                              false) ...[
                            Text(
                              ' · ',
                              style: TextStyle(
                                color: theme.colorScheme.secondary.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 1.5,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isDark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : Colors.black.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(
                                  StillwaterTokens.radiusXs,
                                ),
                              ),
                              child: Text(
                                transaction.paymentMethod!,
                                style: context.textTheme.labelSmall?.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.75,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          if (transaction.tags.isNotEmpty) ...[
                            const SizedBox(width: StillwaterTokens.space2Xs),
                            Text(
                              '#${transaction.tags.first}',
                              style: context.textTheme.labelSmall?.copyWith(
                                fontSize: 10.5,
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: StillwaterTokens.spaceMd),

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
        size: FfAmountSize.md,
        isBlurred: isPrivacyBlur,
      );
    }
    final inflow =
        transaction.effectiveDirection == AccountMovementDirection.inflow;
    return FfAmountText(
      amount: inflow ? transaction.amount : -transaction.amount,
      size: FfAmountSize.md,
      isBlurred: isPrivacyBlur,
      colorOverride: switch (kind) {
        TransactionKind.spending => context.finColors.expense,
        TransactionKind.income => context.finColors.income,
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
      padding: const EdgeInsets.symmetric(horizontal: StillwaterTokens.spaceLg),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: StillwaterTokens.spaceXs),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
