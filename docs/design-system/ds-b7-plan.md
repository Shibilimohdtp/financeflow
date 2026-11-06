# DS-B7 · Budgets (Plan tab) in Stillwater Bloom: audit and plan

Status: **approved by the owner on 2026-11-06**, including every recommendation in section 7. B7a (shared additions) is done; B7b (Plan tab) is next.
Baseline at `6586edd`: `flutter analyze` clean; budgets widget, calculator, `test/unit/budgets/` and smoke tests all
pass (80 tests); the audit numbers are in the CHANGELOG (DS-B6 row). The Budgets files together hold **138 legacy-shim
references** and **65 raw style leaks** (`fontSize`, `TextStyle(`, raw alpha, `Colors.*`, raw sheets and pickers,
`PopupMenuButton`, `AppBar(`).

Current-state screenshots (new capture test `tool/screenshots/plan_screenshots_test.dart`, light and dark):
`screenshots/ds-b7/before_plan.png`, `before_plan_closed.png`, `before_plan_empty.png`, `before_detail.png`,
`before_sheet.png`.

## 1. Audit: current Budgets against Bloom

### What the screenshots show

| # | Problem | Where |
|---|---|---|
| 1 | No key figure. The biggest number is "Total spent", inside a plain card. "Safe to spend today" doesn't exist. | Plan |
| 2 | The status contradicts itself. The pool card says "Healthy & within planned limit" while its own badge says "1 over limit". | Plan |
| 3 | **Closed months are wrong.** October shows "31d left" on every budget and "Spend under ₹303/day for the next 31 days". | Plan, closed month |
| 4 | There is no pace. Groceries at 70% on day 6 shows a green "₹3,590 left" check, and nothing marks expected-by-today. | Plan rows |
| 5 | The projection is naive. Dining's "Projected spend" is **₹34,000** for a ₹6,000 budget on day 6 (spent ÷ days × 30). | Detail |
| 6 | Three summaries overlap: the pool card, "Budget intelligence" and the per-card status all say the same thing in different words. | Plan |
| 7 | Bills are double counted (D1 violated). The old `BudgetCalculator` and the detail list count linked subscription and loan payments in category budgets. | Calculator, detail |
| 8 | The detail goes stale. `BudgetDetailScreen(budget:)` holds the object it was opened with, so an edit doesn't show until you reopen it. | Detail |
| 9 | The detail has no history, trend, run-out date or link to Money. The title repeats ("Dining / Dining · Monthly"). | Detail |
| 10 | The empty state ignores three months of real spending, so there's no suggested setup. | Empty |
| 11 | The sheet asks for a required "Budget Name" before anything else. Alert reads "80% (₹0)" before an amount is entered. There's no per-day preview. It opens with a raw `showModalBottomSheet`. | Sheet |
| 12 | It isn't Bloom: plain `AppBar` (no aurora); ALL-CAPS labels ("TOTAL BUDGET POOL", "DAILY ALLOWANCE", "PLANNED SPENDING LIMIT"); bold amounts instead of light split ones; a one-off month header; a filter `PopupMenuButton`; brick bars and green "left" text (status is colour plus an icon, never words); "Add Budget" title case. | All |
| 13 | Hard-coded copy. The Home card's semantics read a raw double ("Budget exceeded by 800.0"). Font sizes 9 and 10 sit below the type scale. | Home card, Plan |
| 14 | Dead code. `budgets_placeholder_screen.dart` is unused, and so is `dashboard/widgets/month_selector_header.dart` (Budgets has its own private copy). | — |

### What works and should stay

- `BudgetEngine`, `BudgetBoard`, `CommittedBills`, `BudgetInsight` and `BudgetSetupSuggester` are complete and tested
  (`test/unit/budgets/`), and they already fix items 2–5, 7 and 10 once wired.
- Category tiles, `FfAmountText` in rows and `FfEmptyState` are already in use.

## 2. Target layout, block by block

### Plan tab (`budgets_screen.dart`): recipe A on `FfAurora`

