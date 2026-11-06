# Prompt: DS-B7 · Budgets (Plan tab) in Stillwater Bloom

Paste everything below the line into a new Claude Code chat on Opus 5.5.

---

You are the lead product designer and Flutter engineer for **FinanceFlow**, a fully local, privacy-first personal
finance app (Flutter 3.29, Riverpod, Isar; no backend, no telemetry). The app has one design system,
**Stillwater**, in its **Bloom** visual language, already shipped in slices DS-B1…B6: tokens, Geist type, shared
components, then Home, Money, Accounts and Loans. Your job is slice **DS-B7: redesign the whole Budgets experience
(the "Plan" tab)** so it looks and feels like those screens, and make it the screen people open daily to answer:
**"Am I on track, what can I safely spend today, and what should I change?"**

## 1. Read first, in this order (binding; do not skip)

1. `AGENTS.md`: the backup gate, the standalone-startup gate, and the UI section.
2. `docs/design-system/bloom/README.md` and every file it lists, in order:
   - `01-direction.md`: principles, look-and-feel checklist, copy voice
   - `02-foundations.md`: every token; hero tones; type and numerals
   - `03-components.md`: every shared widget with its API
   - `04-screen-recipes.md`: patterns A (hero tab), D (detail) and E (form/sheet) are yours
   - `05-screen-status.md`: the Budgets rows and the Home budget card row
   - `06-workflow.md`: the process and the definition of done
   These files are the single source of truth for the design. If what you want to do contradicts them, either
   follow them or propose a change to them; never silently diverge.
3. `docs/design-system/CHANGELOG.md`: In flight, Decisions, and the Done rows for DS-B1…B6.
4. **Look at** (open the PNGs): `docs/design-system/screenshots/ds-b3/bloom_components.png`, `ds-b4/home.png`,
   `ds-b5/money.png`, `ds-b6/b6_loans.png`, `ds-b6/b6_loan_detail.png`. Your screens must sit next to these
   without looking like a different app.
5. Golden code: `lib/features/dashboard/dashboard_screen.dart` (pattern A),
   `lib/features/loans/loan_detail_screen.dart` (pattern D), `lib/features/transactions/transactions_screen.dart`
   (rows and the DecoratedSliver card list), `lib/shared/widgets/ff_surfaces.dart`, `ff_data_viz.dart`,
   `ff_navigation.dart`, `ff_amount_text.dart`.
6. Budgets product and domain: `docs/features/budgets.md` (the model, the semantics and the owner decisions: D1
   bills & EMIs are a separate line, D3 opt-in rollover, no pro-rating mid-period, one-offs, pace, forecast,
   status), `docs/opus-budgets-redesign-prompt.md` (the product goals; still valid),
   `docs/architecture/periods.md` and `docs/architecture/transaction-semantics.md`.
7. Code you will change or consume:
   - UI: `lib/features/budgets/` (`budgets_screen.dart`, `budget_detail_screen.dart`, `add_edit_budget_sheet.dart`,
     `budgets_controller.dart`, `budgets_placeholder_screen.dart` (not referenced anywhere; delete it),
     `widgets/budget_card.dart`, `budget_insights_card.dart`, `budget_visual_summary_card.dart`)
   - Home: `lib/features/dashboard/widgets/budget_overview_card.dart`, `month_selector_header.dart` (only Budgets
     uses it), and the budget items in `actionable_items_section.dart`
   - Domain already built and tested (slice a, commit b66292a), **not yet wired to the UI**: `lib/services/budgets/`
     (`budget_ledger.dart`, `budget_engine.dart`, `budget_board.dart`, `committed_bills.dart`,
     `budget_insights.dart`, `budget_setup_suggester.dart`), `lib/models/budget.dart`,
     `lib/core/money/money_math.dart`, tests in `test/unit/budgets/`. The screens still use the old
     `BudgetCalculator`.
   - Other consumers of budget data: alerts, financial health, analytics, backup/export/restore, onboarding,
     settings.
   - Tests: `test/widget/budgets_widget_test.dart`, `test/unit/budget_calculator_test.dart`,
     `test/unit/budgets/`.

## 2. Ownership: check this first

The CHANGELOG's In flight table still has a **"Budgets redesign chat"** row that reserves the budgets files. The
owner is now assigning the Budgets UI to **you**. Before editing anything:
- Run `git status`. If there are uncommitted changes under `lib/features/budgets/`, `lib/services/budgets/`,
  `lib/models/budget.dart`, `lib/core/money/money_math.dart` or `test/unit/budgets/`, **stop and ask me**. Another
  chat may still be working there.
