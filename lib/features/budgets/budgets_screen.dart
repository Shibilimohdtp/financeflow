import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/money/money_math.dart';
import '../../core/period/period.dart';
import '../../models/budget.dart';
import '../../models/category.dart';
import '../../services/budgets/budget_board.dart';
import '../../services/budgets/budget_engine.dart';
import '../../services/budgets/budget_setup_suggester.dart';
import '../../shared/widgets/ff_card.dart';
import '../../shared/widgets/ff_divider.dart';
import '../../shared/widgets/ff_empty_state.dart';
import '../../shared/widgets/ff_navigation.dart';
import '../../shared/widgets/ff_period_bar.dart';
import '../../shared/widgets/ff_skeleton_loader.dart';
import '../../shared/widgets/ff_surfaces.dart';
import '../../shared/widgets/ff_toast.dart';
import '../../theme/ff.dart';
import '../categories/categories_controller.dart';
import '../dashboard/dashboard_controller.dart';
import '../loans/loans_screen.dart';
import '../settings/settings_controller.dart';
import '../subscriptions/subscriptions_screen.dart';
import '../transactions/transaction_list_utils.dart';
import 'budget_detail_screen.dart';
import 'budget_format.dart';
import 'budget_sheets.dart';
import 'budgets_controller.dart';
import 'plan_providers.dart';
import 'widgets/budget_group_section.dart';
import 'widgets/plan_bills_card.dart';
import 'widgets/plan_insight_card.dart';
import 'widgets/plan_setup.dart';
import 'widgets/plan_summary.dart';

