import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../models/financial_health.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../theme/stillwater_tokens.dart';
import 'financial_health_controller.dart';

class FinancialHealthScreen extends ConsumerWidget {
  const FinancialHealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final finColors = context.finColors;
    final reportAsync = ref.watch(financialHealthReportProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Health'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: StillwaterTokens.spaceLg),
            child: Center(child: FfPrivacyBadge(label: 'On-device')),
          ),
        ],
      ),
      body: reportAsync.when(
        data: (report) {
          final Color scoreColor;
          switch (report.grade) {
            case HealthScoreGrade.excellent:
            case HealthScoreGrade.strong:
              scoreColor = finColors.income;
              break;
            case HealthScoreGrade.balanced:
              scoreColor = theme.colorScheme.primary;
              break;
            case HealthScoreGrade.needsAttention:
              scoreColor = finColors.expense;
              break;
            case HealthScoreGrade.insufficientData:
              scoreColor = theme.colorScheme.secondary;
              break;
          }

          return ListView(
            padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
            children: [
              // 1. Overall Health Score Hero Card
              FfCard(
                variant: FfCardVariant.elevated,
                child: Column(
                  children: [
                    const SizedBox(height: StillwaterTokens.spaceSm),
                    // Circular Score Ring
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 130,
                          height: 130,
                          child: CircularProgressIndicator(
                            value:
                                report.hasOverallSufficientData
                                    ? (report.totalScore / 100.0)
                                    : 0.0,
                            strokeWidth: 10,
                            backgroundColor:
                                theme.colorScheme.surfaceContainerHighest,
                            color: scoreColor,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              report.hasOverallSufficientData
                                  ? report.totalScore.toStringAsFixed(0)
                                  : '—',
                              style: theme.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: scoreColor,
                              ),
                            ),
                            Text(
                              'out of 100',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: StillwaterTokens.spaceLg),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: StillwaterTokens.spaceMd,
                        vertical: StillwaterTokens.space2Xs,
                      ),
                      decoration: BoxDecoration(
                        color: scoreColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(
                          StillwaterTokens.radiusFull,
                        ),
                      ),
                      child: Text(
                        report.grade.label,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: scoreColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: StillwaterTokens.spaceSm),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: StillwaterTokens.spaceMd,
                      ),
                      child: Text(
                        report.grade.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.8,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: StillwaterTokens.spaceSm),
                  ],
                ),
              ),

              const SizedBox(height: StillwaterTokens.spaceXl),

              // 2. Component Explanations Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Score Breakdown', style: theme.textTheme.titleMedium),
                  Text(
                    '4 Key Indicators',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: StillwaterTokens.spaceSm),

              // 3. Components List
              ...report.components.map((comp) {
                final double scorePct =
                    comp.hasSufficientData ? (comp.score / comp.maxScore) : 0.0;
                final Color barColor =
                    comp.hasSufficientData
                        ? (scorePct >= 0.75
                            ? finColors.income
                            : scorePct >= 0.5
                            ? theme.colorScheme.primary
                            : finColors.expense)
                        : theme.colorScheme.secondary;

                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: StillwaterTokens.spaceMd,
                  ),
                  child: FfCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              comp.title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (!comp.hasSufficientData)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: StillwaterTokens.spaceSm,
                                  vertical: StillwaterTokens.space3Xs,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(
                                    StillwaterTokens.radiusFull,
                                  ),
                                ),
                                child: Text(
                                  'Not enough data',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.secondary,
                                  ),
                                ),
                              )
                            else
                              Text(
                                '${comp.score.toStringAsFixed(0)} / ${comp.maxScore.toStringAsFixed(0)} pts',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: barColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: StillwaterTokens.spaceSm),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            StillwaterTokens.radiusFull,
                          ),
                          child: LinearProgressIndicator(
                            value: scorePct,
                            backgroundColor:
                                theme.colorScheme.surfaceContainerHighest,
                            color: barColor,
                            minHeight: 6,
                          ),
                        ),

                        const SizedBox(height: StillwaterTokens.spaceSm),

                        Text(
                          comp.summary,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: StillwaterTokens.space3Xs),
                        Text(
                          comp.detail,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: StillwaterTokens.spaceLg),

              // 4. Privacy & Non-judgmental Footer
              FfCard(
                variant: FfCardVariant.tinted,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      color: context.secColors.verified,
                      size: 20,
                    ),
                    const SizedBox(width: StillwaterTokens.spaceSm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'On-Device Analysis',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: context.secColors.verified,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: StillwaterTokens.space3Xs),
                          Text(
                            'Your financial health score is calculated entirely on this device from your local transactions and budget targets. It is for your personal guidance and never transmitted anywhere.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: StillwaterTokens.space4Xl),
            ],
          );
        },
        loading:
            () => const Center(
              child: Padding(
                padding: EdgeInsets.all(StillwaterTokens.space4Xl),
                child: CircularProgressIndicator(),
              ),
            ),
        error: (e, _) => Center(child: Text('Could not load health score: $e')),
      ),
    );
  }
}