- If the tree is clean, replace that In flight row with yours (DS-B7, your exact files) and mark the Budgets rows in
  `bloom/05-screen-status.md` as owned by you.

## 3. What to build (the design target)

Use only shared `Ff*` components and tokens. Anything missing becomes a **shared** component or token (with a
widget test, a place in `tool/screenshots/bloom_screenshots_test.dart`, and a row in `03-components.md`), never
one-off code in the feature.

### Plan tab (`budgets_screen.dart`): recipe A, on `FfAurora`

- **Header** drawn on the aurora, like Home: title "Plan", `FfPrivacyBadge`, and an `FfCircleButton` to add a
  budget (or put add in the FAB, as Home and Money do; pick one and say which).
- **Key figure:** "Safe to spend today" (from `BudgetBoard`) as a split hero `FfAmountText`, with a quiet line
  underneath: "₹18,400 left of ₹45,000 · 12 days to go".
- **Hero:** one `FfHeroCard`. Recommended tone is `rose` (02-foundations assigns rose to budgets and the plan).
  - Leading: `FfProgressRing` showing the share of the plan spent.
  - Title: the month; subtitle: the plan status ("On track" / "Needs attention" / "Over plan") with words, plus
    an `FfBadge` with an icon. Never use colour alone.
  - Spent vs plan as split figures.
  - A **pace** visual that shows spend against expected-by-today. Use the existing `FfProgressBar` with `pace:`,
    or `FfRangeBand`; check it reads on a hero, and extend it if not.
- **Bills & EMIs** (owner decision D1) as its own line or compact card: committed vs settled, from
  `committed_bills.dart`. Link to Subscriptions and Loans.
- `FfPeriodBar` for period navigation (closed periods show final results). Retire `month_selector_header.dart` if
  nothing else needs it.
- **Budgets grouped** by Essentials / Lifestyle / Other, sorted by urgency (over → at risk → on track).
  - Each budget is a compact card or row: `FfCategoryTile` (first category), name, "₹4,200 of ₹6,000" (split md or
    inline), and a progress bar with the pace marker.
  - Add an `FfBadge` for over / at risk, an `FfCornerBadge` warning on the icon when over, and an ink open button
    or a tap target to the detail.
- **One insight card**, not three. Merge `budget_card`, `budget_insights_card` and `budget_visual_summary_card` into
  a purposeful design. It holds the single most useful suggestion from `budget_insights.dart`, with a one-tap action
  (for example "Raise Dining to ₹6,500").
- **Empty state:** `FfEmptyState` leading into a **suggested setup** from `budget_setup_suggester.dart` (median of
  the last 3 months, rounded with `MoneyMath.niceCeilMinor`). Show 50/30/20 as a guide only.
- Loading skeletons, error state, amounts hidden, 2× text, dark mode, reduced effects.

### Budget detail (`budget_detail_screen.dart`): recipe D

- `FfHeroCard` (same tone as the plan):
  - Leading: ring = spent / limit.
  - Title: "Left to spend"; subtitle: status.
  - Amount: hero split.
  - Breakdown line: spent · limit · carried (rollover) · adjustments.
  - Three small figures: daily allowance, forecast, days left.
- **Trend card:** an `FfLineChart` of cumulative spend this period **against the ideal pace line**.
  `FfLineChart` has one series today, so add an optional reference/pace series to the shared component (test it,
  document it) instead of a local chart.
- **History card:** the last 6 periods as `FfMonthGrid`. It needs "under" and "over" meanings. Either extend
  `FfMonthStatus` with clear labels and semantics, or map them explicitly; decide, document it in
  `03-components.md`, and never rely on colour alone.
- **The period's transactions** in the Money row style (pattern B rows inside one compact card). The total must
  match the hero to the cent. A "See all in Money" action opens the Money tab with the exact filter. Check that
  `TransactionQuery` can express the budget's categories and period; it supports one `categoryId` today, so
  propose the smallest extension if a budget covers several categories.
- **Actions:** edit, adjust this period only, move money between budgets (if the data model allows without a schema
  change), archive, delete (`FfDialog.confirm`).

### Add / edit budget (`add_edit_budget_sheet.dart`): recipe E

- `showFfSheet` + `FfSheetHeader` / `FfSheetFooter`.
- The `FfAmountField` limit comes first, with a live preview: "₹6,500 a month · about ₹217 a day".
- Category choice as `FfChip`s (multi-select if the model supports it), cadence as `FfSegmentedPill`, group, alert
  threshold, and a rollover `FfRow.toggle` (if supported).
- Use `pickFfDate` for custom ranges; no raw pickers or raw `showModalBottomSheet`. Use smart defaults from the
  suggester.
