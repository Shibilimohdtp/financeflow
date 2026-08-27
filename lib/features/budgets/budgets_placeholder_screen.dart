import 'package:flutter/material.dart';
import '../../core/extensions/context_extensions.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../theme/stillwater_tokens.dart';

class BudgetsPlaceholderScreen extends StatelessWidget {
  const BudgetsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets & Goals'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: StillwaterTokens.spaceLg),
            child: Center(
              child: FfPrivacyBadge(label: 'Phase 2 Preview', iconOnly: true),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview Banner
            FfCard(
              variant: FfCardVariant.tinted,
              child: Row(
                children: [
                  Icon(
                    Icons.pie_chart_outline_rounded,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: StillwaterTokens.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Offline Budgeting & Goals',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: StillwaterTokens.space3Xs),
                        Text(
                          'Category limits, daily allowances, and savings goals will arrive in Phase 2, powered entirely on your device.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: StillwaterTokens.spaceXl),

            Text('Planned Capabilities', style: theme.textTheme.titleMedium),
            const SizedBox(height: StillwaterTokens.spaceSm),

            // Feature Preview Cards
            _buildFeaturePreview(
              context,
              icon: Icons.account_balance_wallet_outlined,
              title: 'Monthly Category Budgets',
              description:
                  'Set calm limits for Food, Transport, Shopping, and more. Visual water-fill bars with zero red-shaming or guilt.',
            ),
            const SizedBox(height: StillwaterTokens.spaceSm),

            _buildFeaturePreview(
              context,
              icon: Icons.savings_outlined,
              title: 'Savings Goals',
              description:
                  'Track funds for emergency reserves, vacations, or major purchases with non-intrusive local progress indicators.',
            ),
            const SizedBox(height: StillwaterTokens.spaceSm),

            _buildFeaturePreview(
              context,
              icon: Icons.calendar_month_outlined,
              title: 'Daily Safe-to-Spend',
              description:
                  'Know exactly how much remains for each day of the month based on your true pace of spending.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturePreview(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = context.theme;

    return FfCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(StillwaterTokens.spaceSm),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
            ),
            child: Icon(icon, size: 22, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: StillwaterTokens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall),
                const SizedBox(height: StillwaterTokens.space3Xs),
                Text(description, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
