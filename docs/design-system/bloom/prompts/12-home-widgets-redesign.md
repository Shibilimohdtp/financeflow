# Prompt: Home widgets redesign, cash flow, budgets, goals, actionable (DS-B12)

Paste everything below the line into a new Claude Code chat (Opus 5.5).

---

You are the lead product designer and Flutter engineer for **FinanceFlow** (Flutter, Riverpod, Isar; fully local,
privacy-first, no backend). The app uses one design system, **Stillwater**, in its **Bloom** visual language.

The Home dashboard is half finished. These parts are fully Bloom and are the quality bar: the **total balance hero**,
the **accounts carousel**, the **loans and EMI hero**, and the **recent transactions** list. The sections between them
are not: **Cash flow**, **Budgets & Spending**, **Savings goals** and the **Actionable / upcoming** strip only got
"Bloom shell" treatment (a borderless squircle card and Geist), but their insides are the old layout. The owner's
verdict: they look like a disconnected design system sitting inside Bloom. Your job is to redesign those widgets so
Home reads as one composed screen, with real layout, hierarchy and data-visualisation improvements and not a recolour.

## Read first, in this order (binding)

1. `AGENTS.md` (backup gate, standalone-startup gate, UI section).
2. `docs/design-system/bloom/README.md`, then `01-direction.md`, `02-foundations.md`, `03-components.md`,
   `04-screen-recipes.md` (pattern A and C), `05-screen-status.md`, `06-workflow.md`.
3. `docs/design-system/CHANGELOG.md`: In flight, Decisions, Done rows for DS-B1…B6.
4. Look at the golden screenshots and read what makes them work: `docs/design-system/screenshots/ds-b4/home.png`
   (the quality bar), `ds-b3/bloom_components.png`, `ds-b6/b6_loans.png`, `ds-b6/b6_loan_detail.png`.
5. Golden code: `lib/features/dashboard/widgets/total_balance_hero.dart`, `home_accounts_carousel.dart`,
   `home_loans_overview.dart`, `home_recent_transactions.dart`, and the shared pieces in
   `lib/shared/widgets/ff_data_viz.dart` (`FfProgressRing`, `FfDotMatrix`, `FfRangeBand`, `FfLineChart`, `FfMonthGrid`),
   `ff_surfaces.dart` (`FfHeroCard`, `FfGlass`), `ff_stat_tile.dart`, `ff_round_buttons.dart`, `ff_chip.dart`.
6. The widgets to redesign, all in `lib/features/dashboard/widgets/` and composed in
   `lib/features/dashboard/dashboard_screen.dart` (486 lines; read all of it, it decides the order and rhythm):
   - `cash_flow_card.dart` (382 lines; still imports the pre-Bloom `FfBarChart`)
   - `budget_overview_card.dart` (246 lines)
   - `savings_goals_overview_card.dart` (150 lines)
   - `actionable_items_section.dart` (227 lines)
   - `month_selector_header.dart` is **not** in scope (Budgets uses it).
   - data and providers: `dashboard_controller.dart`, `lib/services/balance_calculator.dart`,
     `lib/features/budgets/` providers for `overallBudgetSummaryProvider` and `budgetSummariesProvider`, the savings
     goals summary providers, and the dashboard tests (`grep -rln "CashFlowCard\|BudgetOverviewCard\|DashboardScreen\|SavingsGoalsOverviewCard\|ActionableItems" test`).

## Ownership checks before anything else

- `05-screen-status.md` lists the Home **budget overview card** as owned by the **Budgets chat** (DS-B7 includes
  a Home budget card). Check `CHANGELOG.md` In flight, `git log` and `git status`. If DS-B7 has landed, build on its
  data and decisions. If it is in flight, **stop and ask me** whether to do the budget card here or leave it. If it has
  not started, you may do the budget card here using only data that exists today, and record in the changelog that
  DS-B7 must reuse your widget instead of building a second one.
- `FfBarChart` and `FfDonutChart` are restyled by the Insights slice (DS-B8a). **Do not edit those two files here.**
  Use `FfLineChart` or another existing Bloom viz for cash flow. If you truly need a missing viz, add it as a new
  shared component in `ff_data_viz.dart` and tell me. If DS-B8a has already landed, you may use the restyled bars.
- Another chat may be redesigning the **Home header** (DS-B13). Do not touch `home_header.dart`.

## What exists today (verify, do not trust)

- `CashFlowCard`: title "Cash Flow", period label, a bar chart (`FfBarChart` of `BarChartItem`s), income and expense
  numbers, net savings, a trend comparison metric, a privacy-blur toggle and an "open Insights" CTA. Dense, a
  card-in-card look, small type, a header that repeats what `FfPeriodBar` above it already says.
- `BudgetOverviewCard`: a section header "Budgets & Spending" with a "Manage" text button, a card with totals, a
  progress bar (`ff_progress.dart`), over-budget badge, and a list of category rows. Uses `FfSectionHeader` +
  `TextButton`, the old pattern. No hero, no ring, no tone.
- `SavingsGoalsOverviewCard`: totals and a progress bar.
- `ActionableItemsSection`: pending review, upcoming loan EMIs, subscription renewals and alert cues as a stack.
- `DashboardScreen` composes: balance hero → accounts carousel → actionable → `FfPeriodBar` → cash flow → budgets →
  loans hero → goals → recent transactions. The rhythm between a hero, a plain card, a hero and a plain card is
  uneven: some sections have a title above the card, some inside it, some none.

## The task: design principles for this redesign