- Copy must use the user's currency via `CurrencyFormatter` (old validation text says "rupees").

### Home budget card (`budget_overview_card.dart`)

Make it a compact Bloom summary that matches the new Plan hero: safe to spend today, spent of plan, status badge,
and a tap to the Plan tab. Keep the dashboard tests' texts or update them with a reason.

## 4. Domain and data: decide with me

The new engine works in integer minor units and supports multi-category budgets, groups, adjustments and opt-in
rollover. Some of that needs **persistence changes** (slice b of the budgets plan: Isar schema, generated files,
migration, backup/export/restore compatibility). That is backup-gated and startup-gated work.

In your plan:
- Say exactly which parts of the design you can ship **without any schema change**: reading existing budgets
  through `BudgetEngine`/`BudgetBoard` with today's fields (single category, `double` limit converted once via
  `MoneyMath.toMinor`, no groups (put everything under "Other", or derive groups from categories), no rollover or
  adjustments).
- Say exactly which parts need slice b.
- Recommend an order. My default expectation: **ship the Bloom UI on the existing data first (DS-B7)**, then slice
  b as its own approved, backup-gated slice that switches on groups, multi-category, rollover and adjustments.
- Never change an Isar schema, generated file or migration without my explicit approval and my confirmation that I
  made an encrypted backup.
- Single source of truth: budget spending uses the same period and transaction-semantics rules as Home, Insights
  and Money. Tapping a budget figure opens Money filtered to exactly those transactions, and the totals match to
  the cent. Add a test that proves it.

## 5. Rules

- Follow `bloom/06-workflow.md` exactly:
  - In flight row and baseline (`flutter analyze`, budgets tests, `dart run tool/design_system_audit.dart --shared`).
  - Plan, then build, then verify.
  - Before/after screenshots with `tool/screenshots/compare.py`, using a new `tool/screenshots/plan_screenshots_test.dart`
    with realistic sample data (three groups, one over, one at risk, bills, a closed period). **Open the PNGs and
    fix what you see.**
  - Update `bloom/05-screen-status.md` and `CHANGELOG.md` in the same commit.
  - Commit only your own paths with `git commit -- <paths>`.
- Format only the files you touched (`dart format <files>`). Never `dart format lib`.
- No raw colours, sizes, radii, durations or `TextStyle(`s. The leakage numbers must go **down** (budgets currently
  hold most of the remaining leaks and the legacy shims `StillwaterTokens`, `StillwaterColors`, `FfListRow`,
  `FfSnackbar`, `FfConfirmDialog`). After your slice, no budgets file should use them, which unblocks DS-9.
- Accessibility:
  - Progress announces "62% used, ₹2,400 left, ahead of pace by ₹300".
  - Status is never colour alone.
  - 48 dp targets, RTL-safe insets, and split amounts that shrink instead of overflowing at 2× text.
- Money correctness: integer minor units in calculations (`MoneyMath`), `CurrencyFormatter` for display, no
  hard-coded ₹ in copy.
- Never log financial data.
- Backup gate before any device install or data change. Never `adb uninstall`, `adb shell pm clear` or
  `flutter install`; use `adb install -r` only.
- Windows 11, PowerShell and Git Bash.
- Say plainly what you could not verify (device, performance, grain in goldens).

## 6. Slices (propose, then build after approval)

| Slice | Content |
|---|---|
| **B7a** | Shared additions only: a pace-capable bar on heroes if needed, the `FfLineChart` reference series, `FfMonthGrid` under/over, and anything else the design needs. Each comes with widget tests and screenshots. |
| **B7b** | Plan tab: controller wiring to `BudgetBoard` on existing data, hero, bills line, groups, insight, empty state and suggested setup. |
| **B7c** | Budget detail: hero, trend, history, transactions, actions, the exact-filter link to Money. |
| **B7d** | Add/edit sheet; the Home budget card; delete the placeholder; retire `month_selector_header` if unused; remove the legacy shims from budgets. |
| **B7e** *(only if I approve, and backup-gated)* | Persistence slice b: groups, multi-category, rollover, adjustments, with migration and backup compatibility. |

Each slice ends with analyze, the full test suite, guardrails, the leakage audit, before/after screenshots, and the
docs updated.

## 7. Start now

Do **steps 0–1 of `bloom/06-workflow.md` only**: read everything above, check ownership, and record the baseline.
Then return:
- a short audit of the current Budgets UI against Bloom (with screenshots of the current state from a capture test);
- the target layout of each screen, block by block, with the component for each;
- the list of shared additions (B7a);
- the no-schema-change vs slice b split;
- the test and copy changes;
- risks;
- product questions, each with your recommendation.

**Wait for my approval before writing code.**
