# Prompt: Insights redesign (DS-B8)

Paste everything below the line into a new Claude Code chat (Opus 5.5).

---

You are the lead product designer and Flutter engineer for **FinanceFlow** (Flutter, Riverpod, Isar; fully local,
privacy-first, no backend). The app uses one design system, **Stillwater**, in its **Bloom** visual language.
Home, Money, Accounts and Loans already shipped in Bloom. Your job is to redesign the **Insights tab** (the
analytics screen, its widgets and the Financial health screen) so it is indistinguishable in quality and style
from those screens, and to restyle the two pre-Bloom charts `FfBarChart` and `FfDonutChart` inside the shared system.

## Read first, in this order (binding)

1. `AGENTS.md` (backup gate, standalone-startup gate, UI section).
2. `docs/design-system/bloom/README.md`, then `01-direction.md`, `02-foundations.md`, `03-components.md`,
   `04-screen-recipes.md`, `05-screen-status.md`, `06-workflow.md`.
3. `docs/design-system/CHANGELOG.md`: In flight, Decisions, Done rows for DS-B1…B6.
4. Look at the golden screenshots: `docs/design-system/screenshots/ds-b3/bloom_components.png`, `ds-b4/home.png`,
   `ds-b5/money.png`, `ds-b6/b6_loans.png`, `ds-b6/b6_loan_detail.png`.
5. Golden code: `lib/features/dashboard/dashboard_screen.dart` (pattern A), `lib/features/loans/loan_detail_screen.dart`
   (pattern D, uses `FfDotMatrix`, `FfMonthGrid`, `FfLineChart`), `lib/shared/widgets/ff_data_viz.dart`.
6. This screen's files: `lib/features/analytics/` (`analytics_screen.dart`, `analytics_controller.dart`,
   `cash_flow_chart_data.dart`, `widgets/analytics_metrics_hero.dart`, `widgets/analytics_cash_flow_card.dart`,
   `widgets/expense_category_breakdown.dart`), `lib/features/financial_health/`, `lib/services/analytics_calculator.dart`,
   `lib/core/period/` (the shared report period), the tests `analytics_widget_test.dart` and
   `financial_health_widget_test.dart`, and the files that define `FfBarChart` / `FfDonutChart`
   (`grep -rn "class FfBarChart\|class FfDonutChart" lib`).

## What exists today (verify, do not trust)

- `AnalyticsScreen` (title "Insights", privacy badge, `FfPeriodBar` for the shared report period). It is a
  "where did my money go" view: metrics hero, cash-flow card, expense category breakdown, payees. Every category and
  payee opens the Money tab filtered to exactly the transactions behind it (`onShowTransactions` + `TransactionQuery`).
  **That drill-down and the totals-match-Money guarantee must survive.**
- Status is **Tokens**: Geist, ink buttons and squircle cards already apply, but the layout is still the old flat
  stack. `FfBarChart` and `FfDonutChart` are pre-Bloom.
- Financial health (`financial_health_screen.dart`, 300 lines) is Tokens status; it is a good fit for `FfRangeBand`.

## The task

Redesign Insights as **pattern A** (hero tab on `FfAurora`) and Financial health as **pattern D** (detail).
Keep behaviour and data unless I approve a change. Suggested target, which you should challenge in your plan:

**Insights tab**
1. Aurora canvas, large header "Insights" with the on-device privacy chip, `FfPeriodBar` (shared report period, unchanged).
2. **Hero**: an `FfHeroCard` with the period's net as a split `FfAmountText` (`moneyHero`), income and expense as
   two `FfStatTile`s or pills, and the savings rate as an `FfProgressRing`. Pick the tone from `02-foundations.md`
   and justify it (dusk is the default candidate). Direction and status must never be colour only (sign, icon or label too).
3. **Cash flow**: replace the old bar block with `FfLineChart` (income vs expense, bubble on the selected point,
   nothing fabricated when the period has a single point) or a restyled `FfBarChart`; pick one and explain.
4. **Where it went**: category breakdown as `FfDotMatrix` or the restyled `FfDonutChart`, plus ranked
   `FfCategoryTile` rows with inline amounts and share of spend; each row still drills into Money.
5. **Payees and recurring** (whatever exists today): `FfCard` rows, top-N with "See all".
6. **One insight card**, not several: the single most useful observation for the period, with a CTA into Money.
7. States: loading (`FfSkeletonLoader`), no data in period (`FfEmptyState` that says what to do), single
   transaction, very large and negative net, amounts hidden, 2× text, reduced effects, light and dark.

**Financial health (detail)**
Hero with the score or status as a ring plus a text label (never colour only), then each factor as a row with an
`FfRangeBand` or ring, a plain-language "what this means / what to try", and links into the relevant tab.

**Shared charts**
Restyle `FfBarChart` and `FfDonutChart` to Bloom (rounded bars, token colours, tabular numerals, a tooltip bubble like
`FfLineChart`, accessible semantics with a text summary). Update `03-components.md` and the component sheet capture
test. Delete an old chart only when `grep` shows zero other users.

## Rules

- Follow `06-workflow.md` exactly: In flight row (files above plus the chart files), baseline, plan, build, verify
  with before/after screenshots that you actually open and look at, record in `05-screen-status.md` and
  `CHANGELOG.md`, commit only your paths.
- Only shared `Ff*` components and tokens; missing pieces go into the shared system (component + test +
  screenshot + `03-components.md`), never one-off code. No raw colours, sizes, radii or `TextStyle(`.
- Amounts via `FfAmountText` only (split for hero/lg, inline for rows). Never log financial data.
- Keep keys, tooltips and semantics that tests rely on, or update the tests in the same commit with the reason.
- Format only the files you touched. Never `dart format lib`.
- No Isar schema or provider-bootstrap changes in this slice. If you think one is needed, stop and ask me: that
  triggers the backup gate.
- Another chat may be redesigning **More** (Settings, Security, Backup) in parallel. Do not touch those files, and
  when you edit `05-screen-status.md` or `CHANGELOG.md` change only your own rows, re-reading the file right before
  you edit it.
- Windows 11, PowerShell and Git Bash.

## Slices (one commit each, update status and changelog in each)

- **B8a** Restyled `FfBarChart` / `FfDonutChart` (+ tests, component sheet).
- **B8b** Insights tab: hero, cash flow, where it went, payees, insight card, states.
- **B8c** Financial health detail.

## Start

Do steps 0–1 of `06-workflow.md` only: read, baseline (`flutter analyze`, the analytics and financial-health tests,
`dart run tool/design_system_audit.dart --shared`), then return a short plan: current map of the screen (sections,
data, actions, tests that pin texts or keys) → target layout block by block with the component for each → missing
shared pieces → test and copy changes → risks → questions with your recommendation. Wait for my approval before
building.