| Block | Component | Content |
|---|---|---|
| Header on the aurora | `HomeHeader`-style `PreferredSizeWidget` (SafeArea, AnnotatedRegion) | Title "Plan", a label line with the cadence ("Monthly plan"), `FfPrivacyBadge('On-device')` |
| Key figure | `text.label` + `FfAmountText(size: hero, style: split)` + `FfCircleButton` (hide amounts, shared setting) | "Safe to spend today" ₹629 · quiet line "₹15,730 left of ₹33,000 · 25 days to go" |
| Hero | `FfHeroCard(tone: rose)` | Leading `FfProgressRing(value: spent/plan, icon: pie)`; title "November"; subtitle in words ("On track" / "Needs attention" / "Over plan") plus `FfBadge` with an icon; split `FfStatTile`s "Spent ₹17,270" · "Plan ₹33,000"; **pace bar** (`FfProgressBar(onHero:, pace:)`) and the line "₹2,140 ahead of pace" or "₹900 under pace" |
| Period | `FfPeriodBar(units: week/month/year)` | Prev/next and the chooser; closed periods show final results |
| Bills & EMIs | `FfGroupedContainer` with 2 `FfRow`s (`FfIconTile`) | "Subscriptions · ₹649 due 24 Nov" → Subscriptions; "Loans & EMIs · ₹29,600 paid" with a check → Loans. Section header shows "₹30,249 committed". Not part of safe-to-spend (D1). |
| Insight (one) | `FfCard(variant: tinted)` with `FfIconTile` and `FfButton(secondary)` | The single best item, in this order: a raise suggestion ("Dining went over in 3 of the last 3 months · **Raise to ₹6,600**", or "skip about 1 meal out"); a run-out warning ("At this pace Groceries runs out around 24 Nov"); a lower suggestion; for a closed period that stayed within plan, a quiet "Within plan 3 months in a row". Hidden when nothing is useful. |
| Groups | `FfSectionHeader(title: 'Essentials', trailing: '₹9,610 of ₹16,000')` + one compact card per group | Order: Essentials, Lifestyle, Other; rows inside each group sorted by urgency (over → at risk → on track) |
| Budget row | Feature widget `BudgetRow`, composed only of `Ff*` | `FfCategoryTile` (+ `FfCornerBadge(warning)` when over) · name (`title`) · "₹6,800 of ₹6,000" (`label`, inline amounts) · trailing `FfBadge` ("Over ₹800" / "At risk") or "₹3,590 left" · full-width `FfProgressBar(pace:)`; the whole row is a 48 dp+ tap target to the detail; one merged semantics node |
| Other cadences | `FfSectionHeader('Other periods')` + the same rows with their own period label | Weekly, yearly and custom budgets in their own period around the viewed day; not added to the hero |
| Footer | Privacy line, bottom spacer | |
| Add | `FloatingActionButton.extended` "Add budget" (like Home and Money) | |

States:
- **Loading:** skeletons shaped like the key figure, the hero and 3 rows.
- **Error:** `FfEmptyState` "Couldn't load your plan" with "Try again".
- **Closed period:** the key figure becomes "Left at the end" (or "Over plan by"); no safe-to-spend, no pace.
- **Amounts hidden, 2× text** (split amounts shrink), **dark**, **reduced effects** (the hero drops grain).

**Empty state:** `FfEmptyState` ("Plan your month", "Based on what you spent in the last 3 months") leads into a
**Suggested setup** card. It is an `FfGroupedContainer` of `FfRow.checkbox`, each with a category tile, "Usually
₹5,840" and a trailing ₹6,000 (from `niceCeilMinor`). Below it: a total line, a 50/30/20 *guide* (needs · wants ·
left, from `PlanSplit`, words and numbers, nothing pre-filled), and `FfButton` "Create 4 budgets" plus a text button
"Start from scratch". With no history it shows only the empty state and "Add budget".

### Budget detail (`budget_detail_screen.dart`): recipe D

