# Phase 0 audit and roadmap (2026-11-05)

Status: **approved 2026-11-05** with the owner decisions recorded in section 10.

## 1. Baseline

| Check | Result |
|---|---|
| `flutter analyze` | Clean, no issues |
| `flutter test` (all ~94 files) | **409 passed, 2 failed** |
| Failing | `test/widget/loans_widget_test.dart`: "LoanDetailScreen renders overdue banner…" (no `Pay All (3) Overdue`) and "EmiScheduleView renders status pills…" (no `Mark All (2) Paid`). Both fixtures are built from `DateTime.now()`, so the likely cause is a date-dependent fixture rather than removed UI (the labels still exist in `loan_detail_screen.dart:756` and `emi_schedule_view.dart:140`). Not yet confirmed. |
| Builds / device | Not run in Phase 0 (no code change; device work requires the backup gate). |

`docs/context.md` is **not trustworthy**. It reports "146/146 tests" and "READY FOR PRODUCTION". It also lists `pdf`, `printing`, `cryptography`, `csv` and `telephony` dependencies that are not in `pubspec.yaml`, and it says iOS, desktop and web are "complete". Treat it as aspirational until it is rewritten.

### Staged, uncommitted changes (transactions)

There are 12 files, +1392/−580. The changes add a `selectedMonth` filter to the transaction filter state, group older transactions by month name, add a new `TransactionTile` widget, add Levenshtein fuzzy matching to payee suggestions, refine categorization, and update the matching tests. They are a reasonable but incremental change, and they add a **second, conflicting date filter**: `selectedMonth` and `startDate`/`endDate` are ANDed together. All tests touching them pass.
**Recommendation:** commit them as-is as a checkpoint ("previous-model WIP") so the baseline is clean and recoverable. The transactions rebuild will then supersede the filter and grouping parts. The fuzzy payee matching and the tile are worth keeping.

## 2. Domain and data-model flaws (highest severity first)

1. **Money is `double` everywhere.** This covers the entity (`amount`, components), the domain model, every calculator and budgets. `MoneyMath` only rounds or compares with a 0.01 tolerance. Sums over thousands of rows drift, and `==` comparisons are unsafe. *Fix:* use int minor units (`amountMinor`) in the schema, with a read-time fallback from the legacy double, a backup format bump and `Money` value types in the domain.
2. **Income/expense semantics contradict the ADR.** `docs/architecture/transaction-semantics.md` says that for loan payments, only interest and fees are expense. `Transaction.consumptionExpenseAmount` (`lib/models/transaction.dart`) counts the **full** `loanRepayment` amount as spending. `investmentRedemption` reports `interestComponent` as "gain". This is product-defining; see decision D5.
3. **No refund concept.** A refund can only be entered as Income. That inflates income and never reduces the category's spend, so the Food budget stays "over" after a refund.
4. **Period logic is duplicated 4+ times with drift.** The copies are in `AnalyticsCalculator.getDateRangeForTimeRange`, `BudgetCalculator.getPeriodBounds`, `dashboardDateRangeProvider`/`dashboardPreviousDateRangeProvider`, `groupTransactionsForList`, and `budget_detail_screen.dart`. Specific bugs:
   - Week start is hard-coded to Monday, and there is no user preference.
   - Week and previous-week ranges are built with `Duration(days: 7)` and `start.add(Duration(days: i))`, which breaks across DST (latent for India-only users, real for anyone else).
   - **Previous-period comparison is not like-for-like.** Month-to-date is compared with the *whole* previous month, so on the 5th the app reports something like "spending down 80%". This is the main reason "versus last period" feels wrong.
   - Analytics "Custom" defaults to the month start through `DateTime.now()`. Dashboard "Custom" defaults to the full month. The custom previous range is off by one duration.
   - The dashboard reads `DateTime.now()` once when the provider is built, so "This week" and "This month" go stale across midnight or month rollover until something invalidates them.
   - There is no "Day" period anywhere.
