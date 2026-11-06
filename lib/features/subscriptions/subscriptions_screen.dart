import 'package:flutter/material.dart';
import '../../shared/widgets/ff_surfaces.dart';
import '../../theme/ff.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatting/currency_formatter.dart';
import '../../models/app_settings.dart';
import '../../models/subscription.dart';
import '../../repositories/subscription_repository.dart';
import '../../shared/widgets/ff_amount_text.dart';
import '../../shared/widgets/ff_button.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_icon_tile.dart';
import '../../shared/widgets/ff_monogram_tile.dart';
import '../../shared/widgets/ff_navigation.dart';
import '../../shared/widgets/ff_progress.dart';
import '../../shared/widgets/ff_renewal_chip.dart';
import '../../shared/widgets/ff_renewal_strip.dart';
import '../../shared/widgets/ff_row.dart';
import '../../shared/widgets/ff_section_header.dart';
import '../../shared/widgets/ff_sheet.dart';
import '../../shared/widgets/ff_stat_tile.dart';
import '../../shared/widgets/ff_page_scaffold.dart';
import '../../theme/ff_tone.dart';
import '../settings/settings_controller.dart';
import 'add_edit_subscription_sheet.dart';
import 'recurring_suggestions_sheet.dart';
import 'subscription_detail_screen.dart';
import 'subscriptions_controller.dart';

enum SubscriptionSort {
  byDate('By date'),
  byCost('By cost'),
  byCategory('By category');

  const SubscriptionSort(this.label);
  final String label;
}

