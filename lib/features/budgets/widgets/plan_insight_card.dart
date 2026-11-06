import 'package:flutter/material.dart';

import '../../../shared/widgets/ff_button.dart';
import '../../../shared/widgets/ff_card.dart';
import '../../../shared/widgets/ff_icon_tile.dart';
import '../../../theme/ff.dart';
import '../../../theme/ff_tone.dart';
import '../budget_format.dart';
import '../plan_providers.dart';

/// The Plan tab's single suggestion: the most useful change for the viewed
/// period, with a one-tap action. Replaces the old overall summary, the
/// "budget intelligence" card and the per-card status lines, which all said
/// the same thing in different words.
class PlanInsightCard extends StatelessWidget {
  const PlanInsightCard({
    super.key,
    required this.insight,
    required this.isPrivacyBlur,
    required this.periodName,
    this.onApplyLimit,
    this.onOpenBudget,
  });

  final PlanInsight insight;
  final bool isPrivacyBlur;

  /// "October", for a closed period's note.
  final String periodName;

  /// Raise or lower the budget's limit to [newLimitMinor].
  final void Function(int newLimitMinor)? onApplyLimit;
  final VoidCallback? onOpenBudget;

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final content = _content();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FfSpace.pageMargin),
      child: FfCard(
        key: const ValueKey('plan-insight'),
        variant: FfCardVariant.tinted,
        tone: content.tone,
        density: FfDensity.compact,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FfIconTile(icon: content.icon, tone: content.tone),
                const SizedBox(width: FfSpace.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(content.title, style: ff.text.title),
                      const SizedBox(height: FfSpace.x3s),
                      Text(content.body, style: ff.text.bodySm),
                      if (content.note != null) ...[
                        const SizedBox(height: FfSpace.x2s),
                        Text(content.note!, style: ff.text.label),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (content.action != null) ...[
              const SizedBox(height: FfSpace.sm),
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: FfRowTokens.iconTile + FfSpace.sm,
                ),
                child: FfButton(
                  key: const ValueKey('plan-insight-action'),
                  label: content.action!,
                  onPressed: content.onAction,
                  variant: FfButtonVariant.primary,
                  size: FfButtonSize.sm,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  _InsightContent _content() {
    final r = insight.result;
    final i = insight.insight;
    final s = insight.suggestion;
    String m(int minor) => isPrivacyBlur ? 'more' : BudgetFormat.money(minor);
    switch (insight.kind) {
      case PlanInsightKind.raise:
        final n = i!.history.length;
        final noun = BudgetFormat.periodNoun(r!.budget.period, count: n);
        final skip = s!.skipPurchases;
        final per = BudgetFormat.periodNoun(r.budget.period);
        final skipText =
            skip != null && skip > 0
                ? 'Or skip about $skip purchase${skip == 1 ? '' : 's'} a $per '
                    'to keep the current limit.'
                : null;
        return _InsightContent(
          icon: Icons.trending_up_rounded,
          tone: FfTone.warning,
          title: '${r.budget.name} keeps going over',
          body:
              'Over plan in ${i.exceededCount} of the last $n $noun'
              '${isPrivacyBlur ? '' : ', by about ${BudgetFormat.estimate(i.averageOvershootMinor)} each time'}. '
              'A limit close to what you usually spend is easier to keep.',
          note: skipText,
          action:
              isPrivacyBlur
                  ? 'Raise the limit'
                  : 'Raise to ${m(s.newLimitMinor)}',
          onAction:
              onApplyLimit == null
                  ? null
                  : () => onApplyLimit!(s.newLimitMinor),
        );
      case PlanInsightKind.lower:
        final n = i!.history.length;
        final noun = BudgetFormat.periodNoun(r!.budget.period, count: n);
        final freed = r.budget.limitMinor - s!.newLimitMinor;
        return _InsightContent(
          icon: Icons.savings_outlined,
          tone: FfTone.savings,
          title: '${r.budget.name} has room to spare',
          body:
              'You used less than three quarters of it in each of the last '
              '$n $noun.',
          note: 'Lowering it frees ${m(freed)} for other budgets.',
          action:
              isPrivacyBlur
                  ? 'Lower the limit'
                  : 'Lower to ${m(s.newLimitMinor)}',
          onAction:
              onApplyLimit == null
                  ? null
                  : () => onApplyLimit!(s.newLimitMinor),
        );
      case PlanInsightKind.runOut:
        final date = BudgetFormat.shortDate(r!.runOutDate!);
        return _InsightContent(
          icon: Icons.hourglass_bottom_rounded,
          tone: FfTone.warning,
          title: '${r.budget.name} may run out around $date',
          body:
              isPrivacyBlur
                  ? 'At this pace it will go over before the period ends.'
                  : 'At this pace you would spend about '
                      '${BudgetFormat.estimate(r.forecastMinor)} of '
                      '${m(r.limitMinor)}.',
          note:
              isPrivacyBlur
                  ? null
                  : 'Keeping to ${m(r.dailyAllowanceMinor)} a day stays within plan.',
          action: 'See ${r.budget.name}',
          onAction: onOpenBudget,
        );
    }
  }
}

class _InsightContent {
  const _InsightContent({
    required this.icon,
    required this.tone,
    required this.title,
    required this.body,
    this.note,
    this.action,
    this.onAction,
  });

  final IconData icon;
  final FfTone tone;
  final String title;
  final String body;

  /// A quieter second line: the alternative or the daily figure.
  final String? note;
  final String? action;
  final VoidCallback? onAction;
}