5. **Two independent period states.** Home (`selectedDashboardPeriodProvider` + month browsing) and Insights (`selectedAnalyticsTimeRangeProvider`, current period only, cannot step back) disagree, so the two screens show different numbers for "this month".
6. **Aggregations are re-implemented per screen.** The dashboard uses `BalanceCalculator.calculateMonthlyCashFlow`, analytics uses `AnalyticsCalculator`, the list uses `calculateTransactionListSummary`, and budgets use `BudgetCalculator`. They share the per-transaction getters but differ in filtering. For example, the analytics account filter includes both endpoints of transfers, the type filter uses the legacy `type` instead of purpose, and `transactionCount` includes transfers. No one number is tappable to its source rows.
7. **Two parallel classification systems.** The legacy `TransactionType` (6 values, including `cash`) and `TransactionPurpose` (14 values) coexist. Filters use `type`, while maths uses `purpose`. `isReviewed` and `reviewStatus` on `Transaction` are effectively dead, because review happens in `PendingTransactionEntity`.
8. **Denormalised category name, icon and colour on every transaction.** Renaming a category leaves old rows showing the old name, and analytics groups by id but labels by the stale per-row name.
9. **Currency is hard-coded to INR** (`CurrencyFormatter.currencySymbol = '₹'`, 78 `₹` literals). `currencyCode` is stored but unused.
10. **Timezone:** dates are local `DateTime`. Bucketing uses the device's current zone, so travel shifts transactions across days. That is acceptable for v1, but it should be documented and "day" defined in one place.

## 3. Performance and scalability

- The transaction list (`filteredTransactionsProvider`) and analytics (`analyticsRawTransactionsProvider`) both `watchAllTransactions()` and filter and aggregate in Dart on every change. Analytics also builds `categoryTransactions` holding every row. At 50k rows this costs real jank and memory on every write.
- Time series loops over every transaction for every day (O(days × n)).
- The indexes exist (`date`, `accountId`, `categoryId`, `purpose`), but queries don't use where-clauses on `date`. Fix: paged, date-ranged queries plus aggregate-by-period in one pass.

## 4. UX problems per screen (code review; not yet visually verified)

- **Add/Edit transaction** (`add_edit_transaction_screen.dart`, 3,543 lines, 46 `setState`, `_submit` about 480 lines). A purpose selector, purpose-specific forms for loans/debts/investments/subscriptions, category grid, account picker, date and "more details" all live in one widget. Payee is mandatory (`validate()`), which blocks a 5-second entry.
- **Transactions list.** Quick filters, a filter sheet, a month selector (staged) and a date range overlap. "Sort" counts as an active filter. Groups are "Today / Yesterday / This week / Earlier this month / <Month>", so there are no per-day sections or daily totals. Sorting by amount still groups by date. There is no needs-review, amount-range or payee filter, no bulk edit and no saved filter. The filter state is global, so it persists, but nothing shows that it does.
- **Home** stacks 12+ sections: header, period selector, hero, account strip, actionable items, cash flow, quick actions, recent transactions, budgets, goals, top categories, insights and loans. Hierarchy is weak.
- **Insights** offers Week/Month/Year/Custom with no navigation to previous periods, a heat-map and multiple overlapping cards.
- **"Gemini AI" is not AI.** No HTTP client exists in `lib/`, and release builds have no `INTERNET` permission. The "AI" is a local heuristic behind a Gemini consent screen. That misleads users and Play reviewers. (On the plus side, "no internet permission" is a strong, verifiable privacy claim.)

## 5. Design system

- The naming is mixed: `stillwater_*` files and classes, a "Lichen Ledger" palette in `stillwater_colors.dart`, and theme labels "Lichen Ledger (Light/Dark)" in `app_settings.dart`. The app is still labelled "FinanceFlow".
- The tokens exist (`StillwaterTokens`), but only 75 of ~115 feature files reference them. Hard-coded values include 56 numeric `EdgeInsets` and 190 raw `fontSize:` (mostly 10–11 px, which is too small for accessibility and ignores the type scale).
- There is only one palette and no selectable themes. The docs list two different spacing scales (context.md vs tokens).

## 6. Store readiness gaps

