# Prompt: Savings goals, Needs review and Investments redesign (DS-B14)

Paste everything below the line into a new Claude Code chat (Opus 5.5).

---

You are the lead product designer, UX designer and Flutter engineer for **FinanceFlow** (Flutter, Riverpod, Isar;
fully local, privacy-first, no backend). The app uses one design system, **Stillwater**, in its **Bloom** visual
language. Home, Money, Accounts and Loans already shipped in Bloom and are the quality bar. Your job is one
combined task: redesign three feature areas, **end to end, every screen, sheet and widget in them**:

1. **Savings goals**: list, goal detail, add/edit goal sheet, add contribution sheet.
2. **Needs review**: the queue of transactions detected from SMS, notifications and imports that wait for a human
   decision, with its cards, filters, actions and sheets.
3. **Investments (portfolio)**: portfolio list, investment detail, add/edit investment sheet.

**The brief is design, not decoration.** These screens are currently at "Tokens" status: they already inherit Geist,
ink buttons and squircle cards, and that is exactly what is wrong with them, because the layouts, hierarchy and
bottom sheets are still the old stacked-form, list-of-cards design. Recolouring or re-skinning is explicitly the wrong
outcome. Each area must get a **considered, creative layout and interaction design** that makes the job of that
screen fast, clear and a pleasure, built from Bloom's vocabulary (aurora canvas, hero tones, squircles, light
oversized numerals, ink pills with one lime accent, dot-matrix / ring / range-band viz, floating dock) and with our
own signature, never copied from the reference imagery. The three areas should feel like siblings of Loans and Accounts
but each with its own character: goals are about **progress and momentum**, review is about **fast, confident
triage**, investments are about **a calm read of what you own**.

## Read first, in this order (binding)

1. `AGENTS.md` (backup gate, standalone-startup gate, UI section).
2. `docs/design-system/bloom/README.md`, then `01-direction.md`, `02-foundations.md`, `03-components.md`,
   `04-screen-recipes.md` (patterns B, C, D and E), `05-screen-status.md`, `06-workflow.md`.
3. `docs/design-system/CHANGELOG.md`: In flight, Decisions, Done rows for DS-B1…B6.
4. Look at the golden screenshots, then read the code behind them: `docs/design-system/screenshots/ds-b4/home.png`,
   `ds-b5/money.png`, `ds-b6/b6_loans.png`, `ds-b6/b6_loan_detail.png`, `ds-b6/b6_accounts.png`,
   `ds-b3/bloom_components.png`; code: `lib/features/loans/loans_screen.dart` and `loan_detail_screen.dart`,
   `lib/features/accounts/accounts_screen.dart`, `lib/shared/widgets/ff_data_viz.dart` (`FfProgressRing`,
   `FfDotMatrix`, `FfRangeBand`, `FfLineChart`, `FfMonthGrid`), `ff_surfaces.dart`, `ff_sheet.dart`,
   `ff_navigation.dart` (`FfCarousel`, `FfPillBar`), `ff_chip.dart`, `ff_segmented_pill.dart`, `ff_round_buttons.dart`,
   `ff_stat_tile.dart`, `ff_icon_tile.dart`, `ff_category_tile.dart`, `ff_corner_badge.dart`, `ff_empty_state.dart`.
5. The areas themselves (read every file; numbers are lines):
   - **Goals**, `lib/features/savings_goals/`: `savings_goals_screen.dart` (344), `savings_goal_detail_screen.dart`
     (459), `add_edit_savings_goal_sheet.dart` (334), `add_goal_contribution_sheet.dart` (261),
     `savings_goals_controller.dart` (168); models `lib/models/savings_goal.dart` (name, targetAmount, targetDate,
     linkedAccountId, notes, isCompleted) and `goal_contribution.dart`; logic
     `lib/services/savings_goal_calculator.dart`; test `savings_goals_widget_test.dart`,
     `savings_goal_calculator_test.dart`.
   - **Needs review**, `lib/features/ingestion/`: `needs_review_screen.dart` (**917**), `needs_review_controller.dart`
     (272), plus `lib/models/ingestion/`, `lib/services/` ingestion services (`grep -rln "PendingTransaction\|ingestion" lib/services`),
     tests `needs_review_widget_test.dart`, `ingestion_service_test.dart`, `sms_parser_test.dart`. The entry points
     are Home's actionable strip, the Money tab's pending-review task card (already Bloom), alerts and
     `lib/app/router.dart`. The review flow confirms a transaction through `AddEditTransactionSheet` (do not break it).
   - **Investments**, `lib/features/investments/`: `investments_screen.dart` (326), `investment_detail_screen.dart`
     (389), `add_edit_investment_sheet.dart` (436), `investments_controller.dart` (113); model
     `lib/models/investment.dart` (`AssetType`, quantity, purchase price/date, **user-entered** `currentValue`,
     `investedAmount`, realised and unrealised P/L, `lastValuationDate`, ledger baselines); logic
     `lib/services/investment_calculator.dart` (`PortfolioSummary`, `AssetAllocationSlice`); test
     `investment_calculator_test.dart`.
   - Also in scope as the last, optional slice: CSV import (`csv_import_screen.dart` 886 lines) and the SMS and
     notification permission screens in `lib/features/ingestion/permissions/`. Ask me before starting that slice.

