import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../theme/stillwater_tokens.dart';

class HomeQuickActions extends StatelessWidget {
  final VoidCallback onAddTransaction;
  final VoidCallback? onTransfer;
  final VoidCallback? onManageAccounts;
  final VoidCallback? onOpenBudgets;
  final VoidCallback? onOpenLoans;

  const HomeQuickActions({
    super.key,
    required this.onAddTransaction,
    this.onTransfer,
    this.onManageAccounts,
    this.onOpenBudgets,
    this.onOpenLoans,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    final actions = [
      _QuickActionItem(
        icon: Icons.add_rounded,
        label: 'Add Entry',
        tooltip: 'Add new transaction',
        isPrimary: true,
        onTap: onAddTransaction,
      ),
      if (onTransfer != null)
        _QuickActionItem(
          icon: Icons.swap_horiz_rounded,
          label: 'Transfer',
          tooltip: 'Transfer between accounts',
          onTap: onTransfer!,
        ),
      if (onManageAccounts != null)
        _QuickActionItem(
          icon: Icons.account_balance_wallet_outlined,
          label: 'Accounts',
          tooltip: 'Manage accounts',
          onTap: onManageAccounts!,
        ),
      if (onOpenBudgets != null)
        _QuickActionItem(
          icon: Icons.pie_chart_outline_rounded,
          label: 'Budgets',
          tooltip: 'View and manage budgets',
          onTap: onOpenBudgets!,
        ),
      if (onOpenLoans != null)
        _QuickActionItem(
          icon: Icons.account_balance_outlined,
          label: 'Loans & EMI',
          tooltip: 'View loans and EMIs',
          onTap: onOpenLoans!,
        ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: StillwaterTokens.spaceLg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:
            actions.map((action) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: StillwaterTokens.space3Xs,
                  ),
                  child: _buildActionButton(context, theme, action),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    ThemeData theme,
    _QuickActionItem action,
  ) {
    final isPrimary = action.isPrimary;
    final bgColor =
        isPrimary
            ? theme.colorScheme.primary
            : theme.colorScheme.surfaceContainerLow;
    final fgColor =
        isPrimary
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onSurfaceVariant;
    final borderColor =
        isPrimary ? theme.colorScheme.primary : theme.dividerColor;

    return Semantics(
      button: true,
      label: action.tooltip,
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
        child: InkWell(
          onTap: action.onTap,
          borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
          child: Container(
            constraints: const BoxConstraints(
              minHeight: StillwaterTokens.touchTargetMin,
            ),
            padding: const EdgeInsets.symmetric(
              vertical: StillwaterTokens.spaceSm,
              horizontal: StillwaterTokens.space2Xs,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
              border: Border.all(
                color: borderColor,
                width: StillwaterTokens.borderWidthHairline,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(action.icon, size: 20, color: fgColor),
                const SizedBox(height: StillwaterTokens.space3Xs),
                Text(
                  action.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: fgColor,
                    fontWeight: isPrimary ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionItem {
  final IconData icon;
  final String label;
  final String tooltip;
  final bool isPrimary;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.tooltip,
    this.isPrimary = false,
    required this.onTap,
  });
}