| Area | Finding | Severity |
|---|---|---|
| **Isar 3.1.0+1** | Upstream is unmaintained. Its Android native libs predate the **16 KB page-size** requirement Google Play enforces for apps targeting Android 15+. That likely blocks new submissions and updates. The community fork (`isar_community`) is a near drop-in with the same file format. | **Blocker** |
| Release signing | `release` uses the **debug** signing config. | **Blocker** |
| SMS permissions | `READ_SMS`/`RECEIVE_SMS` in the main manifest. Play only allows them for default SMS handlers or approved exceptions, through a Permissions Declaration with video and review. Rejection risk is high. | High |
| Notification listener | Allowed, but needs a prominent in-app disclosure and a Data Safety declaration. | Med |
| iOS | `Info.plist` has **no `NSFaceIDUsageDescription`**, so the app crashes on Face ID auth. SMS and notification ingestion are impossible on iOS, so the feature set needs an iOS-specific shape (CSV, manual, Shortcuts later). | High (iOS) |
| Version, identity | `1.0.0+1`, app ID `com.financeflow.app.financeflow` (awkward, but changing it after any public install breaks continuity. Decide **before** first release.) | Decision |
| Privacy policy, Data Safety, listing assets | None in repo | Needed |
| Localization / RTL | No `l10n`, strings hard-coded, `₹` hard-coded | Med |
| Accessibility | Large-font support is partial (2 ad-hoc `textScaler` checks), and 10–11 px text is common | Med |
| Backup | PBKDF2 at **10k** iterations (weak for 2026; ≥310k recommended), AES-CTR + HMAC is OK. Round-trip of all new fields (money records, advances, EMI payments) needs a test. | Med |
| Dark mode | Present | OK |
| Startup | `main()` is synchronous through `runApp`, the DB opens after the first frame, there's a retry UI | OK |

## 7. Features ranked by user impact × current quality

| Rank | Feature | Impact | State | Recommendation |
|---|---|---|---|---|
| 1 | Transactions (add, list, filter) | Core | Half-baked | Rebuild (Phase 2) |
| 2 | Home + Insights (period analysis) | Core | Numbers inconsistent | Rebuild on shared aggregation (Phase 3) |
| 3 | Budgets | High | Logic OK, Monday-only weeks, refund-blind | Rebase on shared periods; redesign |
| 4 | Accounts and balances | High | Logic OK; balance maths in double | Money migration |
| 5 | Ingestion review (notifications/CSV) | High (India) | Works, big screen (930 lines) | Keep; simplify UI; SMS behind decision D3 |
| 6 | Subscriptions / bills | Med-high | Works | Feeds "upcoming bills" |
| 7 | Loans/EMI + personal debts/advances | Med | Large and complex (about 6k lines combined) | Keep the domain; collapse the UI; EMI accounting decision D5 |
| 8 | Backup/restore/export | Critical for trust | Works; weak KDF | Harden, test round-trip |
| 9 | Security (PIN/biometric) | High trust | Works; iOS plist missing | Fix |
| 10 | Savings goals | Med | Works | Redesign only |
| 11 | Investments | Low-med | Manual valuations | Keep minimal or hide in v1 |
| 12 | Financial health score, heat-map, "insights" engine | Low | Opaque scores | Cut or fold into Insights |
| 13 | "Gemini AI" | Low | Not real | Remove or rename to "Smart suggestions" (D4) |

## 8. Roadmap (proposed)

I agree with the proposed order, with two changes. First, **platform risk moves to the front**: migrating to the Isar fork must happen *before* the int-money schema migration, so the database file changes once, behind one backup gate. Second, **feature cuts happen early**, so dead features don't get redesigned.

**Phase 1a: Platform and baseline** (small, one backup gate)
- Commit the staged work; fix or quarantine the 2 date-dependent tests (use a fixed clock).
- Swap to `isar_community` (verify 16 KB alignment of `.so`), add a release-signing scaffold (keystore stays outside git), and add `NSFaceIDUsageDescription`.
- Full AGENTS.md startup gate: analyze, tests, debug and release APKs, then `verify_debug_startup.ps1`.