/// The Stillwater Bloom Subscriptions list screen (Pattern C, Sand Hero).
///
/// Answers:
/// 1. "What am I committed to paying?" -> Sand FfHeroCard with monthly split amount
/// 2. "What is due next?" -> Hero next-line & 30-day rhythm strip
/// 3. "Can I trust I won't be surprised?" -> Urgency groups (This week, Later this month)
/// 4. "How little effort is it to add or fix one?" -> 1-tap add & smart suggestions
class SubscriptionsScreen extends ConsumerStatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  ConsumerState<SubscriptionsScreen> createState() =>
      _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends ConsumerState<SubscriptionsScreen> {
  SubscriptionSort _currentSort = SubscriptionSort.byDate;
  bool _isSuggestionsDismissed = false;
  bool _isPausedSectionExpanded = false;

  void _openAddSheet(BuildContext context) {
    showFfSheet(context, builder: (_) => const AddEditSubscriptionSheet());
  }

  void _openSuggestionsSheet(BuildContext context) {
    showFfSheet(context, builder: (_) => const RecurringSuggestionsSheet());
  }

  void _openDetail(BuildContext context, Subscription sub) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SubscriptionDetailScreen(subscription: sub),
      ),
    );
  }

  static String _dueLabel(int days) {
    if (days < 0) return '${days.abs()}d ago';
    if (days == 0) return 'today';
    if (days == 1) return 'tomorrow';
    return 'in ${days}d';
  }

  String? _computeTopSpendInsight(
    List<Subscription> activeSubs,
    double monthlyTotal,
  ) {
    if (activeSubs.length < 3 || monthlyTotal <= 0) return null;
    final sorted = [...activeSubs]..sort(
      (a, b) => b.monthlyEquivalentAmount.compareTo(a.monthlyEquivalentAmount),
    );
    final top2Total =
        sorted[0].monthlyEquivalentAmount + sorted[1].monthlyEquivalentAmount;
    final pct = (top2Total / monthlyTotal * 100).round();
    if (pct >= 50 && pct < 100) {
      return '${sorted[0].merchant} and ${sorted[1].merchant} make up $pct% of your monthly commitment.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    final summary = ref.watch(subscriptionsSummaryProvider);
    final subsAsync = ref.watch(allSubscriptionsStreamProvider);
    final suggestionsAsync = ref.watch(recurringSuggestionsProvider);
    final settings =
        ref.watch(settingsStreamProvider).value ?? const AppSettings();
    final isPrivacyBlur = settings.isPrivacyBlurEnabled;

    final suggestions = suggestionsAsync.value ?? const [];
    final hasSuggestions = suggestions.isNotEmpty && !_isSuggestionsDismissed;

    return FfPageScaffold(
      title: 'Subscriptions',
      subtitle: 'Recurring payments, on-device',
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'subscriptions_fab',
        tooltip: 'Add subscription',
        onPressed: () => _openAddSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Subscription'),
      ),
      body: subsAsync.when(
        data: (allSubs) {
          if (allSubs.isEmpty) {
            return _buildEmptyState(context);
          }

          final activeSubs =
              allSubs
                  .where((s) => s.status == SubscriptionStatus.active)
                  .toList();
          final inactiveSubs =
              allSubs
                  .where((s) => s.status != SubscriptionStatus.active)
                  .toList();

          // Compute earliest next renewal for hero
          Subscription? earliestNext;
          if (activeSubs.isNotEmpty) {
            final sortedByDate = [...activeSubs]..sort(
              (a, b) => a.daysUntilRenewal().compareTo(b.daysUntilRenewal()),
            );
            earliestNext = sortedByDate.first;
          }

          final topSpendInsight = _computeTopSpendInsight(
            activeSubs,
            summary.monthlyTotal,
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              FfSpace.pageMargin,
              FfSpace.sm,
              FfSpace.pageMargin,
              104,
            ),
            children: [
              // ── 1. Sand Hero Card ──────────────────────────────────────
              FfHeroCard(
                tone: FfHeroTone.sand,
                leading: const FfIconTile(
                  icon: Icons.autorenew_rounded,
                  tone: FfTone.primary,
                ),
                title: 'MONTHLY COMMITMENT',
                subtitle:
                    '${summary.activeCount} active ${summary.activeCount == 1 ? 'plan' : 'plans'}',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FfAmountText(
                      amount: summary.monthlyTotal,
                      size: FfAmountSize.hero,
                      style: FfAmountStyle.split,
                      isBlurred: isPrivacyBlur,
                    ),
                    const SizedBox(height: FfSpace.md),
                    FfHeroFigures([
                      FfHeroFigure(
                        'Annual pace',
                        isPrivacyBlur
                            ? '••••'
                            : CurrencyFormatter.formatAmount(
                              summary.yearlyTotal,
                            ),
                      ),
                      if (earliestNext != null)
                        FfHeroFigure(
                          'Next up',
                          '${earliestNext.merchant} · ${_dueLabel(earliestNext.daysUntilRenewal())}',
                        )
                      else
                        FfHeroFigure('Active plans', '${summary.activeCount}'),
                    ]),
                  ],
                ),
              ),

              const SizedBox(height: FfSpace.md),

              // ── 2. The Next 30 Days Strip ─────────────────────────────
              FfRenewalStrip(
                subscriptions: allSubs,
                isPrivacyBlur: isPrivacyBlur,
                onSubscriptionTap: (sub) => _openDetail(context, sub),
              ),

              const SizedBox(height: FfSpace.md),

              // ── 3. Suggestions Moment Card (Dismissible) ──────────────
              if (hasSuggestions) ...[
                FfCard(
                  variant: FfCardVariant.tinted,
                  padding: const EdgeInsets.symmetric(
                    horizontal: FfSpace.md,
                    vertical: FfSpace.sm,
                  ),
                  onTap: () => _openSuggestionsSheet(context),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: ff.color.actionPrimary,
                          borderRadius: BorderRadius.circular(FfRadius.sm),
                        ),
                        child: Icon(
                          Icons.auto_awesome,
                          color: ff.color.onActionPrimary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: FfSpace.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${suggestions.length} recurring ${suggestions.length == 1 ? "pattern" : "patterns"} detected',
                              style: ff.text.titleSm.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Tap to review and add to tracker',
                              style: ff.text.bodySm.copyWith(
                                color: ff.color.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        tooltip: 'Dismiss suggestions banner',
                        onPressed: () {
                          setState(() => _isSuggestionsDismissed = true);
                        },
                      ),
                      const Icon(Icons.chevron_right_rounded, size: 20),
                    ],
                  ),
                ),
                const SizedBox(height: FfSpace.md),
              ],

              // ── 4. Insight Card (At most one) ─────────────────────────
              if (topSpendInsight != null) ...[
                FfCard(
                  density: FfDensity.compact,
                  variant: FfCardVariant.standard,
                  padding: const EdgeInsets.all(FfSpace.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lightbulb_outline_rounded,
                        size: 20,
                        color: ff.color.spark,
                      ),
                      const SizedBox(width: FfSpace.md),
                      Expanded(
                        child: Text(
                          topSpendInsight,
                          style: ff.text.bodySm.copyWith(
                            color: ff.color.textSecondary,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: FfSpace.md),
              ],

              // ── 5. Sort & Filter PillBar ──────────────────────────────
              FfPillBar<SubscriptionSort>(
                values: SubscriptionSort.values,
                selected: _currentSort,
                label: (s) => s.label,
                onSelected: (sort) {
                  setState(() => _currentSort = sort);
                },
              ),

              const SizedBox(height: FfSpace.md),

              // ── 6. Grouped Subscriptions Content ──────────────────────
              ..._buildGroupedContent(
                context,
                activeSubs: activeSubs,
                inactiveSubs: inactiveSubs,
                isPrivacyBlur: isPrivacyBlur,
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
        error:
            (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(FfSpace.xl),
                child: Text('Error loading subscriptions: $e'),
              ),
            ),
      ),
    );
  }

  List<Widget> _buildGroupedContent(
    BuildContext context, {
    required List<Subscription> activeSubs,
    required List<Subscription> inactiveSubs,
    required bool isPrivacyBlur,
  }) {
    if (_currentSort == SubscriptionSort.byCost) {
      final sortedByCost = [...activeSubs]..sort(
        (a, b) =>
            b.monthlyEquivalentAmount.compareTo(a.monthlyEquivalentAmount),
      );
      return [
        const FfSectionHeader(title: 'All Active Plans by Cost'),
        FfGroupedContainer(
          children:
              sortedByCost
                  .map(
                    (sub) => _buildSubscriptionRow(context, sub, isPrivacyBlur),
                  )
                  .toList(),
        ),
        if (inactiveSubs.isNotEmpty) ...[
          const SizedBox(height: FfSpace.lg),
          _buildInactiveSection(context, inactiveSubs, isPrivacyBlur),
        ],
      ];
    }

    if (_currentSort == SubscriptionSort.byCategory) {
      final Map<String, List<Subscription>> byCat = {};
      for (final sub in activeSubs) {
        byCat.putIfAbsent(sub.category, () => []).add(sub);
      }
      final sortedCategories = byCat.keys.toList()..sort();

      return [
        for (final cat in sortedCategories) ...[
          FfSectionHeader(title: cat, count: byCat[cat]!.length),
          FfGroupedContainer(
            children:
                byCat[cat]!
                    .map(
                      (sub) =>
                          _buildSubscriptionRow(context, sub, isPrivacyBlur),
                    )
                    .toList(),
          ),
          const SizedBox(height: FfSpace.md),
        ],
        if (inactiveSubs.isNotEmpty) ...[
          const SizedBox(height: FfSpace.sm),
          _buildInactiveSection(context, inactiveSubs, isPrivacyBlur),
        ],
      ];
    }

    // Default: By date urgency groups
    final thisWeek = <Subscription>[];
    final laterThisMonth = <Subscription>[];
    final nextMonthAndBeyond = <Subscription>[];

    for (final sub in activeSubs) {
      final days = sub.daysUntilRenewal();
      if (days <= 7) {
        thisWeek.add(sub);
      } else if (days <= 30) {
        laterThisMonth.add(sub);
      } else {
        nextMonthAndBeyond.add(sub);
      }
    }

    // Sort within groups by renewal date ascending
    thisWeek.sort(
      (a, b) => a.daysUntilRenewal().compareTo(b.daysUntilRenewal()),
    );
    laterThisMonth.sort(
      (a, b) => a.daysUntilRenewal().compareTo(b.daysUntilRenewal()),
    );
    nextMonthAndBeyond.sort(
      (a, b) => a.daysUntilRenewal().compareTo(b.daysUntilRenewal()),
    );

    return [
      if (thisWeek.isNotEmpty) ...[
        FfSectionHeader(title: 'This Week', count: thisWeek.length),
        FfGroupedContainer(
          children:
              thisWeek
                  .map(
                    (sub) => _buildSubscriptionRow(context, sub, isPrivacyBlur),
                  )
                  .toList(),
        ),
        const SizedBox(height: FfSpace.md),
      ],
      if (laterThisMonth.isNotEmpty) ...[
        FfSectionHeader(
          title: 'Later This Month',
          count: laterThisMonth.length,
        ),
        FfGroupedContainer(
          children:
              laterThisMonth
                  .map(
                    (sub) => _buildSubscriptionRow(context, sub, isPrivacyBlur),
                  )
                  .toList(),
        ),
        const SizedBox(height: FfSpace.md),
      ],
      if (nextMonthAndBeyond.isNotEmpty) ...[
        FfSectionHeader(
          title: 'Next Month & Beyond',
          count: nextMonthAndBeyond.length,
        ),
        FfGroupedContainer(
          children:
              nextMonthAndBeyond
                  .map(
                    (sub) => _buildSubscriptionRow(context, sub, isPrivacyBlur),
                  )
                  .toList(),
        ),
        const SizedBox(height: FfSpace.md),
      ],
      if (inactiveSubs.isNotEmpty) ...[
        _buildInactiveSection(context, inactiveSubs, isPrivacyBlur),
      ],
    ];
  }

  Widget _buildSubscriptionRow(
    BuildContext context,
    Subscription sub,
    bool isPrivacyBlur,
  ) {
    final ff = context.ff;
    final isMonthly = sub.billingFrequency == SubscriptionFrequency.monthly;
    final subline =
        isMonthly
            ? sub.category
            : '${sub.category} · ${CurrencyFormatter.formatAmount(sub.monthlyEquivalentAmount)}/mo';

    return FfRow(
      leading: FfMonogramTile(name: sub.merchant, size: FfRowTokens.iconTile),
      title: sub.merchant,
      subtitle: subline,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FfAmountText(
                amount: sub.amount,
                size: FfAmountSize.sm,
                showSign: false,
                isBlurred: isPrivacyBlur,
              ),
              Text(
                '/${sub.billingFrequency.shortLabel}',
                style: ff.text.labelSm.copyWith(
                  color: ff.color.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: FfSpace.x3s),
          FfRenewalChip(
            daysUntilRenewal: sub.daysUntilRenewal(),
            status: sub.status,
            compact: true,
          ),
        ],
      ),
      onTap: () => _openDetail(context, sub),
    );
  }

  Widget _buildInactiveSection(
    BuildContext context,
    List<Subscription> inactiveSubs,
    bool isPrivacyBlur,
  ) {
    final ff = context.ff;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(FfRadius.md),
          onTap: () {
            setState(() {
              _isPausedSectionExpanded = !_isPausedSectionExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: FfSpace.xs),
            child: Row(
              children: [
                Icon(
                  _isPausedSectionExpanded
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  size: 20,
                  color: ff.color.textSecondary,
                ),
                const SizedBox(width: FfSpace.xs),
                Text(
                  'Paused & Cancelled (${inactiveSubs.length})',
                  style: ff.text.titleSm.copyWith(
                    color: ff.color.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isPausedSectionExpanded) ...[
          const SizedBox(height: FfSpace.xs),
          FfGroupedContainer(
            children:
                inactiveSubs
                    .map(
                      (sub) =>
                          _buildSubscriptionRow(context, sub, isPrivacyBlur),
                    )
                    .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        FfSpace.pageMargin,
        FfSpace.md,
        FfSpace.pageMargin,
        104,
      ),
      children: [
        // Ghost strip
        const FfRenewalStrip(subscriptions: []),
        const SizedBox(height: FfSpace.x2l),
        FfEmptyState(
          icon: Icons.repeat_rounded,
          title: 'No subscriptions tracked',
          description:
              'Keep recurring charges in one place. Never be surprised by auto-renewals, see your true monthly commitment, and get reminders on device.',
          actionLabel: 'Add subscription',
          onAction: () => _openAddSheet(context),
        ),
        const SizedBox(height: FfSpace.md),
        Center(
          child: FfButton(
            label: 'Find from my transactions',
            variant: FfButtonVariant.text,
            onPressed: () => _openSuggestionsSheet(context),
          ),
        ),
      ],
    );
  }
}
