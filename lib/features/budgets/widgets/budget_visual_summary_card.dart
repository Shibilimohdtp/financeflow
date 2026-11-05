import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/formatting/currency_formatter.dart';
import '../../../shared/widgets/ff_card.dart';
import '../../../theme/stillwater_tokens.dart';
import '../../../theme/stillwater_typography.dart';

class BudgetVisualSummaryCard extends StatelessWidget {
  final double totalBudgeted;
  final double totalSpent;
  final double totalRemaining;
  final int overBudgetCount;
  final int totalBudgetsCount;

  const BudgetVisualSummaryCard({
    super.key,
    required this.totalBudgeted,
    required this.totalSpent,
    required this.totalRemaining,
    required this.overBudgetCount,
    this.totalBudgetsCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final finColors = context.finColors;

    final isExceeded = totalSpent > totalBudgeted;
    final rawRatio = totalBudgeted > 0 ? (totalSpent / totalBudgeted) : 0.0;
    final progress = rawRatio.clamp(0.0, 1.0);
    final percentageInt = (rawRatio * 100).round();
    final isApproaching = !isExceeded && rawRatio >= 0.8;

    final Color statusColor;
    final IconData statusIcon;
    final String statusMessage;
    final String gaugeSublabel;

    if (isExceeded) {
      statusColor = finColors.expense;
      statusIcon = Icons.error_outline_rounded;
      final overAmount = totalSpent - totalBudgeted;
      statusMessage =
          '${CurrencyFormatter.formatAmount(overAmount)} over planned limit';
      gaugeSublabel = 'OVER';
    } else if (isApproaching) {
      statusColor = context.statusColors.warning;
      statusIcon = Icons.warning_amber_rounded;
      statusMessage = 'Approaching limit ($percentageInt% used)';
      gaugeSublabel = 'USED';
    } else {
      statusColor = finColors.income;
      statusIcon = Icons.check_circle_outline_rounded;
      statusMessage = 'Healthy & within planned limit';
      gaugeSublabel = 'USED';
    }

    final double availablePercent =
        isExceeded ? 0 : ((1.0 - progress) * 100).clamp(0.0, 100.0);

    return FfCard(
      variant: FfCardVariant.elevated,
      padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Header: Pool Label & Over-budget badge ──────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withValues(alpha: 0.4),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: StillwaterTokens.spaceXs),
                  Text(
                    'TOTAL BUDGET POOL',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.secondary,
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              if (overBudgetCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: StillwaterTokens.spaceSm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: finColors.expenseContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(
                      StillwaterTokens.radiusFull,
                    ),
                    border: Border.all(
                      color: finColors.expense.withValues(alpha: 0.35),
                      width: StillwaterTokens.borderWidthHairline,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 12,
                        color: finColors.expense,
                      ),
                      const SizedBox(width: StillwaterTokens.space2Xs),
                      Text(
                        '$overBudgetCount over limit',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: finColors.expense,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                )
              else if (totalBudgetsCount > 0)
                Text(
                  '$totalBudgetsCount active ${totalBudgetsCount == 1 ? 'budget' : 'budgets'}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
            ],
          ),

          const SizedBox(height: StillwaterTokens.spaceMd),

          // ── 2. Hero Spend & Precision Radial Gauge ─────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left: Total Spent, Hero Amount, Status Line
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Spent',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        CurrencyFormatter.formatAmount(totalSpent),
                        style: StillwaterTypography.numHero(
                          color:
                              isExceeded
                                  ? finColors.expense
                                  : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: StillwaterTokens.space2Xs),
                        Expanded(
                          child: Text(
                            statusMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: StillwaterTokens.spaceSm),

              // Right: Precision Gauge
              _BudgetProgressGauge(
                progress: progress,
                percentage: percentageInt,
                statusColor: statusColor,
                sublabel: gaugeSublabel,
              ),
            ],
          ),

          const SizedBox(height: StillwaterTokens.spaceMd),

          // ── 3. Bottom Metric Capsules (Total Budget & Remaining) ───
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: 'TOTAL BUDGET',
                  value: CurrencyFormatter.formatAmount(totalBudgeted),
                  caption:
                      totalBudgetsCount > 0
                          ? '$totalBudgetsCount ${totalBudgetsCount == 1 ? 'category' : 'categories'}'
                          : 'Monthly limit',
                  valueColor: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: StillwaterTokens.spaceSm),
              Expanded(
                child: _MetricTile(
                  label: isExceeded ? 'OVER BUDGET' : 'REMAINING',
                  value:
                      isExceeded
                          ? CurrencyFormatter.formatAmount(
                            totalSpent - totalBudgeted,
                          )
                          : CurrencyFormatter.formatAmount(totalRemaining),
                  caption:
                      isExceeded
                          ? 'Exceeds budget'
                          : '${availablePercent.toStringAsFixed(0)}% available',
                  valueColor: isExceeded ? finColors.expense : finColors.income,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BudgetProgressGauge extends StatelessWidget {
  final double progress;
  final int percentage;
  final Color statusColor;
  final String sublabel;

  const _BudgetProgressGauge({
    required this.progress,
    required this.percentage,
    required this.statusColor,
    required this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: progress),
      duration: StillwaterTokens.durationDeliberate,
      curve: StillwaterTokens.easeEmphasized,
      builder: (context, animatedProgress, _) {
        return SizedBox(
          width: 78,
          height: 78,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Custom Circular Gauge Painter with rounded caps
              CustomPaint(
                size: const Size(78, 78),
                painter: _GaugePainter(
                  progress: animatedProgress,
                  progressColor: statusColor,
                  trackColor: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.7),
                  strokeWidth: 6.5,
                ),
              ),
              // Perfectly proportioned, centered label
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$percentage%',
                    style: StillwaterTypography.numMd(
                      color: theme.colorScheme.onSurface,
                    ).copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    sublabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 9,
                      letterSpacing: 0.9,
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color trackColor;
  final double strokeWidth;

  const _GaugePainter({
    required this.progress,
    required this.progressColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track Paint
    final trackPaint =
        Paint()
          ..color = trackColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress Arc Paint
    if (progress > 0) {
      final progressPaint =
          Paint()
            ..color = progressColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..strokeCap = StrokeCap.round;

      const startAngle = -math.pi / 2;
      final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final String caption;
  final Color valueColor;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.caption,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: StillwaterTokens.spaceSm + 2,
        vertical: StillwaterTokens.spaceXs + 2,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.35,
        ),
        borderRadius: BorderRadius.circular(StillwaterTokens.radiusMd),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.5),
          width: StillwaterTokens.borderWidthHairline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.secondary,
              fontSize: 10,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: StillwaterTypography.numMd(
                color: valueColor,
              ).copyWith(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.secondary.withValues(alpha: 0.8),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
