import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/financial_health.dart';
import '../../shared/widgets/ff_badge.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_data_viz.dart';
import '../../shared/widgets/ff_progress.dart';
import '../../shared/widgets/ff_section_header.dart';
import '../../shared/widgets/ff_stat_tile.dart';
import '../../shared/widgets/ff_surfaces.dart';
import '../../shared/widgets/ff_page_scaffold.dart';
import '../../theme/ff.dart';
import '../../theme/ff_tone.dart';
import 'financial_health_controller.dart';

/// Financial Health detail screen (Pattern D) in Stillwater Bloom.
/// Displays an [FfHeroCard] with circular progress wellness score,
/// followed by 4 key indicators on [FfRangeBand] with plain-language advice
/// and links into relevant tabs.
class FinancialHealthScreen extends ConsumerWidget {
  const FinancialHealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ff = context.ff;
    final c = ff.color;
    final reportAsync = ref.watch(financialHealthReportProvider);

    return FfPageScaffold(
      title: 'Financial Health',
      subtitle: 'Wellness score, on-device',
      body: reportAsync.when(
        data: (report) => _buildContent(context, report),
        loading:
            () => const Center(
              child: Padding(
                padding: EdgeInsets.all(FfSpace.x4l),
                child: FfLoading(),
              ),
            ),
        error:
            (e, _) => Center(
              child: Text(
                'Unable to calculate health score: $e',
                style: ff.text.body.copyWith(color: c.statusError),
              ),
            ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, FinancialHealthReport report) {
    final ff = context.ff;
    final c = ff.color;

    final heroTone = switch (report.grade) {
      HealthScoreGrade.excellent || HealthScoreGrade.strong => FfHeroTone.moss,
      HealthScoreGrade.balanced => FfHeroTone.dusk,
      HealthScoreGrade.needsAttention => FfHeroTone.rose,
      HealthScoreGrade.insufficientData => FfHeroTone.sand,
    };

    final scoreNormalized =
        report.hasOverallSufficientData
            ? (report.totalScore / 100.0).clamp(0.0, 1.0)
            : 0.0;
    final scoreStr =
        report.hasOverallSufficientData
            ? report.totalScore.toStringAsFixed(0)
            : '—';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        FfSpace.pageMargin,
        FfSpace.xs,
        FfSpace.pageMargin,
        FfSpace.x4l,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── 1. Overall Health Score Hero (Pattern D) ──────────────────────
          FfHeroCard(
            tone: heroTone,
            leading: FfProgressRing(
              value: scoreNormalized,
              icon: Icons.health_and_safety_outlined,
              semanticsLabel: '$scoreStr out of 100',
            ),
            title: report.grade.label,
            subtitle: 'Financial Wellness Score',
            child: Builder(
              builder: (context) {
                final heroFf = context.ff;
                final heroC = heroFf.color;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MediaQuery.withClampedTextScaling(
                      maxScaleFactor: 1.3,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              scoreStr,
                              style: heroFf.text.displayLg.copyWith(
                                fontWeight: FontWeight.w300,
                                height: 1.0,
                                color: heroC.textPrimary,
                              ),
                            ),
                            const SizedBox(width: FfSpace.xs),
                            Text(
                              'out of 100',
                              style: heroFf.text.labelLg.copyWith(
                                color: heroC.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: FfSpace.sm),
                    Text(
                      report.grade.description,
                      style: heroFf.text.bodySm.copyWith(
                        color: heroC.textSecondary,
                      ),
                    ),
                    const SizedBox(height: FfSpace.md),
                    FfHeroFigures([
                      FfHeroFigure('Scale', '100 pts'),
                      FfHeroFigure(
                        'Factors',
                        '${report.components.length} indicators',
                      ),
                      FfHeroFigure(
                        'Analysis',
                        report.hasOverallSufficientData ? 'Active' : 'Building',
                      ),
                    ]),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: FfSpace.xl),

          // ── 2. Component Explanations Header ──────────────────────────────
          const FfSectionHeader(title: 'Score Breakdown · 4 Key Indicators'),
          const SizedBox(height: FfSpace.xs),

          // ── 3. Components List ────────────────────────────────────────────
          for (final comp in report.components) ...[
            _IndicatorCard(component: comp),
            const SizedBox(height: FfSpace.sm),
          ],

          const SizedBox(height: FfSpace.md),

          // ── 4. Privacy Guarantee Footer ───────────────────────────────────
          FfCard(
            variant: FfCardVariant.tinted,
            padding: const EdgeInsets.all(FfSpace.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: FfIconSize.md,
                  color: c.statusSuccess,
                ),
                const SizedBox(width: FfSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'On-Device Analysis',
                        style: ff.text.titleSm.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: FfSpace.x2s),
                      Text(
                        'Your wellness score is computed strictly on your device using local transactions, budgets, and savings goals. Never sent to any server.',
                        style: ff.text.bodySm.copyWith(color: c.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IndicatorCard extends StatelessWidget {
  final HealthScoreComponent component;

  const _IndicatorCard({required this.component});

  IconData _iconFor(String key) => switch (key) {
    'savings_rate' => Icons.savings_outlined,
    'budget_discipline' => Icons.pie_chart_outline_rounded,
    'goal_progress' => Icons.flag_outlined,
    'cash_flow' => Icons.swap_vert_rounded,
    _ => Icons.insights_rounded,
  };

  String _ctaFor(String key) => switch (key) {
    'savings_rate' => 'Review spending',
    'budget_discipline' => 'Manage budgets',
    'goal_progress' => 'View savings goals',
    'cash_flow' => 'Inspect cash flow',
    _ => 'View details',
  };

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final c = ff.color;
    final comp = component;
    final scorePct = comp.percentage;

    final FfTone statusTone =
        !comp.hasSufficientData
            ? FfTone.neutral
            : scorePct >= 0.75
            ? FfTone.income
            : scorePct >= 0.5
            ? FfTone.neutral
            : FfTone.expense;

    return FfCard(
      density: FfDensity.comfortable,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                _iconFor(comp.key),
                size: FfIconSize.sm,
                color: c.textPrimary,
              ),
              const SizedBox(width: FfSpace.xs),
              Expanded(
                child: Text(
                  comp.title,
                  style: ff.text.titleSm.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              if (!comp.hasSufficientData)
                const FfBadge(label: 'Not enough data', tone: FfTone.neutral)
              else
                FfBadge(
                  label:
                      '${comp.score.toStringAsFixed(0)} / ${comp.maxScore.toStringAsFixed(0)} pts',
                  tone: statusTone,
                ),
            ],
          ),
          const SizedBox(height: FfSpace.md),
          if (comp.hasSufficientData)
            FfRangeBand(
              bands: const [
                FfBand(
                  start: 0.0,
                  end: 0.49,
                  tone: FfTone.expense,
                  label: 'Needs attention',
                ),
                FfBand(
                  start: 0.50,
                  end: 0.74,
                  tone: FfTone.neutral,
                  label: 'Steady',
                ),
                FfBand(
                  start: 0.75,
                  end: 1.0,
                  tone: FfTone.income,
                  label: 'Strong',
                ),
              ],
              value: scorePct,
              valueLabel: '${comp.score.toStringAsFixed(0)} pts',
            )
          else ...[
            Text(
              'Collecting more transactions to evaluate this factor.',
              style: ff.text.bodySm.copyWith(color: c.textSecondary),
            ),
          ],
          const SizedBox(height: FfSpace.sm),
          Text(
            comp.summary,
            style: ff.text.bodySm.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: FfSpace.x2s),
          Text(
            comp.detail,
            style: ff.text.bodySm.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: FfSpace.sm),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: FfButton(
              label: _ctaFor(comp.key),
              variant: FfButtonVariant.secondary,
              size: FfButtonSize.sm,
              leadingIcon: const Icon(Icons.arrow_forward_rounded, size: 14),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
        ],
      ),
    );
  }
}
