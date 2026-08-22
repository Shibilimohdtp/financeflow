import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../models/insight.dart';
import '../../../shared/widgets/ff_card.dart';
import '../../../theme/stillwater_tokens.dart';
import '../insights_controller.dart';

class LocalInsightsCard extends ConsumerWidget {
  final List<Insight> insights;

  const LocalInsightsCard({super.key, required this.insights});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;

    if (insights.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: StillwaterTokens.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 16,
                    color: context.aiColors.accent,
                  ),
                  const SizedBox(width: StillwaterTokens.spaceXs),
                  Text(
                    'On-Device Analysis',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: context.aiColors.accent,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              Text(
                '${insights.length} active',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: StillwaterTokens.spaceXs),
          ...insights.map((insight) {
            final IconData iconData;
            final Color iconColor;

            switch (insight.severity) {
              case InsightSeverity.success:
                iconData = Icons.trending_up_rounded;
                iconColor = context.finColors.income;
                break;
              case InsightSeverity.warning:
                iconData = Icons.info_outline_rounded;
                iconColor = theme.colorScheme.tertiary;
                break;
              case InsightSeverity.info:
              case InsightSeverity.neutral:
                iconData = Icons.lightbulb_outline_rounded;
                iconColor = context.aiColors.accent;
                break;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: StillwaterTokens.spaceSm),
              child: FfCard(
                variant: FfCardVariant.tinted,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(StillwaterTokens.space2Xs),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(iconData, color: iconColor, size: 18),
                    ),
                    const SizedBox(width: StillwaterTokens.spaceSm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            insight.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: StillwaterTokens.space3Xs),
                          Text(
                            insight.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 16),
                      tooltip: 'Dismiss',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        ref.read(dismissedInsightIdsProvider.notifier).update((
                          set,
                        ) {
                          return {...set, insight.id};
                        });
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