## Coordination and ownership (check before anything else)

- `git status`, `git log --oneline -10`, and the CHANGELOG **In flight** table. Other chats may be working on Home
  widgets (DS-B12), the Home header (DS-B13), Budgets (DS-B7), Insights (DS-B8), More (DS-B9), Add transaction (DS-B10)
  and Add account (DS-B11). If any of their In flight rows touches a file you need, stop and ask me.
- **Do not edit**: `lib/features/dashboard/`, `lib/features/budgets/`, `lib/features/analytics/`,
  `lib/features/settings/`, `lib/features/transactions/` (the add/edit transaction flow, Money list), `lib/features/accounts/`,
  `lib/features/loans/`. You only call into them. The Home goals card (`savings_goals_overview_card.dart`) and
  actionable strip belong to DS-B12; if you change what they depend on (a provider shape, a route), tell me and update
  only the minimum call site.
- You may add **new shared components** to `lib/shared/widgets/` (with tests, component-sheet screenshot and
  `03-components.md`). Edit existing shared components only to extend them compatibly; run the full suite after any such edit.
- In `05-screen-status.md` and `CHANGELOG.md` change only your own rows and re-read each file right before editing.

## What exists today (verify, do not trust)

- Goals: a list with progress bars, a detail with the goal facts and a contribution history list, and two sheets
  built from stacked `FfTextField`s and pickers.
- Needs review: one very long screen with filter chips, a list of pending-item cards with actions, and flows to
  confirm, edit, dismiss or ignore; it is the largest of the three and the least designed.
- Investments: a list of holdings with totals, a detail with `_DetailRow` key-value rows, and a long add/edit sheet.
- Each of the three has its own private `_SectionLabel` and ad-hoc spacing (the duplicated private widgets are a smell:
  replace them with shared section components).

## Design directions (starting points; improve them, justify what you change)

### 1. Savings goals: progress and momentum (tide hero)

- **List (pattern C):** a tide `FfHeroCard` summarising all goals (total saved vs total target as a split
  amount with an `FfProgressRing` and a "next milestone" line), then goal cards as **item cards with a ring and
  a pace state**: "On track", "Behind by ₹X/month", "Done" always with icon plus words, never colour only. Consider an
  `FfCarousel` for the nearest goals with a vertical list for the rest. Completed goals collapse into a quiet
  "Achieved" section with a small celebratory but calm moment (no confetti).
- **Detail (pattern D):** hero with the goal as a big ring, saved and remaining, target date and a **"what you need
  per month" figure computed by the existing calculator**. A "path" chart (`FfLineChart` with an ideal line vs actual
  saved) if you extend `FfLineChart` with an optional reference series (shared, tested), otherwise propose another viz.
  Contribution history as a day-grouped list, an `FfMonthGrid` or dot-matrix "streak" if the data supports it.
- **Add/edit goal sheet (pattern E, creative):** start from **goal templates** as tiles (Emergency fund, Trip, Gadget,
  Vehicle, Home, Education, Custom) that prefill name and icon; the amount as a big `FfAmountField`; **date chips**
  ("3 months", "6 months", "1 year", "Pick date") and a **live line under the form** that states the consequence
  ("₹4,200 a month gets you there by 12 Mar"); an optional linked account as a chip row. A mini preview of the goal card
  at the top that updates as you type.
- **Contribution sheet:** a numeric-first sheet with quick-amount chips (suggested monthly amount, round numbers,
  "remaining"), the account the money moves from if the logic supports it, and a preview ("Goal reaches 62%").
  Must keep today's behaviour exactly; do not change how contributions affect balances.