**Phase 1b: Domain correctness** (pure Dart, test-first)
- `Period` value type (day/week/month/year/custom, week-start preference, calendar arithmetic only, `previous()` and `toDate()` like-for-like).
- `Money` (int minor units) and schema `amountMinor` with legacy fallback, a migration test against an old-format DB and old backups.
- Purposes: add `refund` (negative spend in its category). Finalize EMI and investment semantics (D5). Retire `TransactionType` from logic (filters by purpose groups).
- One `LedgerAggregator` (totals, by category, by payee, by account, time buckets, comparison). Dashboard, analytics, budgets and the list all use it. Each result carries the `TransactionQuery` that produced it, so every number can drill down.
- Date-ranged, paged repository queries.

**Phase 1c: Tokens and component kit**
- One theme namespace (name decided in D1), colour roles, type scale, spacing, radii, elevation and motion; light/dark; 3–4 selectable accent themes.
- Components: card, list row, amount text, chip, segmented control, sheet, empty state, skeleton, period switcher.

**Phase 2: Transactions rebuild.** Amount-first quick add (optional payee, smart defaults), separate "advanced" flows for loan, debt and investment purposes. Daily sections with sticky day totals, a unified filter model (query object) with chips and one-tap clear, swipe actions, multi-select bulk edit, and a detail screen. The add/edit screen gets split into a controller and widgets of 300 lines or less.

**Phase 3: Analysis rebuild.** A shared Day/Week/Month/Year/Custom switcher with prev/next. Home answers: spent vs last period (like-for-like), top categories, budget status, upcoming bills. Insights adds trend and payees. Every figure drills down.

**Phase 4: Redesign the remaining screens**, with empty, loading and error states and accessibility passes (contrast, 48 dp, semantics, 200% text).

**Phase 5: Release hardening.** 50k-row performance benchmark on device, backup round-trip of every entity, KDF upgrade (with versioned envelope), app size, privacy policy, Data Safety draft, listing assets and an iOS parity checklist.

## 9. Decisions needed from the owner

- **D1 Brand:** keep "FinanceFlow" (recommended; it's in the app ID, assets and backups) or move to "Lichen Ledger". The theme namespace gets renamed to a neutral `AppTheme`/`ff` either way.
- **D2 Staged changes:** commit as a checkpoint (recommended) or revert.
- **D3 SMS on Play:** ship v1 *without* SMS permissions, using notification listener + CSV (recommended). Keep SMS in a separate sideload/F-Droid flavor, or apply for the Play exception later.
- **D4 "Gemini AI":** remove and rename to local "Smart suggestions" (recommended), or implement real opt-in Gemini (adds `INTERNET` and weakens the "no network" claim).
- **D5 EMI and loan accounting:** "Spending" counts interest and fees only, with principal shown as "Debt payments" in cash flow (recommended, matches the ADR). The alternative is to count the full EMI as spending, as the code does today.
- **D6 Scope:** India-first INR v1 with a currency abstraction ready (recommended), or multi-currency v1.
- **D7 Cuts for v1:** hide financial-health score, heat-map, and investments (recommended), or keep.
- **D8 Isar fork migration:** approve moving to `isar_community` in Phase 1a. This needs a personal encrypted backup per AGENTS.md before any device validation.

## 10. Owner decisions (2026-11-05)

- **D1 Brand and theme:** keep the "FinanceFlow" name and the current theme (palette and naming) unchanged.
- **D2 Staged work:** committed to `main` as a checkpoint (`ff526a9`).
- **D3 SMS:** keep SMS reading as a feature. Separately, local notifications are reported as never arriving; diagnose and fix.
- **D4 AI:** remove every AI/Gemini/LLM feature and its UI, settings, consent and activity log. No "smart suggestions" branding.
- **D5 Loans/EMI:** the **full EMI amount counts as spending** (code already does this; the ADR is updated). The loan balance shown to users must include the **remaining interest**, not just outstanding principal.
- **D6 Currency:** INR stays the default, with an app-wide option for USD, EUR and GBP.
- **D7 Home:** remove duplicate or overloaded home sections, but keep every feature reachable elsewhere.
- **D8 Isar fork:** follow the roadmap. It is gated on a personal encrypted backup per AGENTS.md.
