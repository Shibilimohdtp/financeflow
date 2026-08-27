import 'package:flutter/material.dart';
import '../../core/extensions/context_extensions.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../theme/stillwater_tokens.dart';

class AnalyticsPlaceholderScreen extends StatelessWidget {
  const AnalyticsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Trends'),
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
                    Icons.insights_rounded,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: StillwaterTokens.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Local Intelligence & Insights',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: StillwaterTokens.space3Xs),
                        Text(
                          'Detailed charts, category breakdowns, and merchant trends will arrive in Phase 2, computed 100% locally.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: StillwaterTokens.spaceXl),

            Text('Planned Visualizations', style: theme.textTheme.titleMedium),
            const SizedBox(height: StillwaterTokens.spaceSm),

            // Feature Preview Cards
            _buildFeaturePreview(
              context,
              icon: Icons.donut_large_rounded,
              title: 'Category Breakdown Donut',
              description:
                  'Clean visual split of your spending across food, utilities, shopping, and fuel with exact tabular amounts.',
            ),
            const SizedBox(height: StillwaterTokens.spaceSm),

            _buildFeaturePreview(
              context,
              icon: Icons.bar_chart_rounded,
              title: 'Income vs. Expense Trends',
              description:
                  'Monthly bar charts comparing total inflows against outflows to clearly illustrate your savings rate.',
            ),
            const SizedBox(height: StillwaterTokens.spaceSm),

            _buildFeaturePreview(
              context,
              icon: Icons.speed_rounded,
              title: 'Financial Health Score',
              description:
                  'A composite 0–100 score analyzing savings discipline, emergency buffers, and subscription load without judgment.',
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
