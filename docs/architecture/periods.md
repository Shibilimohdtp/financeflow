# Reporting periods (ADR, 2026-11-05)

`lib/core/period/period.dart` is the only place that defines day, week,
month, year and custom ranges. Home (`dashboardPeriodProvider`), insights
(`AnalyticsCalculator.periodFor`), budgets (`BudgetCalculator.getPeriodBounds`)
and the transaction list grouping all derive their boundaries from it.

- Ranges are half-open local calendar days `[start, endExclusive)`. APIs that
  need an inclusive end use `endInclusive` (last millisecond).
- Arithmetic is calendar-based (`DateTime(y, m, d + n)`), never
  `Duration(days: n)`, so DST transitions cannot shift a boundary.
- Weeks start on Monday by default. `weekStart` is supported in `Period`;
  a user preference needs a settings field and is deferred to the next
  backup-gated schema migration.
- "Versus last period" is like-for-like: a period in progress is compared with
  the same number of elapsed days at the start of the previous period
  (clamped to its length). Finished periods compare whole-to-whole.
- Income and spending totals come from `LedgerTotals` (`lib/services/
  ledger_totals.dart`), which uses the per-transaction definitions in
  `Transaction.earnedIncomeAmount` / `consumptionExpenseAmount`. The full EMI
  counts as spending (see `transaction-semantics.md`).

## Shared report period

`reportPeriodProvider` (`lib/core/period/report_period_provider.dart`) is
the single period for Home and Insights; both render `FfPeriodBar`
(prev/next plus a chooser for today/week/month/year/custom). The Money tab
keeps its own `TransactionQuery.period` (it also allows "All time"), and
Insights drill-downs copy the report period into that query, so a number
on Insights always matches the list it opens.

Budgets still browse months through `selectedDashboardMonthProvider`; that
is owned by the budgets redesign.

Known gap: `DateTime.now()` is read when providers build, so a screen left
open across midnight keeps the old "today" until it rebuilds.