| Block | Component | Content |
|---|---|---|
| App bar | `FfAppBar(title: name, subtitle: 'Monthly · Essentials')`, actions: edit, `FfMenuButton` (archive, delete) | Watches the budget **by id** from the stream (fixes item 8) |
| Hero | `FfHeroCard(tone: rose, leading: FfProgressRing(spent/limit))` | Title "Left to spend" (or "Over by"); subtitle status in words + badge; `FfAmountText(hero, split)`; breakdown "Spent ₹6,800 · limit ₹6,000" (carried and adjustments are added after slice b); 3 figures via new `FfHeroFigures`: "Per day ₹0" · "Forecast ₹7,900" · "Days left 25" |
| Attention | `FfCard(variant: warning)` | Over or at risk: "₹800 over · Raise to ₹6,600" (permanent limit for now; "this month only" after slice b) |
| Trend | `FfCard` → `titleLg` "This month" + `FfLineChart` | Cumulative spend per day up to today **against the ideal pace line** (new reference series) |
| History | `FfCard` → `FfMonthGrid` (6 months, new `under`/`over` statuses) | Notes are the amounts; a line underneath: "Within plan in 2 of the last 6 months" |
| Transactions | `FfSectionHeader('Spending this month', trailing: 'See all in Money')` + one compact card of Money's `TransactionTile` rows | The total line equals the hero's spent to the cent. "See all" opens Money with the exact filter (section 4). |
| Details | `FfGroupedContainer` of `FfKeyValueRow` | Period dates; "Alert at 80% · ₹4,800"; "Started 12 Nov · earlier spending in the month counts" when started mid-period |
| Actions | `FfButton(outlined)` archive; delete via `FfDialog.confirm` | Move money and adjust-this-period arrive with slice b |

### Add / edit (`add_edit_budget_sheet.dart`): recipe E