### 2. Needs review: fast, confident triage

- **Queue (pattern B, but with a creative core):** the page header shows how many items wait and a one-line promise
  ("Review in under a minute"). The primary interaction is **reviewing one item at a time with big, clear decisions**:
  evaluate a focused **triage card** (amount split, payee, detected category and account with a confidence cue, source
  chip SMS / Notification / Import, the original message snippet collapsed behind "See source") with three actions:
  **Confirm** (ink pill), **Edit** (opens the Add transaction sheet), **Dismiss** (quiet). Offer **swipe gestures as an
  accelerator only**, never the only path, with visible buttons and screen-reader actions. Also provide a **list mode**
  (the full queue, grouped by day or by source) with multi-select and **bulk confirm / bulk dismiss** for the high
  confidence items. A `FfSegmentedPill` switches "Focus" and "List"; recommend which is default and why.
- **Trust cues without colour-only:** confidence as a small labelled indicator ("Likely", "Check this"), duplicates
  flagged with an icon and text, transfers between own accounts called out.
- **Empty state is a reward:** "You're all caught up" with the date of the last review and a calm illustration built from
  shared pieces (a dot matrix, a ring), plus a link to ingestion settings.
- **Sheets:** the filter and bulk-action sheets use `FfSheet` with pills and chips, and the dismiss confirmation says
  exactly what will happen to the item (is it deleted, hidden, or remembered as "never ask again for this sender"?
  keep today's behaviour and wording unless I approve a change).
- **Privacy:** snippets of messages are shown only on this screen, respect amounts-hidden mode, and are never logged.

### 3. Investments: a calm read of what you own (dusk hero)

- **List (pattern C):** a dusk `FfHeroCard` with current value (split amount), invested, and total return as a signed
  value **and** percentage (icon, sign and words, never colour only); an **allocation band**: a segmented `FfRangeBand`
  or `FfDotMatrix` by asset type from the existing `AssetAllocationSlice`s with a legend that is also readable
  as text; holdings as item cards (name, asset type icon tile, current value, return chip, "valued 3 weeks ago" when
  stale). Sort and group by asset type as `FfPillBar` filters.
- **Staleness is the honest design problem:** values are **user-entered, not live market prices**. Never imply live
  data and never fabricate prices or charts. Surface freshness ("Updated 40 days ago") and make **"Update value"** a
  one-tap quick sheet (big amount field, previous value for reference, resulting return preview).
- **Detail (pattern D):** hero with value and return, a facts grid (units, average price, invested, realised and
  unrealised P/L, purchase date) replacing the `_DetailRow` key-values with `FfStatTile`s, linked account and notes,
  actions (update value, edit, archive) in a clear order, destructive last.
- **Add/edit sheet (pattern E, creative):** **asset type tiles** first (Stocks, Mutual funds, Gold, FD, Crypto, …
  from `AssetType`), then fields adapt to the type with helpful wording (units × price auto-computes invested amount
  with a visible, editable result), a live preview card of the holding, and the optional account as a chip row.
  Keep the ledger-baseline and P/L behaviour of the model unchanged.

## Cross-cutting rules for all three

- Build the **shared pieces first** so the three areas stay consistent and other tabs can reuse them. Likely
  candidates: a section label/heading component replacing every private `_SectionLabel`; a **type/template tile
  row**; an **item card with ring/pace/status**; a **live preview card** for sheets; a **quick-amount chip row**; a
  **consequence line** (one sentence under a form); a **stale/fresh value cue**; an **allocation band**. Share only
  what at least two places use, and say which.
- Every status (on track, behind, done, likely, check this, stale, gain, loss) uses **icon + text + tone**, never
  colour alone. Gain and loss obey the income/expense CVD rule in `02-foundations.md`.
- Heroes are rare: one hero per screen, tone by domain (tide goals, dusk investments; for review use a quiet moss or sand
  header, or none, and justify). No new blur or grain beyond hero, glass and dock rules. Reduced-effects fallback.
- Amounts via `FfAmountText` / `FfAmountField` only. Bottom sheets via `showFfSheet` / `FfSheet` and `FfSheetFooter`.
  No raw colours, sizes, radii, durations, `TextStyle(`, `Colors.*`. Remove every static `StillwaterColors` read.
- States for every screen and sheet: loading skeleton that matches the final shape, error with retry, empty (with a
  helpful next step), one item, many items, very large and zero amounts, negative returns, amounts hidden, 2× text,
  keyboard open, light and dark, reduced effects.
- Accessibility: 48 dp targets, contrast ratchet green, labelled semantics for rings, charts and swipe actions, a
  logical focus order in sheets, `Semantics` summaries on cards (keep or improve the existing ones).
- **Behaviour and data unchanged** unless I approve it in the plan: same models, calculators, controllers, providers,
  navigation callbacks and persisted values. **No Isar schema, generated-file or provider-bootstrap changes** (that is
  the backup gate: stop and ask me). Never log financial data, message contents or sender names.
- Keep keys, tooltips and semantics that tests rely on, or update those tests in the same commit and say why. Add tests
  for every new interaction and for every extracted pure function.
- Split files over ~500 lines as you go (`needs_review_screen.dart` at 917 and `csv_import_screen.dart` at 886 must be
  split into private widgets/files; do the split as a behaviour-preserving commit first).
- Format only files you touched. Never `dart format lib`. Commit only your paths. Windows 11, PowerShell and Git Bash.

## Process and slices

This is a large task. Work in **one commit per slice**, update `05-screen-status.md` and `CHANGELOG.md` in each, and
**pause for my review after each area** (a short report with the screenshots) before starting the next. If you judge
the task too large for one context window, say so in the plan and propose the exact split into separate chats, each
with a ready-to-paste continuation prompt written into `bloom/prompts/`.

- **B14a Shared pieces** needed by two or more areas (section heading, tile row, preview card, quick chips,
  consequence line, stale cue, allocation band, optional `FfLineChart` reference series) with tests, component-sheet
  screenshot, `03-components.md`.
- **B14b Goals**: list, detail, add/edit sheet, contribution sheet.
- **B14c Needs review (split)**: behaviour-preserving split of the 917-line screen and tests for what is only
  reachable through the UI today.
- **B14d Needs review (redesign)**: focus mode, list mode, bulk actions, sheets, empty state.
- **B14e Investments**: list, detail, quick "Update value", add/edit sheet.
- **B14f Polish**: cross-area states matrix, motion, consistency pass, docs.
- **B14g (ask first)**: CSV import and the two permission screens.

## Verification

- Before / after screenshots with `tool/screenshots/compare.py`, light and dark, for every screen and sheet in the
  state matrix above. Add capture tests under `tool/screenshots/` using only APIs available at the previous commit.
  **Open the PNGs and look at them**; judge each area as a whole next to its golden sibling (goals ↔ loans,
  investments ↔ accounts, review ↔ money) and fix what you see: overflow, clipped text, wrong hero contrast, empty
  areas, anything that looks like the old design with new colours.
- Tap and effort comparison for the main tasks: add a goal, add a contribution, review ten pending items (before vs
  after taps and seconds-equivalent steps), update an investment's value, add an investment. Report them.
- Widget tests for each new interaction (template tile fills the form, date chip updates the consequence line,
  focus-mode confirm/edit/dismiss and their semantics actions, bulk actions, stale cue, update-value sheet). Full
  suite green, `flutter analyze` clean, `dart run tool/design_system_audit.dart --shared` numbers not up.
- Say plainly what you could not verify (device feel, gestures on hardware, SMS and notification sources, scroll
  performance, grain). No device install without the backup gate: ask me to create and verify an encrypted
  FinanceFlow backup and keep the file and passphrase, wait for my explicit confirmation, then `adb install -r` only
  (never `adb uninstall`, `pm clear` or `flutter install`).

## Start

Do steps 0–1 of `06-workflow.md` only. Read everything above, run the coordination checks, take the baseline
(`flutter analyze`, the tests for the three areas, `dart run tool/design_system_audit.dart --shared`, current
screenshots of every screen and sheet), then return:

1. A map of each area today: screens, sheets, widgets, data each shows, actions, callers and entry points, tests that
   pin texts or keys, and the effort count (taps) for the main tasks.
2. Your target design for each area: top-to-bottom layout for every screen and sheet, the shared component for each
   block, the creative idea that gives it character, and its empty, loading, error, hidden-amount and 2× text states.
   Include at least one alternative for the two ideas you consider riskiest (for example swipe triage in Needs review)
   and your recommendation.
3. The list of shared components to add or extend, behaviour or copy changes that need my approval, risks (especially
   anything touching the confirm-to-transaction flow, ledger baselines or persistence) and questions.
4. Whether you recommend doing this in one chat or splitting it, and the slice order.

Wait for my approval before building anything.
