import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/formatting/currency_formatter.dart';
import '../../core/formatting/date_formatter.dart';
import '../../models/subscription.dart';
import '../../repositories/subscription_repository.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_privacy_badge.dart';
import '../../theme/stillwater_tokens.dart';
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

class _SubscriptionsScreenState extends ConsumerState<SubscriptionsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
            child: Center(child: FfPrivacyBadge(label: 'On-device')),
          ),
        ],
      ),
      body: subsAsync.when(
        data: (allSubs) {
          final activeSubs =
              allSubs
                  .where((s) => s.status == SubscriptionStatus.active)
                  .toList();
          final otherSubs =
              allSubs
                  .where((s) => s.status != SubscriptionStatus.active)
                  .toList();

          return Column(
            children: [
              // Monthly & Yearly Burn Rate Hero Card
              Padding(
                padding: const EdgeInsets.all(StillwaterTokens.spaceLg),
                child: FfCard(
                  variant: FfCardVariant.elevated,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monthly Subscriptions',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: StillwaterTokens.space2Xs),
                      Text(
                        CurrencyFormatter.formatINR(summary.monthlyTotal),
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: StillwaterTokens.spaceSm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Yearly: ${CurrencyFormatter.formatINR(summary.yearlyTotal)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                          Text(
                            '${summary.activeCount} active plans',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Recurring Suggestions Banner
              if (suggestionCount > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: StillwaterTokens.spaceLg,
                  ),
                  child: Material(
                    color: context.aiColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(
                      StillwaterTokens.radiusSm,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(
                        StillwaterTokens.radiusSm,
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RecurringSuggestionsSheet(),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(StillwaterTokens.spaceSm),
                        child: Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              color: context.aiColors.accent,
                              size: 18,
                            ),
                            const SizedBox(width: StillwaterTokens.spaceSm),
                            Expanded(
                              child: Text(
                                '$suggestionCount recurring payment patterns detected',
                                style: TextStyle(
                                  color: context.aiColors.accent,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: context.aiColors.accent,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: StillwaterTokens.spaceSm),

              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: 'Active (${activeSubs.length})'),
                  Tab(text: 'Paused & Cancelled (${otherSubs.length})'),
                ],
              ),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Active Tab
                    activeSubs.isEmpty
                        ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(
                              StillwaterTokens.spaceXl,
                            ),
                            child: FfEmptyState(
                              icon: Icons.subscriptions_outlined,
                              title: 'No active subscriptions',
                              description:
                                  'Add Netflix, Spotify, gym memberships, or cloud storage to forecast renewals accurately.',
                              actionLabel: 'Add Subscription',
                              onAction: () => _openAddSheet(context),
                            ),
                          ),
                        )
                        : ListView.separated(
                          padding: const EdgeInsets.all(
                            StillwaterTokens.spaceLg,
                          ),
                          itemCount: activeSubs.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(
                                height: StillwaterTokens.spaceSm,
                              ),
                          itemBuilder: (context, index) {
                            final sub = activeSubs[index];
                            final days = sub.daysUntilRenewal();
                            return FfCard(
                              onTap: () => _openDetail(context, sub),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.repeat_rounded,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: StillwaterTokens.spaceMd,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          sub.merchant,
                                          style: theme.textTheme.titleMedium,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Renews ${DateFormatter.formatFullDate(sub.nextRenewalDate)} (${days == 0 ? "Today" : (days == 1 ? "Tomorrow" : "in $days days")})',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color:
                                                    days <= 3
                                                        ? context
                                                            .secColors
                                                            .error
                                                        : theme
                                                            .colorScheme
                                                            .secondary,
                                                fontWeight:
                                                    days <= 3
                                                        ? FontWeight.w600
                                                        : FontWeight.normal,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        CurrencyFormatter.formatINR(sub.amount),
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Text(
                                        '/${sub.billingFrequency.name}',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color:
                                                  theme.colorScheme.secondary,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                    // Paused & Cancelled Tab
                    otherSubs.isEmpty
                        ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(StillwaterTokens.spaceXl),
                            child: FfEmptyState(
                              icon: Icons.pause_circle_outline_rounded,
                              title: 'No paused subscriptions',
                              description:
                                  'Paused or cancelled services will appear here for your reference.',
                            ),
                          ),
                        )
                        : ListView.separated(
                          padding: const EdgeInsets.all(
                            StillwaterTokens.spaceLg,
                          ),
                          itemCount: otherSubs.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(
                                height: StillwaterTokens.spaceSm,
                              ),
                          itemBuilder: (context, index) {
                            final sub = otherSubs[index];
                            return FfCard(
                              onTap: () => _openDetail(context, sub),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.secondary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.pause_rounded,
                                      color: theme.colorScheme.secondary,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: StillwaterTokens.spaceMd,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          sub.merchant,
                                          style: theme.textTheme.titleMedium,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          sub.status.displayName,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color:
                                                    theme.colorScheme.secondary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    CurrencyFormatter.formatINR(sub.amount),
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'subscriptions_add_fab',
        onPressed: () => _openAddSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Plan'),
      ),
    );
  }
}