`showFfSheet` → `FfSheetHeader("New budget" / "Edit budget")`, then:
- `FfAmountField` first, with the live preview "₹6,500 a month · about ₹217 a day" (from the period's day count).
- Category as `FfChip` wrap, single-select for now; choosing one fills the amount from the suggester ("Usually ₹5,840 · use ₹6,000").
- Name is optional and defaults to the category name.
- Cadence as `FfSegmentedPill` (Monthly / Weekly / Yearly / Custom); custom uses `pickFfDateRange`.
- Alert as `FfSegmentedPill` (75% / 80% / 90% / Off), with the amount shown ("at ₹5,200").
- `FfSheetFooter` "Save budget".

Group and rollover rows appear only with slice b. Validation copy goes through `CurrencyFormatter` and contains no "rupees".

### Home budget card (`budget_overview_card.dart`)

This is a compact Bloom summary in `FfCard.decorationOf`:
- Label "Plan · November", then "Safe to spend today" as a split md amount.
- "₹17,270 of ₹33,000", a pace bar, a status `FfBadge`, and `FfInkButton.open(small)` → the Plan tab.
- It always shows the current month.

The actionable item "1 budget reached limit" reads from the board, with the same count and the copy "1 budget is over plan".

## 3. Shared additions (B7a)

Each comes with a widget test (both modes, 2× text, reduced effects, semantics), a place in
`bloom_screenshots_test.dart`, and a row in `03-components.md`.

| Addition | Why | API sketch |
|---|---|---|
| `FfProgressBar` on heroes | The track (`surfaceContainerHighest`) disappears on the rose gradient | `onHero: true` → track and fill from `FfHeroColorScope` (`onHero` at `FfTint.medium` / full); pace tick uses `onHero`; new contrast rule |
| `FfProgressBar` rich semantics | Announce "62% used, ₹2,400 left, ahead of pace by ₹300" instead of "62%" | `semanticValue: String?` overrides the percent |
| `FfProgressBar` over state | Above 100% the fill turns `moneyExpense` (off heroes); always paired with a badge | `tone: FfTone?` instead of the raw `color:` (keep `color` for callers) |
| `FfLineChart` reference series | Spend vs ideal pace | `reference: List<double>?` (dashed, `textTertiary`), `referenceLabel`, `domainLength` so actual stops at today while pace spans the period; the selected bubble reads both values |
| `FfMonthStatus.under` / `.over` | Budget history | under = check + "within plan"; over = up-arrow/! on `moneyExpense` container + "over plan"; words in semantics and an optional `note` |
| `FfHeroFigures` | Loan detail's three hero figures are a local closure; Budget detail needs the same | `FfHeroFigures([FfHeroFigure(label, value)])`, `labelLg` tabular; Loan detail switched to it (no visual change) |
| `FfPeriodBar(units:)` | Plan must not offer Today/Custom | `units: {week, month, year}`; default = today's behaviour |

`BudgetRow` stays a feature widget because it is pure composition of `Ff*` parts. It becomes shared only if goals or
subscriptions need the same row later.

## 4. Domain and data: no schema change vs slice b

### Ships in DS-B7 with **no** Isar/schema/generated-file change

- A `budgetBoardProvider` builds a memoised `BudgetLedger` from `allTransactionsStreamProvider`. It feeds
  `BudgetEngine`/`BudgetBoard` with today's `Budget` fields: one category; `amountLimit` → `limitMinor` once via
  `MoneyMath.toMinor`; no adjustments; rollover off.
- **Groups are derived**, not stored: `BudgetSetupSuggester.groupFor(categoryId)`, where seed categories map to
  Essentials/Lifestyle and custom categories go to Other. The UI shows the derived group; there's no picker yet.
- Bills & EMIs come from `CommittedBills.forPeriod` (reads subscriptions and loans; read-only).
- Safe to spend, pace, forecast, status, run-out date, history, trend and insights.
- **One-tap suggestions change the permanent limit** (existing `amountLimit`), with an Undo toast.
- Suggested setup creates normal budgets in one batch.
- Archive and delete as today.
- **Exact Money link** (in memory only):
  - `TransactionQuery` gains `categoryIds: Set<String>?` (`categoryId` stays as is) and `budgetCounted: bool`, which
    matches only transactions with `BudgetLedger.countedMinor(tx) > 0`, so bill payments and non-consumption rows are
    excluded.
  - Money's summary "Spent" over that query equals the budget's `spentMinor`.
  - A filter chip reads "Budget: Dining".
  - A parity test covers a plain expense, a linked EMI in the same category, a shared category, a future-dated row,
    a period boundary at 23:59/00:00 and an investment fee.
  - `BudgetsScreen` gets an `onShowTransactions` callback from `router.dart`, like Analytics.

### Needs slice b (B7e, persistence, backup-gated, only with your approval)

These are new `BudgetEntity` fields or a new collection, a migration, backup/export/restore (including old backups) and
the startup gate:
- a stored, user-chosen group;
- multi-category budgets (`categoryIds`);
- `limitMinor` stored as an integer;
- rollover (`rolloverMode`, `rolloverSince`);
- `BudgetAdjustment` ("this period only" and "move money between budgets");
- a week-start preference in settings.

The UI for these (group pill, multi-select chips, rollover `FfRow.toggle`, Adjust and Move actions, the
"carried · adjusted" breakdown) is designed now but switched on only in B7e.

### Recommended order

B7a (shared additions) → B7b (Plan tab + board wiring + Money link) → B7c (detail) → B7d (sheet, Home card, delete
dead files, remove shims) → **stop** → B7e as its own approved, backup-gated slice. Each slice ends with analyze, the
full suite, guardrails, the audit, before/after screenshots and docs.

## 5. Tests and copy

- `test/widget/budgets_widget_test.dart` is rewritten. Texts it pins today will change:
  - "TOTAL BUDGET POOL", "DAILY ALLOWANCE", "PROJECTED SPEND", "Budget Settings" → removed;
  - "New Budget Plan" → "New budget"; "PLANNED SPENDING LIMIT" → removed; "Budget Name" → "Name (optional)";
  - "Period Cycle" → none (segmented pill); "Alert Threshold" → "Alert me at";
  - "Save Budget" → "Save budget"; "Add Budget" → "Add budget";
  - "No budgets for this month" / "Create Budget" → "Plan your month" / "Add budget".
- New widget tests:
  - board wiring: safe to spend, status words, urgency order, groups;
  - a closed month (no "days left", no safe-to-spend);
  - empty state with suggestions vs no history;
  - detail watches by id (edit refreshes it);
  - semantics strings for progress;
  - 2× text with no overflow on the Plan, detail and sheet;
  - amounts hidden;
  - the Money parity test (section 4).
- B7a component tests in `test/widget/components/`.
- `test/widget/app_shell_navigation_test.dart` overrides `budgetSummariesProvider`/`overallBudgetSummaryProvider`.
  It switches to the board provider override.
- `test/unit/budget_calculator_test.dart` stays while alerts and the health score still use `BudgetCalculator`
  (see Q5).
- Copy follows `01-direction.md`: sentence case; "Over plan" not "Exceeded"; "On track" / "At risk" / "Over" per
  budget; "Delete the Dining budget? Its transactions stay." All amounts go through `CurrencyFormatter`; there's no ₹
  in strings.

## 6. Risks

- **Two calculators.** Alerts (`alert_engine_service.dart`) and the health score still use the old
  `BudgetCalculator`. Until they move, an alert can disagree with the Plan tab: it counts linked bills, uses the naive
  projection and has no at-risk state.
- **Money files.** The link touches `transaction_list_utils.dart`, `transactions_controller.dart`,
  `active_filter_chips.dart`, `router.dart`. They are free in the status table; I add them to In flight when B7b starts.
- **Shared chart change.** `FfLineChart` is used by Loan detail and the component sheet. The reference series is
  off by default; their goldens are re-captured to prove no change.
- **Investment-fee rows.** A purchase with a fee counts only the fee in a budget, but Money's row shows the full
  amount. The totals still match; the row might confuse. I'll show it with a "fee ₹X counted" subtitle in budget scope.
- **Dates.** Goldens and "today" use `DateTime.now()`: captures change daily, and a screen left open past midnight
  keeps yesterday (known gap in `periods.md`).
- **Performance.** The ledger is built once per transaction-stream event and the board once per period change. I
  haven't measured it on a device with a large ledger.
- **Not verifiable here:** device behaviour and cold start (no device work is needed, since there's no schema or
  bootstrap change), grain (goldens draw it only after the first frame), and real performance.

## 7. Product questions (with my recommendation)

1. **Add button:** FAB "Add budget", as on Home and Money; the header stays clean. *Recommend FAB.*
2. **Plan period:** Plan gets its own `planPeriodProvider` (month by default; week/month/year only) instead of the
   shared Home/Insights `reportPeriodProvider`, which can be "Today" or a custom range that budgets don't support.
   `selectedDashboardMonthProvider` stays for the health screen. The Home card always shows the current month.
   *Recommend own provider.*
3. **Groups before slice b:** derived from category (seed ids → Essentials/Lifestyle, custom → Other), with no picker.
   *Recommend yes.*
4. **One-tap "Raise to ₹6,600"** changes the permanent limit (with Undo) until "this month only" exists in slice b.
   *Recommend yes.*
5. **Alerts and health score:** move them to `BudgetEngine` in a small follow-up slice right after B7d (it changes
   alert behaviour: at-risk alerts, bills excluded), not inside the UI slices. *Recommend follow-up slice.*
6. **Other cadences** (weekly/yearly/custom in a month view): their own "Other periods" section, not added to the
   hero total. *Recommend yes (matches `budgets.md`).*
7. **Closed and future periods:** closed shows final results ("Left at the end" / "Over plan by"); future months
   can't be opened (`FfPeriodBar` already stops at today). *Recommend yes.*
8. **Alert threshold control:** a segmented pill (75 / 80 / 90 % / Off) instead of a slider. *Recommend pill.*
9. **Budget name:** optional, defaults to the category. *Recommend yes.*
10. **Bills & EMIs line** links straight to Subscriptions and Loans; no separate bills screen in B7. *Recommend yes.*
11. **Hide amounts** on the Plan key figure uses the same app-wide setting and button as Home. *Recommend yes.*
12. **Slice b (B7e)** is scheduled after B7d as its own slice, only after you approve it and confirm an encrypted
    backup. *Recommend yes.*