/// The Plan tab (Stillwater Bloom recipe A, on the aurora): "Am I on track,
/// what can I safely spend today, and what should I change?"
///
/// Top to bottom: header, period bar, the key figure (safe to spend today),
/// the plan hero, one suggestion, Bills & EMIs, the budgets grouped by
/// Essentials / Lifestyle / Other (most urgent first), budgets on other
/// cadences, and the privacy footer. Before any budget exists it shows a
/// suggested setup from real spending.
class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key, this.onShowTransactions});

  /// Opens the Money tab with a query. When null (Plan pushed as a page)
  /// the hero has no "see spending" button.
  final ValueChanged<TransactionQuery>? onShowTransactions;

  static const _units = {PeriodUnit.week, PeriodUnit.month, PeriodUnit.year};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardAsync = ref.watch(budgetBoardProvider);
    final period = ref.watch(planPeriodProvider);
    final isPrivacyBlur =
        ref.watch(settingsStreamProvider).valueOrNull?.isPrivacyBlurEnabled ??
        false;
    final budgetsAsync = ref.watch(activeBudgetsStreamProvider);
    final hasAnyBudget = (budgetsAsync.valueOrNull ?? const []).isNotEmpty;
    // Until the budgets have loaded, show the skeleton rather than the
    // first-run setup.
    final loading = !budgetsAsync.hasValue && !budgetsAsync.hasError;
    final canPop = Navigator.of(context).canPop();

    return FfAurora(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButtonLocation: FfDock.fabLocation,
        floatingActionButton:
            hasAnyBudget
                ? FloatingActionButton.extended(
                  heroTag: 'budgets_add_fab',
                  tooltip: 'Add budget',
                  onPressed: () => openBudgetSheet(context),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add budget'),
                )
                : null,
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value:
              Theme.of(context).brightness == Brightness.dark
                  ? SystemUiOverlayStyle.light
                  : SystemUiOverlayStyle.dark,
          child: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              color: context.ff.color.actionPrimary,
              onRefresh: () async {
                ref.invalidate(activeBudgetsStreamProvider);
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: PlanHeader(
                      onBack:
                          canPop
                              ? () => Navigator.of(context).maybePop()
                              : null,
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.only(
                      bottom:
                          FfDock.insetOf(context) + FfSpace.x4l + FfSpace.x3l,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: FfSpace.sm),
                        ...(loading
                                ? const AsyncValue<BudgetBoard>.loading()
                                : boardAsync)
                            .when(
                              loading: () => const [_PlanSkeleton()],
                              error:
                                  (e, _) => [
                                    Padding(
                                      padding: const EdgeInsets.all(
                                        FfSpace.pageMargin,
                                      ),
                                      child: FfEmptyState(
                                        icon: Icons.error_outline_rounded,
                                        title: 'Couldn\'t load your plan',
                                        description:
                                            'Your budgets and transactions are safe on this '
                                            'device. Try again in a moment.',
                                        actionLabel: 'Try again',
                                        onAction: () {
                                          ref.invalidate(
                                            activeBudgetsStreamProvider,
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                              data:
                                  (board) =>
                                      !hasAnyBudget
                                          ? [
                                            _setup(context, ref, isPrivacyBlur),
                                          ]
                                          : _plan(
                                            context,
                                            ref,
                                            board,
                                            period,
                                            isPrivacyBlur,
                                          ),
                            ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _plan(
    BuildContext context,
    WidgetRef ref,
    BudgetBoard board,
    Period period,
    bool isPrivacyBlur,
  ) {
    final insight = ref.watch(planInsightProvider);
    final bills = board.bills;
    const gap = SizedBox(height: FfSpace.xl);
    final periodName = _periodName(period);

    return [
      FfPeriodBar(
        period: period,
        units: _units,
        chooserTitle: 'Show plan for',
        onChanged: (p) {
          if (p == null) return;
          ref.read(planPeriodProvider.notifier).state = p;
          // The budget detail and Home's budget card still read the
          // dashboard month until they move to the plan period (B7c, B7d).
          if (p.unit == PeriodUnit.month) {
            ref.read(selectedDashboardMonthProvider.notifier).state = p.start;
          }
        },
      ),
      const SizedBox(height: FfSpace.xs),
      if (board.results.isNotEmpty) ...[
        PlanKeyFigure(
          board: board,
          isPrivacyBlur: isPrivacyBlur,
          onToggleBlur:
              () => ref
                  .read(settingsControllerProvider.notifier)
                  .setPrivacyBlurEnabled(!isPrivacyBlur),
        ),
        const SizedBox(height: FfSpace.md),
        PlanHero(
          board: board,
          isPrivacyBlur: isPrivacyBlur,
          onOpenSpending:
              onShowTransactions == null
                  ? null
                  : () => onShowTransactions!(
                    TransactionQuery(
                      period: board.period,
                      budgetScope: BudgetScope(
                        categoryIds: {
                          for (final r in board.results)
                            ...r.budget.categoryIds,
                        },
                        label: '$periodName plan',
                      ),
                    ),
                  ),
        ),
      ] else
        _NoBudgetsThisPeriod(period: period),
      if (insight != null) ...[
        const SizedBox(height: FfSpace.md),
        PlanInsightCard(
          insight: insight,
          isPrivacyBlur: isPrivacyBlur,
          periodName: periodName,
          onApplyLimit:
              insight.result == null
                  ? null
                  : (limit) =>
                      _applyLimit(context, ref, insight.result!.budget, limit),
          onOpenBudget:
              insight.result == null
                  ? null
                  : () => _openBudget(context, insight.result!),
        ),
      ],
      for (final group in board.groups) ...[
        gap,
        BudgetGroupSection(
          key: ValueKey('group-${group.group.name}'),
          title: group.group.label,
          results: group.results,
          isPrivacyBlur: isPrivacyBlur,
          onOpen: (r) => _openBudget(context, r),
        ),
      ],
      if (board.otherCadence.isNotEmpty) ...[
        gap,
        BudgetGroupSection(
          key: const ValueKey('group-other-periods'),
          title: 'Other periods',
          results: board.otherCadence,
          isPrivacyBlur: isPrivacyBlur,
          showTotals: false,
          showPeriod: true,
          onOpen: (r) => _openBudget(context, r),
        ),
      ],
      if (bills.occurrences.isNotEmpty) ...[
        gap,
        PlanBillsCard(
          bills: bills,
          isPrivacyBlur: isPrivacyBlur,
          onOpenSubscriptions:
              () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SubscriptionsScreen()),
              ),
          onOpenLoans:
              () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const LoansScreen())),
        ),
      ],
      gap,
      const _PrivacyFooter(),
    ];
  }

  Widget _setup(BuildContext context, WidgetRef ref, bool isPrivacyBlur) {
    final suggestion = ref.watch(budgetSetupSuggestionProvider);
    final categories = {
      for (final c
          in ref.watch(categoriesStreamProvider).valueOrNull ??
              const <Category>[])
        c.id: c,
    };
    final bills = ref.watch(budgetBoardProvider).valueOrNull?.bills;
    return PlanSetup(
      suggestion: suggestion,
      categories: categories,
      monthlyBillsMinor:
          bills == null
              ? 0
              : bills.occurrences.fold(0, (s, o) => s + o.amountMinor),
      isPrivacyBlur: isPrivacyBlur,
      onAddBudget: () => openBudgetSheet(context),
      onCreate: (picked) => _createSuggested(context, ref, picked, categories),
    );
  }

  Future<void> _createSuggested(
    BuildContext context,
    WidgetRef ref,
    List<SuggestedBudget> picked,
    Map<String, Category> categories,
  ) async {
    final now = ref.read(planNowProvider);
    final start = Period.containing(PeriodUnit.month, now).start;
    final controller = ref.read(budgetsControllerProvider.notifier);
    try {
      for (final s in picked) {
        final c = categories[s.categoryId]!;
        await controller.saveBudget(
          Budget(
            id: const Uuid().v4(),
            name: c.name,
            categoryId: c.id,
            categoryName: c.name,
            categoryIcon: c.iconIdentifier,
            categoryColor: c.colorTokenIdentifier,
            amountLimit: MoneyMath.fromMinor(s.suggestedMinor),
            startDate: start,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
      if (context.mounted) {
        FfToast.show(
          context,
          message:
              picked.length == 1
                  ? 'Budget created.'
                  : '${picked.length} budgets created.',
        );
      }
    } catch (_) {
      if (context.mounted) {
        FfToast.show(
          context,
          message: 'Could not create the budgets. Nothing else changed.',
          tone: FfToastTone.error,
        );
      }
    }
  }

  /// A one-tap suggestion: changes the budget's limit (not just this
  /// period; that needs the persistence slice) and offers Undo.
  Future<void> _applyLimit(
    BuildContext context,
    WidgetRef ref,
    Budget budget,
    int newLimitMinor,
  ) async {
    final controller = ref.read(budgetsControllerProvider.notifier);
    final before = budget.amountLimit;
    try {
      await controller.saveBudget(
        budget.copyWith(
          amountLimit: MoneyMath.fromMinor(newLimitMinor),
          updatedAt: DateTime.now(),
        ),
      );
      if (!context.mounted) return;
      FfToast.show(
        context,
        message:
            '${budget.name} is now ${BudgetFormat.money(newLimitMinor)} '
            'a ${BudgetFormat.periodNoun(budget.period)}.',
        actionLabel: 'Undo',
        onAction:
            () => controller.saveBudget(
              budget.copyWith(amountLimit: before, updatedAt: DateTime.now()),
            ),
      );
    } catch (_) {
      if (context.mounted) {
        FfToast.show(
          context,
          message: 'Could not change the limit.',
          tone: FfToastTone.error,
        );
      }
    }
  }

  void _openBudget(BuildContext context, BudgetPeriodResult r) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => BudgetDetailScreen(
              budget: r.budget,
              onShowTransactions: onShowTransactions,
            ),
      ),
    );
  }

  static String _periodName(Period p) =>
      p.unit == PeriodUnit.month
          ? periodLabel(p).split(' ').first
          : periodLabel(p);
}

/// Budgets exist, but none on the viewed cadence (for example only weekly
/// budgets while viewing a month).
class _NoBudgetsThisPeriod extends StatelessWidget {
  const _NoBudgetsThisPeriod({required this.period});

  final Period period;

  @override
  Widget build(BuildContext context) {
    final noun = switch (period.unit) {
      PeriodUnit.week => 'weekly',
      PeriodUnit.year => 'yearly',
      _ => 'monthly',
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FfSpace.pageMargin),
      child: FfCard(
        variant: FfCardVariant.tinted,
        density: FfDensity.compact,
        child: Text(
          'No $noun budgets yet. Your other budgets are listed below in '
          'their own periods.',
          style: context.ff.text.bodySm,
        ),
      ),
    );
  }
}

class _PrivacyFooter extends StatelessWidget {
  const _PrivacyFooter();

  @override
  Widget build(BuildContext context) {
    final ff = context.ff;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FfSpace.pageMargin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shield_outlined,
            size: FfIconSize.xs,
            color: ff.color.textSecondary,
          ),
          const SizedBox(width: FfSpace.xs),
          Flexible(
            child: Text(
              'Worked out on this device. Nothing leaves your phone.',
              style: ff.text.label,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// Loading: shaped like the key figure, the hero and a group card.
class _PlanSkeleton extends StatelessWidget {
  const _PlanSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: FfSpace.pageMargin),
      child: FfSkeletonLoader(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: FfSpace.md),
            const FfSkeletonBlock(width: FfSpace.x4l * 2, height: FfSpace.sm),
            const SizedBox(height: FfSpace.xs),
            const FfSkeletonBlock(width: FfSpace.x4l * 3, height: FfSpace.x3l),
            const SizedBox(height: FfSpace.lg),
            // Shaped like the rose plan hero.
            const FfSkeletonBlock(
              height: FfSpace.x4l * 3,
              borderRadius: FfHeroTokens.radius,
            ),
            const SizedBox(height: FfSpace.xl),
            Container(
              decoration: FfCard.decorationOf(
                context,
                density: FfDensity.compact,
              ),
              child: const Column(
                children: [
                  FfTransactionSkeletonRow(),
                  FfDivider(),
                  FfTransactionSkeletonRow(),
                  FfDivider(),
                  FfTransactionSkeletonRow(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
