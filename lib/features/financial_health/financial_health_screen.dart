import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../models/financial_health.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_section_header.dart';
import '../../theme/stillwater_typography.dart';
import 'financial_health_controller.dart';
import '../../shared/widgets/ff_app_bar.dart';
import '../../shared/widgets/ff_progress.dart';
import '../../theme/ff.dart';

class FinancialHealthScreen extends ConsumerWidget {
  const FinancialHealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final finColors = context.ff.color;
    final reportAsync = ref.watch(financialHealthReportProvider);

    return Scaffold(
      appBar: FfAppBar(
        title: 'Financial Health',
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: FfSpace.lg),
            child: Center(
              child: FfPrivacyBadge(label: 'On-device', iconOnly: true),
            ),
          ),
        ],
      ),
      body: reportAsync.when(
        data: (report) {
          final Color scoreColor;
          switch (report.grade) {
            case HealthScoreGrade.excellent:
            case HealthScoreGrade.strong:
              scoreColor = finColors.moneyIncome;
              break;
            case HealthScoreGrade.balanced:
              scoreColor = context.ff.color.actionPrimary;
              break;
            case HealthScoreGrade.needsAttention:
              scoreColor = finColors.moneyExpense;
              break;
            case HealthScoreGrade.insufficientData:
              scoreColor = context.ff.color.secondary;
              break;
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              FfSpace.lg,
              FfSpace.md,
              FfSpace.lg,
              FfSpace.x4l,
            ),
            children: [
              // ── 1. Overall Health Score Hero ────────────────────────────
              FfCard(
                variant: FfCardVariant.elevated,
                child: Column(
                  children: [
                    const SizedBox(height: FfSpace.sm),
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
                                context.ff.color.surfaceContainerHighest,
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
                              style: context.ff.text.labelSm.copyWith(
                                color: context.ff.color.secondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: FfSpace.lg),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: FfSpace.md,
                        vertical: FfSpace.x2s,
                      ),
                      decoration: BoxDecoration(
                        color: scoreColor.withValues(
                          alpha: FfTint.subtle.alpha,
                        ),
                        borderRadius: BorderRadius.circular(FfRadius.full),
                      ),
                      child: Text(
                        report.grade.label,
                        style: context.ff.text.titleSm.copyWith(
                          color: scoreColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: FfSpace.sm),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: FfSpace.sm,
                      ),
                      child: Text(
                        report.grade.description,
                        style: context.ff.text.body.copyWith(
                          color: context.ff.color.secondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: FfSpace.sm),
                  ],
                ),
              ),

              const SizedBox(height: FfSpace.x2l),

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
                                  ? finColors.moneyIncome
                                  : scorePct >= 0.5
                                  ? context.ff.color.actionPrimary
                                  : finColors.moneyExpense)
                              : context.ff.color.secondary;

                      return Padding(
                        padding: const EdgeInsets.all(FfSpace.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    comp.title,
                                    style: context.ff.text.titleSm.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: FfSpace.sm),
                                if (!comp.hasSufficientData)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: FfSpace.sm,
                                      vertical: FfSpace.x3s,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          theme
                                              .colorScheme
                                              .surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(
                                        FfRadius.full,
                                      ),
                                    ),
                                    child: Text(
                                      'Not enough data',
                                      style: context.ff.text.labelSm.copyWith(
                                        color: context.ff.color.secondary,
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
                            const SizedBox(height: FfSpace.sm),
                            FfProgressBar(
                              value: scorePct,
                              color: barColor,
                              size: FfProgressSize.md,
                            ),
                            const SizedBox(height: FfSpace.sm),
                            Text(
                              comp.summary,
                              style: context.ff.text.bodySm.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: FfSpace.x3s),
                            Text(
                              comp.detail,
                              style: context.ff.text.bodySm.copyWith(
                                color: context.ff.color.secondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),

              const SizedBox(height: FfSpace.x2l),

              // ── 4. Privacy Guarantee Footer ─────────────────────────────
              FfCard(
                variant: FfCardVariant.tinted,
                padding: const EdgeInsets.all(FfSpace.md),
                child: Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 24,
                      color: context.ff.color.statusSuccess,
                    ),
                    const SizedBox(width: FfSpace.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'On-Device Analysis',
                            style: context.ff.text.titleSm.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: FfSpace.x3s),
                          Text(
                            'Your wellness score is computed strictly on your device using local transactions, budgets, and savings goals.',
                            style: context.ff.text.bodySm.copyWith(
                              color: context.ff.color.secondary,
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
                padding: EdgeInsets.all(FfSpace.x4l),
                child: FfLoading(),
              ),
            ),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
