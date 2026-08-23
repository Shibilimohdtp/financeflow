import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../models/financial_health.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_section_header.dart';
import '../../theme/stillwater_tokens.dart';
import '../../theme/stillwater_typography.dart';
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
            padding: const EdgeInsets.fromLTRB(
              StillwaterTokens.spaceLg,
              StillwaterTokens.spaceMd,
              StillwaterTokens.spaceLg,
              StillwaterTokens.space4Xl,
            ),
            children: [
              // ── 1. Overall Health Score Hero ────────────────────────────
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
                          width: 120,
                          height: 120,
                          child: CircularProgressIndicator(
                            value:
                                report.hasOverallSufficientData
                                    ? (report.totalScore / 100.0)
                                    : 0.0,
                            strokeWidth: 8,
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
                              style: StillwaterTypography.numHero(
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
                        horizontal: StillwaterTokens.spaceSm,
                      ),
                      child: Text(
                        report.grade.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: StillwaterTokens.spaceSm),
                  ],
                ),
              ),

              const SizedBox(height: StillwaterTokens.space2Xl),

              // ── 2. Component Explanations Header ────────────────────────
              const FfSectionHeader(
                title: 'Score Breakdown · 4 Key Indicators',
              ),

              // ── 3. Components List ──────────────────────────────────────
              FfGroupedContainer(
                children:
                    report.components.map((comp) {
                      final double scorePct =
                          comp.hasSufficientData
                              ? (comp.score / comp.maxScore)
                              : 0.0;
                      final Color barColor =
                          comp.hasSufficientData
                              ? (scorePct >= 0.75
                                  ? finColors.income
                                  : scorePct >= 0.5
                                  ? theme.colorScheme.primary
                                  : finColors.expense)
                              : theme.colorScheme.secondary;

                      return Padding(
                        padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    comp.title,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: StillwaterTokens.spaceSm),
                                if (!comp.hasSufficientData)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: StillwaterTokens.spaceSm,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          theme
                                              .colorScheme
                                              .surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(
                                        StillwaterTokens.radiusFull,
                                      ),
                                    ),
                                    child: Text(
                                      'Not enough data',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: theme.colorScheme.secondary,
                                          ),
                                    ),
                                  )
                                else
                                  Text(
                                    '${comp.score.toStringAsFixed(0)} / ${comp.maxScore.toStringAsFixed(0)} pts',
                                    style: StillwaterTypography.numSm(
                                      color: barColor,
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
                                minHeight: 5,
                              ),
                            ),
                            const SizedBox(height: StillwaterTokens.spaceSm),
                            Text(
                              comp.summary,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              comp.detail,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),

              const SizedBox(height: StillwaterTokens.space2Xl),

              // ── 4. Privacy Guarantee Footer ─────────────────────────────
              FfCard(
                variant: FfCardVariant.tinted,
                padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
                child: Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 24,
                      color: context.secColors.verified,
                    ),
                    const SizedBox(width: StillwaterTokens.spaceMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'On-Device Analysis',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Your wellness score is computed strictly on your device using local transactions, budgets, and savings goals.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