Home must read as **one hierarchy**, not a pile of cards. Apply these and argue with them in your plan:

1. **Few heroes, many calm cards.** Home already has three gradient heroes (balance, accounts, loans). Do not add
   more gradient blocks by default. Cash flow, budgets and goals are mostly **calm `FfCard`s** whose character comes
   from a single strong figure, a clean viz and a clear verb, with at most one of them (budget) earning a rose
   `FfHeroCard` if you can justify it against the "heroes are rare" rule in `01-direction.md`. Decide and explain.
2. **One section pattern.** Pick a single, repeatable section structure for every Home block (title row with an
   optional count and a quiet "See all" pill-link, then the card), use it for all of them including the ones that
   are already Bloom, and say which existing file gets a one-line change to match.
3. **Cash flow becomes a picture, not a table.** One big figure (net for the period, split `moneyLg`), income and
   expense as two clearly signed stat tiles (icon plus sign plus label, never colour only), and an
   `FfLineChart` (income vs expense over the period, bubble on the selected point) or the restyled bars if available.
   Remove the repeated period title, keep the trend delta as a small chip with direction icon and words. The privacy
   toggle already exists on the hero, so remove the duplicate from this card unless you can justify it. Tapping the card
   opens Insights. Nothing is invented when there is one data point.
4. **Budgets show pace, not just totals.** The strongest view: "left to spend" as the key figure, a ring or a
   `FfRangeBand`/segmented bar with a **pace marker** (where you should be today vs where you are), the top 2-3
   budgets that need attention as compact rows (category tile, spent/limit inline, status icon plus text), and the
   over-budget count as a badge. No dense category list. Empty state (no budgets) must still lead into setup.
5. **Goals become a quiet progress story.** Total saved vs target as a ring or dot matrix, nearest goal with its
   percentage and an estimate if the data exists, a tide-toned icon tile. Not a bar plus numbers.
6. **Actionable stays a strip, but a better one.** Horizontally scrollable `FfChip`-style cards (count + one verb,
   e.g. "3 to review", "EMI due in 2 days", "Netflix renews tomorrow") or a single compact card with rows, whichever is
   faster to scan; each item has icon, words and a tap target of at least 48 dp. It disappears when empty.
7. **Order and rhythm.** Review the order of the whole screen once the new blocks exist and propose the best one
   (for example: balance → accounts → actionable → period + cash flow → budgets → loans → goals → recent). Spacing
   between sections is one token, headings align to `FfSpace.pageMargin`, and scroll length is considered: Home must
   not feel like an endless list, so propose what to collapse or show conditionally.
8. **Numbers and states.** Amounts via `FfAmountText` only (split for lg, inline for rows). Handle: loading skeletons
   that match the final shapes, error cards with a retry, empty states, a negative net, very large numbers, amounts
   hidden, 2× text, reduced effects, light and dark. Loading must not flash a different layout.

## Hard constraints

- Behaviour and data are unchanged unless I approve it: same providers, same navigation callbacks
  (`onOpenAnalytics`, `onOpenBudgets`, `onOpenSavingsGoals`, …), same tap targets. No Isar schema, generated-file or
  provider-bootstrap changes (backup gate; stop and ask me). Never log financial data.
- Only shared `Ff*` components and tokens; missing viz or tiles become shared components (component + test +
  screenshot + `03-components.md`), never one-off code. No raw colours, sizes, radii or `TextStyle(`.
- Accessibility per `01-direction.md`: 48 dp targets, contrast ratchet green, no colour-only status, semantic labels
  that summarise each card for a screen reader (keep or improve the existing `Semantics`).
- Keep keys, tooltips and semantics that tests rely on, or update the tests in the same commit and say why.
- Performance: Home is the first screen. No new blur or grain, no per-frame animation, charts cached in providers or
  built from already-loaded data. Measure nothing you cannot verify, and say what you could not.
- Format only files you touched. Never `dart format lib`. Commit only your paths. Windows 11, PowerShell and Git Bash.

## Slices (one commit each, each updating `05-screen-status.md` and `CHANGELOG.md`)

- **B12a** Section pattern + page rhythm (shared section header widget if needed, order, spacing), no content change.
- **B12b** Cash flow card.
- **B12c** Budgets card (subject to the ownership check).
- **B12d** Savings goals card and actionable strip.
- **B12e** States and polish: skeletons that match, errors, empties, 2× text, hidden amounts, final screenshots.

## Verification

- Before / after full-page screenshots of Home with `tool/screenshots/compare.py`, light and dark, and each new card
  in these states: normal, empty, loading, error, negative net, over budget, hidden amounts, 2× text. **Open the PNGs
  and look at them**; judge the page as a whole next to `ds-b4/home.png`, not card by card. Fix what you see.
- Widget tests for each card's states and tap callbacks; the dashboard test still passes; full suite green; analyze
  clean; `dart run tool/design_system_audit.dart --shared` numbers not up.
- Say plainly what you could not verify (device, scroll performance, grain).

## Start

Do steps 0–1 of `06-workflow.md` only. Read, run the ownership checks, take the baseline (`flutter analyze`,
dashboard tests, the audit, current screenshots), then return:

1. A map of Home today: block order, the pattern each block uses, what each card shows, callbacks, tests that pin text.
2. Your target for the whole screen (block order and the section pattern) and for each redesigned card, with the
   shared component per block and a description of its empty, loading, error and hidden-amount states.
3. Missing shared pieces, test and copy changes, risks, and questions with your recommendations, in particular the
   budget-card ownership answer and whether any of these cards should be a hero.

Wait for my approval before building anything.
