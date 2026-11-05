import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/subscription.dart';
import '../../repositories/subscription_repository.dart';
import '../../shared/widgets/ff_amount_text.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_grouped_container.dart';
import '../../shared/widgets/ff_list_row.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../shared/widgets/ff_section_header.dart';
import '../../shared/widgets/ff_segmented_pill.dart';
import '../../theme/stillwater_tokens.dart';
import '../../theme/stillwater_typography.dart';
import 'add_edit_subscription_sheet.dart';
import 'recurring_suggestions_sheet.dart';
import 'subscription_detail_screen.dart';
import 'subscriptions_controller.dart';

class SubscriptionsScreen extends ConsumerStatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  ConsumerState<SubscriptionsScreen> createState() =>
      _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends ConsumerState<SubscriptionsScreen> {
  bool _showInactive = false;

  void _openAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddEditSubscriptionSheet(),
    );
  }

  void _openDetail(BuildContext context, Subscription sub) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SubscriptionDetailScreen(subscription: sub),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final summary = ref.watch(subscriptionsSummaryProvider);
    final subsAsync = ref.watch(allSubscriptionsStreamProvider);
    final suggestionsAsync = ref.watch(recurringSuggestionsProvider);
    final suggestionCount = suggestionsAsync.value?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscriptions'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: StillwaterTokens.spaceLg),
            child: Center(
              child: FfPrivacyBadge(label: 'On-device', iconOnly: true),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'subscriptions_fab',
        tooltip: 'Add subscription',
        onPressed: () => _openAddSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Subscription'),
      ),
      body: subsAsync.when(
        data: (allSubs) {
          final activeSubs =
              allSubs
                  .where((s) => s.status == SubscriptionStatus.active)
                  .toList();
          final inactiveSubs =
              allSubs
                  .where((s) => s.status != SubscriptionStatus.active)
                  .toList();
          final displaySubs = _showInactive ? inactiveSubs : activeSubs;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              StillwaterTokens.spaceLg,
              StillwaterTokens.spaceMd,
              StillwaterTokens.spaceLg,
              104,
            ),
            children: [
              // ── 1. Burn Rate Hero Card ──────────────────────────────────
              FfCard(
                variant: FfCardVariant.elevated,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MONTHLY RECURRING COMMITMENT',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: StillwaterTokens.spaceXs),
                    Text(
                      CurrencyFormatter.formatAmount(summary.monthlyTotal),
                      style: StillwaterTypography.numHero(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: StillwaterTokens.spaceSm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Annual pace: ${CurrencyFormatter.formatAmount(summary.yearlyTotal)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        Text(
                          '${summary.activeCount} active ${summary.activeCount == 1 ? 'plan' : 'plans'}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: StillwaterTokens.spaceLg),

              // ── 2. Recurring Suggestions Alert Banner ───────────────────
              if (suggestionCount > 0) ...[
                FfCard(
                  variant: FfCardVariant.tinted,
                  padding: const EdgeInsets.all(StillwaterTokens.spaceMd),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const RecurringSuggestionsSheet(),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.15,
                          ),
                          borderRadius: BorderRadius.circular(
                            StillwaterTokens.radiusSm,
                          ),
                        ),
                        child: Icon(
                          Icons.auto_awesome,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: StillwaterTokens.spaceMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$suggestionCount recurring $suggestionCount == 1 ? "pattern" : "patterns" detected',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Tap to review and add to subscription tracker',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: StillwaterTokens.spaceLg),
              ],

              // ── 3. Segmented Pill Tab Bar ────────────────────────────────
              FfSegmentedPill<bool>(
                options: [
                  FfSegmentOption(
                    value: false,
                    label: 'Active (${activeSubs.length})',
                  ),
                  FfSegmentOption(
                    value: true,
                    label: 'Paused & Cancelled (${inactiveSubs.length})',
                  ),
                ],
                selectedValue: _showInactive,
                onSelected: (val) {
                  setState(() {
                    _showInactive = val;
                  });
                },
              ),

              const SizedBox(height: StillwaterTokens.spaceLg),

              // ── 4. Subscriptions List ────────────────────────────────────
              FfSectionHeader(
                title:
                    _showInactive ? 'Inactive Plans' : 'Active Subscriptions',
              ),

              if (displaySubs.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: StillwaterTokens.space2Xl,
                  ),
                  child: FfEmptyState(
                    icon:
                        _showInactive
                            ? Icons.pause_circle_outline_rounded
                            : Icons.repeat_rounded,
                    title:
                        _showInactive
                            ? 'No inactive subscriptions'
                            : 'No active subscriptions',
                    description:
                        _showInactive
                            ? 'Subscriptions you pause or cancel will remain stored here safely.'
                            : 'Track recurring services like Netflix, Spotify, iCloud, gym, and broadband.',
                    actionLabel: _showInactive ? null : 'Add Subscription',
                    onAction:
                        _showInactive ? null : () => _openAddSheet(context),
                  ),
                )
              else
                FfGroupedContainer(
                  children:
                      displaySubs.map((sub) {
                        final days = sub.daysUntilRenewal();
                        final isDueSoon = sub.isDueSoon(daysThreshold: 3);

                        String renewalText;
                        if (sub.status != SubscriptionStatus.active) {
                          renewalText = sub.status.displayName;
                        } else if (days == 0) {
                          renewalText = 'Renews today';
                        } else if (days == 1) {
                          renewalText = 'Renews tomorrow';
                        } else if (days < 0) {
                          renewalText = 'Renewed ${days.abs()}d ago';
                        } else {
                          renewalText =
                              'Renews in ${days}d (${DateFormatter.formatShortDate(sub.nextRenewalDate)})';
                        }

                        return FfListRow(
                          leading: Container(
                            width: StillwaterTokens.iconTileSize,
                            height: StillwaterTokens.iconTileSize,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer
                                  .withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(
                                StillwaterTokens.radiusSm,
                              ),
                            ),
                            child: Icon(
                              _getSubscriptionIcon(sub.merchant),
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          title: sub.merchant,
                          subtitle:
                              '${sub.billingFrequency.displayName} · $renewalText',
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              FfAmountText(
                                amount: sub.amount,
                                size: FfAmountSize.sm,
                                showSign: false,
                              ),
                              if (isDueSoon &&
                                  sub.status == SubscriptionStatus.active)
                                Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.statusColors.warningContainer,
                                    borderRadius: BorderRadius.circular(
                                      StillwaterTokens.radiusXs,
                                    ),
                                  ),
                                  child: Text(
                                    'Due Soon',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: context.statusColors.warning,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          onTap: () => _openDetail(context, sub),
                        );
                      }).toList(),
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

  static IconData _getSubscriptionIcon(String merchant) {
    final lower = merchant.toLowerCase();
    if (lower.contains('netflix') ||
        lower.contains('prime') ||
        lower.contains('hotstar') ||
        lower.contains('youtube') ||
        lower.contains('disney')) {
      return Icons.movie_outlined;
    } else if (lower.contains('spotify') ||
        lower.contains('apple music') ||
        lower.contains('gaana') ||
        lower.contains('wynk')) {
      return Icons.music_note_outlined;
    } else if (lower.contains('cloud') ||
        lower.contains('google') ||
        lower.contains('drive') ||
        lower.contains('dropbox')) {
      return Icons.cloud_outlined;
    } else if (lower.contains('gym') ||
        lower.contains('fitness') ||
        lower.contains('cult')) {
      return Icons.fitness_center_rounded;
    } else if (lower.contains('wifi') ||
        lower.contains('broadband') ||
        lower.contains('airtel') ||
        lower.contains('jio')) {
      return Icons.wifi_rounded;
    }
    return Icons.repeat_rounded;
  }
}
