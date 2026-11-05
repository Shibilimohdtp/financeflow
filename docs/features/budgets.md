# Budgets: model, semantics and decisions

Status: domain layer implemented (slice a, 2026-11-05). Persistence, UI and
integrations follow in later slices; until then the existing screens still
use `BudgetCalculator`.

Code: `lib/services/budgets/` (`budget_ledger.dart`, `budget_engine.dart`,
`budget_board.dart`, `committed_bills.dart`, `budget_insights.dart`,
`budget_setup_suggester.dart`), model in `lib/models/budget.dart`. Tests:
`test/unit/budgets/`.

## Model

A budget covers one or more categories (`categoryIds`; older budgets read as
`[categoryId]`) on a cadence (weekly, monthly, yearly, or one custom range)
with a limit in integer minor units (`limitMinor`; older budgets convert their
`double amountLimit` once). It belongs to a fixed group (Essentials,
Lifestyle, Other) and has an alert threshold and an opt-in rollover mode.

`BudgetAdjustment` changes one budget's limit for one period: "this period
only" changes, and moves between budgets (two adjustments sharing a
`transferId`).

## Money

All budget arithmetic is in integer minor units. A ledger `double` becomes an
integer exactly once, in `MoneyMath.toMinor`, and sums use
`MoneyMath.sumMinor`, so a budget total and the matching transaction list
total agree to the cent. The ledger itself stays `double` until a separate,
backup-gated migration.

## What counts

A transaction counts toward a category budget when:

- its category is one of the budget's categories,
- its date is inside the budget's period (half-open local days, see
  `docs/architecture/periods.md`), including future-dated transactions,
- the amount is `Transaction.consumptionExpenseAmount` (see
  `transaction-semantics.md`): spending, legacy cash, unlinked EMIs and
  investment fees count; transfers, lending, income and investment principal
  do not,
- and it is **not** a payment linked to a tracked subscription or loan
  (`linkedSubscriptionId` / `linkedLoanId`). Those form the separate
  "Bills & EMIs" line (owner decision D1, 2026-11-05). The link is the only
  test; merchant and category text are never used.

There is no refund or split transaction type. A refund recorded as income
does not reduce budget spending. Recategorising a transaction moves it
between budgets on the next read; nothing is cached.

A budget whose categories were deleted or archived reads as zero spending and
is never deleted automatically. When two budgets share a category, the plan
total counts each transaction once.

## Periods

- Weekly, monthly and yearly budgets use `Period.containing` with the
  week-start preference.
- A custom budget is one inclusive day range; times of day are ignored. An
  old custom budget without an end date runs for one year.
- **Mid-period budgets are not pro-rated.** Spending earlier in the period is
  real money, so a budget created on the 12th gets the full limit and the
  period's earlier spending counts. The UI says so.

## Limit for a period

`limit = max(0, plan + adjustments in the period + carried amount)`.

Rollover is opt-in (`off`, `unspent`, `both`; owner decision D3). The carried
amount is replayed from the later of `rolloverSince` and the budget's first
period, at most 12 periods back, so it always reflects the current ledger and
can't drift. `unspent` carries only leftovers; `both` also carries
overspending. Turning rollover on never adds money to earlier periods.

## Pace, forecast and status

- **Expected by today**: limit × elapsed days ÷ total days (the pace marker).
- **Forecast**: spent + days after today × a blended daily rate. The blend is
  w × this period's pace + (1 − w) × the usual pace, where w is the share of
  the period elapsed. The usual pace is the median daily spending over the
  previous three periods that had any spending; with none, the part of the
  limit not taken by one-off payments, spread evenly.
- A single transaction of at least 40% of the limit is a **one-off** (rent,
  an appliance). It counts as spent but never sets the pace.
  Future-dated transactions count as spent but do not set the pace either.
- **Status**: *over* when spent > limit. *At risk* when the forecast exceeds
  the limit by more than 5%, or spending is past the alert threshold and the
  forecast exceeds the limit at all. Otherwise *on track*. Being past the
  threshold alone is not "at risk".
- Day-of-week weighting is deferred: there is too little data per category
  for it to be reliable.

## The plan (board)

For a viewed period, the plan includes the budgets on that cadence (monthly
in a month view, weekly in a week view). Other cadences are listed separately
in their own period around the viewed day.

- **Left** is the sum of each budget's own leftover; one overspent budget
  does not silently consume the others, and its overspending is shown
  separately.
- **Safe to spend today** = left ÷ days left including today. Bills are their
  own line and do not reduce it.
- **Plan status**: over if total spending exceeds the plan; needs attention
  if any budget is over or at risk, or the total forecast overruns by more
  than 5%; otherwise on track.

## Bills & EMIs

Active subscriptions and active loans produce due dates inside the period
(monthly dates keep their day, clamped to short months). A due date before the
subscription's or loan's next due date is settled, because those dates only
move forward once a payment is recorded or skipped. Linked payments in the
period settle the earliest remaining dates.

## Insights and suggestions

From up to six closed periods (dropping leading periods with no data):

- With at least three, if the budget went over in at least half, suggest
  raising it to the median spend (rounded up). Also show how many average
  purchases would need to be skipped instead.
- If every period used under 75% of the plan, suggest lowering it to the
  median plus 10% (rounded up).

## Suggested setup

This uses the three full calendar months before the current one. For each
eligible category, it suggests the median monthly spending, rounded up to a
friendly figure with `MoneyMath.niceCeilMinor`. A category needs spending in
at least two of those months once two months of data exist. Income is
estimated as the median earned income.

The 50/30/20 rule is shown as a guide (`PlanSplit`, with bills counted as
needs) and never fills in amounts.
