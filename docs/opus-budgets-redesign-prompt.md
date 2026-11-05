# Prompt: Redesign and upgrade the Budgets feature (paste into a new Claude Code chat on Opus)

---

You are the lead product designer and Flutter engineer for **FinanceFlow**, a fully local, privacy-first personal finance app (Flutter, Riverpod, Isar; no backend, no telemetry). Your task is to **redesign the entire Budgets experience and make the feature genuinely powerful**, so that using it measurably improves someone's financial planning and habits. The target is a store-quality feature comparable to or better than the budgeting in YNAB, Monarch, Copilot and Goodbudget, while staying simple enough that a first-time user sets up their first budget in under a minute.

Read `AGENTS.md` and `docs/` first (`docs/architecture/periods.md`, `docs/architecture/transaction-semantics.md`, `docs/features/FinanceFlow_PRD.md`, `docs/features/FinanceFlow_Design_System.md`). They contain binding rules.

## What exists today (verified from the code)

Files:
- UI: `lib/features/budgets/` (`budgets_screen.dart` ~430 lines, `budget_detail_screen.dart` ~500, `add_edit_budget_sheet.dart` ~560, `budgets_placeholder_screen.dart`, `widgets/budget_card.dart`, `budget_insights_card.dart`, `budget_visual_summary_card.dart`), controller `budgets_controller.dart`.
- Domain: `lib/models/budget.dart`, `lib/services/budget_calculator.dart` (pure static class), `lib/repositories/budget_repository.dart`, Isar schema `lib/database/schemas/budget_entity.dart`.
- Period math lives in `lib/core/period/period.dart` (the calculator already uses `Period.containing`). Spending is derived from `Transaction.consumptionExpenseAmount`.
- Tests: `test/unit/budget_calculator_test.dart`, `test/widget/budgets_widget_test.dart`.
- Budget data is also consumed by: dashboard (`dashboard/widgets/budget_overview_card.dart`, `actionable_items_section.dart`), alerts (`alerts_controller`, `alert_engine_service`), financial health, analytics insights, backup/restore/export, onboarding, settings. **Any model or schema change must be propagated to all of these.**

Current model (limitations to address):
- A `Budget` is **one category + one limit + one period** (weekly / monthly / yearly / custom) with a start date, optional end date, an alert threshold (default 80%), and an archive flag. Amounts are `double`.
- There is **no overall/monthly total budget**, no grouping of categories, no link to income, no rollover of unspent or overspent money, no per-period history, no subcategories, and no way to see "what can I still safely spend today".
- Summary metrics per budget: spent, remaining, % used, over-budget amount, days remaining, daily allowance, projected end-of-period spend, approaching-threshold flag, exceeded flag.
- Weekly/monthly/yearly budgets always resolve to the calendar period containing the reference date (so past periods cannot be browsed), while custom budgets use explicit dates.
- Three overlapping summary widgets and an insights card suggest the screen is cluttered; I find the current screen not good enough in layout, hierarchy and usefulness.

## Goal

Make Budgets the screen people open daily to answer: **"Am I on track, what can I spend today, and what should I change?"** Redesign the UI and upgrade the logic together. Deliver a coherent, minimal, elegant experience, not a pile of cards.

## Feature ideas to evaluate (pick, refine and prioritize; push back if you disagree)

Think deeply about which of these produce real behavioral and financial benefit, then propose a scoped plan. Don't build everything just because it is listed.

1. **Overall monthly plan on top**: a hero showing total planned vs spent vs left, expected income (optional), a "safe to spend today" figure, a pace indicator (spent % vs elapsed-time %), and a clear status (on track / watch / over). The single most important number should be unmistakable.
2. **Period navigation**: browse previous and next weeks/months with the same math (a time-travel selector shared with the rest of the app's period system), including closed periods that show final results.
3. **Budget setup that is nearly effortless**: a guided first-run that suggests budgets from the last 1-3 months of actual spending (average, median, rounded sensibly), offers templates (e.g. 50/30/20, essentials-first), lets the user adjust with sliders or quick chips, and shows the total against income.
4. **Rollover (opt-in per budget)**: carry unspent or overspent amounts into the next period, with clear visualization of the carried amount.
5. **Budget groups** (e.g. Needs / Wants / Savings & goals / Debts) with group totals, and optional multi-category budgets so one budget can cover several categories.
6. **Fixed vs flexible spending**: treat subscriptions, EMIs and recurring bills as committed ("already spoken for") so the flexible remainder and the daily allowance are realistic. The app already has subscriptions, loans/EMIs and savings goals; integrate with them rather than duplicating.
7. **Forecasting**: end-of-period projection that is robust (account for upcoming known bills, front-loaded rent, day-of-week patterns; avoid the naive "daily pace x days" trap that overstates early in the period).
8. **Smart, quiet alerts**: threshold, projected-overrun and "a bill is coming" nudges through the existing alert/notification system, with sensible de-duplication and no spam.
9. **Insights that lead to action**: for each budget, trend over the last N periods, how often it was exceeded, average overshoot, top merchants driving it, and a concrete suggestion (e.g. "Raise Dining to 6,500 or cut 3 visits"), with a one-tap adjust.
10. **Fast corrective actions**: move money between budgets, raise/lower a limit for this period only versus permanently, mark a transaction as excluded from budgets, and jump from any budget directly to its filtered transactions (this must match the budget's number exactly).
11. **Savings and goals tie-in**: show planned savings as a first-class line, and link to savings goals.
12. **Celebration and streaks (restrained)**: positive reinforcement for staying under budget; avoid gimmicks and guilt.

## Non-negotiable engineering requirements

- **Money correctness**: decide, with a recommendation, whether to move budget amounts to integer minor units or a fixed-point type now (the model currently uses `double`). If you change representation, do it consistently with the rest of the app, with a migration plan and tests. Use `core/money/money_math.dart` where it applies.
- **Single source of truth**: budget spending must use the same period and transaction-semantics definitions as the dashboard, analytics and the transactions list (see `docs/architecture/`). Tapping any budget number must open the transactions list pre-filtered to exactly those transactions, and the totals must match to the cent.
- **Edge cases with tests**: period boundaries, week-start preference, month-end/leap-year, timezone/DST, custom ranges, transfers, refunds, split or reclassified transactions, archived or deleted categories, deleting a category that has a budget, duplicate budgets for one category, zero spend, overspend, future-dated transactions, rollover chains, and budgets created mid-period (pro-rate or not; decide and document).
- **Performance**: computing summaries for all budgets must not scan all transactions repeatedly per widget build; use indexed or date-bounded queries and memoized providers.
- **Persistence safety**: any Isar schema or generated-file change requires a migration that preserves existing budgets, updated backup/export/restore payloads (including restoring old backups), and updated tests. Handle old backup versions.

## Hard repo rules (follow `AGENTS.md` exactly)

- **Backup gate**: before any step that could affect existing user data or a real-device install (schema/generated-file changes validated on a device, migrations, `adb install`, reset, restore), STOP and ask me to personally create and verify an encrypted FinanceFlow backup and keep the file and passphrase. Wait for my explicit confirmation. Never create one for me. Never run `adb uninstall`, `adb shell pm clear` or `flutter install`; use `adb install -r` only.
- **Standalone startup gate**: keep `main()` synchronous through `runApp`; no awaited DB/plugin work before the first frame; failures show recoverable in-app UI. If you touch Isar schemas, bootstrap, notifications or build config: run `flutter analyze`, the affected tests (including `test/widget_test.dart` and `test/integration/isar_startup_test.dart`), `flutter build apk --debug` and `--release` (Windows retry: `JAVA_TOOL_OPTIONS=-Djdk.net.unixdomain.tmpdir=.`), then `./tool/verify_debug_startup.ps1 -Serial <device>` with no `flutter run` attached.
- Never log financial data. Fixed privacy-safe milestones only.
- Environment: Windows 11, PowerShell.

## Design requirements

- Use the app's existing token/theme system (`lib/theme/`, `lib/shared/widgets/ff_*`). The app theme is in flux (the "Stillwater" / "Lichen Ledger" naming is inconsistent), so build budget UI on shared components and tokens only. No hard-coded colors, sizes or text styles. If the token set lacks something you need (e.g. status colors for safe/watch/over, a progress-bar component), add it to the shared system, not locally.
- Light and dark mode, large font scaling, 48dp touch targets, semantic labels (progress bars must announce "62% used, 2,400 left"), color is never the only status signal, RTL-safe layouts.
- Clear hierarchy: one hero number, then the budgets list sorted by urgency (over -> at risk -> on track), with group sections. Progress visuals should show both **spend** and **expected pace for today** so users see whether they are ahead or behind, not just a percentage.
- Meaningful empty state (guides to the suggested-budgets setup), skeleton loading, error states, and delightful but restrained motion (animated progress, no looping animations).
- Budget detail screen: period chart (daily cumulative spend vs ideal line), transactions list for the period, history across past periods, rollover info, actions (edit, adjust this period, archive, delete). Replace long forms with a short add/edit flow with smart defaults and live preview.
- Split the large widgets into small, testable ones. Remove dead code (`budgets_placeholder_screen.dart` looks unused; verify) and merge the three overlapping summary widgets into a purposeful design.
- Keep all user-facing copy plain, kind and specific (no jargon, no shaming). Use proper currency formatting from `core/formatting` and respect the user's currency setting rather than hard-coded rupee text (the validation messages currently say "rupees").

## Process

1. **Do not code first.** Enter plan mode. Read the files above plus the transactions filter code, the period system, dashboard budget card and alert engine. Run `flutter analyze` and the budget tests for a baseline.
2. Deliver a short written **audit** (UX problems, logic flaws, data-model gaps) and a **proposal**: the chosen feature set (what is in v1 vs later, with reasoning), the data model and migration plan, the screen map, and 2-3 low-fi layout descriptions or HTML/SVG mockups I can react to. Ask me for approval and ask any product-defining questions with a concrete recommendation.
3. Implement in small committed slices: (a) domain and period/money layer with tests, (b) persistence and migration with backup compatibility, (c) UI components and screens, (d) integrations (dashboard card, alerts, health score, analytics), (e) polish and accessibility.
4. Verify UI visually in an emulator or the built-in browser with screenshots in light/dark and at large text sizes. Do not claim UI works from analyzer output alone. Report anything unverified honestly.
5. Update `docs/` (a `docs/features/budgets.md` describing the model, semantics and decisions).

**Start now with step 1 only: read, baseline, then return the audit and proposal for my approval.**
