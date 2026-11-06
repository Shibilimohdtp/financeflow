# 05 · Screen status

Status of every screen, sheet and feature widget against Bloom. **Update this file in the commit that changes a
screen.** Values:

- **Bloom** — fully redesigned to the recipes; screenshot in `../screenshots/<slice>/`.
- **Tokens** — reads tokens and shared components (DS-7 sweep), so it already has Geist, ink buttons, squircle
  cards and the new colours, but its layout and hierarchy are not redesigned yet.
- **Legacy** — still uses old shims (`StillwaterTokens`, `StillwaterColors`, `FfListRow`, `FfSnackbar`,
  `FfConfirmDialog`, raw pickers/sheets).

Owner: "—" means free to take. Check the **In flight** table in `../CHANGELOG.md` before starting; add your row.

## Shell and shared

| Item | File | Status | Notes |
|---|---|---|---|
| App shell + floating dock | `lib/app/router.dart` | Bloom (759f13b) | `FfDock` in the bottom-bar slot (not over content) |
| Old bottom bar | `shared/widgets/stillwater_bottom_navigation_bar.dart` | unused | Delete in DS-9 |
| Shared components | `lib/shared/widgets/` | Bloom (fe46fbc + later) | `FfBarChart` & `FfDonutChart` restyled in Bloom (DS-B8a). DS-B7a added hero/tone/semantics to `FfProgressBar`, a reference series to `FfLineChart`, within/over-plan months to `FfMonthGrid`, `FfHeroFigures`, `FfPeriodBar(units:)` |

## Screens

| Area | Screen / widget | File(s) | Pattern | Status | Owner | Notes |
|---|---|---|---|---|---|---|
| Home | Dashboard & all widgets (header, balance, carousel, actionable, cash flow, budgets, loans, goals, recent transactions) | `dashboard/dashboard_screen.dart`, `dashboard/widgets/*` | A | Bloom (this commit) | — | Full Stillwater Bloom redesign: bespoke header with brand mark, command balance anchor (flush right-aligned account selector), FfGroupedContainer actionable rows with FfIconTiles, restyled CashFlowCard with FfBarChart & calm income/expense tiles, Bloom budget card with FfProgressBar, Bloom savings goals with FfProgressRing, and Money-matched recent transactions. Dock floats over content with FfDock.insetOf and FfDock.fabLocation. |
| Home | Month selector header | `dashboard/widgets/month_selector_header.dart` | — | Tokens | DS-B7 chat | Not imported anywhere (Budgets has a private copy); delete in B7d |
| Money | Transactions list & all widgets (search pill, summary card, day headers, filter sheet, active chips, tiles) | `transactions/transactions_screen.dart`, `widgets/*` | B / E | Bloom (07fbca8) | — | Redesigned on FfAurora with tactile stadium search pill, Bloom squircle summary card with flow indicator, frosted floating day headers, tokenized active filter chips, squircle swipe tiles, full Pattern E filter & sort sheet, and FfDock.fabLocation FAB |
| Money | Filter sheet, active filter chips | `transactions/widgets/transaction_filter_sheet.dart`, `active_filter_chips.dart` | E / B | Bloom (07fbca8) | — | Bloom Ledger Lens filter sheet with visual account/category selectors, amount presets, squircle inputs, and tokenized active chips |
| Money | Add/edit transaction (full screen + sheet + form) | `transactions/add_edit_transaction_screen.dart`, `add_edit_transaction_sheet.dart`, `transaction_form.dart`, `form/widgets/*`, `widgets/transaction_pickers.dart` | E | Tokens (B10d complex & edit) | DS-B10 chat | Complex purposes (loan EMI split, debt obligations, investment assets, subscriptions) and edit mode (provenance badge, destructive delete with confirm dialog, update action, caller hooks) redesigned in Bloom. Pickers polish next. |
| Money | Transaction detail | `transactions/transaction_detail_screen.dart` | D | Tokens | — | |
| Plan | Budgets list | `budgets/budgets_screen.dart` + `widgets/plan_summary.dart`, `budget_row.dart`, `budget_group_section.dart`, `plan_insight_card.dart`, `plan_bills_card.dart`, `plan_setup.dart` | A | Bloom (DS-B7b) | DS-B7 chat | On `BudgetBoard`; safe to spend, rose hero, one insight, groups, bills, suggested setup; hero ↗ opens Money with the exact budget scope |
| Plan | Budget detail | `budgets/budget_detail_screen.dart` | D | Bloom (DS-B7c) | DS-B7 chat | |
| Plan | Add/edit budget | `budgets/add_edit_budget_sheet.dart`, `budget_sheets.dart` | E | Bloom (DS-B7b) | DS-B7 chat | `showFfSheet`; limit first with live per-day preview, usual-spend suggestion, category chips, cadence and alert pills |
| Plan | Budget card, insights card, visual summary | (deleted) | — | Removed (DS-B7b) | — | Merged into the plan hero and the single insight card |
| Plan | Placeholder | `budgets/budgets_placeholder_screen.dart` | — | Legacy | DS-B7 chat | Not referenced anywhere in `lib/`; delete |
| Insights | Analytics | `analytics/analytics_screen.dart`, `widgets/analytics_metrics_hero.dart`, `analytics_cash_flow_card.dart`, `expense_category_breakdown.dart` | A | Bloom (7f05c84) | DS-B8b | Pattern A on FfAurora, dusk hero card, single insight card, restyled charts |
| Insights | Financial health | `financial_health/financial_health_screen.dart` | D | Bloom (431c504) | DS-B8c | Pattern D with wellness score hero, 4 indicator cards on FfRangeBand with CTAs |
| More | Settings hub | `settings/more_screen.dart`, `settings_screen.dart`, `settings_detail_screen.dart` | F | Bloom (this commit) | DS-B9 chat | Redesigned on FfAurora with sand vault hero and split files |
| More | Security, lock | `security/security_settings_screen.dart`, `lock_screen.dart` | F / G | Bloom (this commit) | DS-B9 chat | Security in Pattern F; Lock in Pattern G with calm aurora, squircle mark, and zero static colours |
| More | Backup, restore preview, export | `backup/backup_screen.dart`, `restore_preview_screen.dart`, `export/export_screen.dart` | F | Bloom (this commit) | DS-B9 chat | Backup in Pattern F status hero, restore preview 2-step breakdown, export with pills & privacy badge |
| More | Alerts inbox, alert settings | `alerts/alerts_inbox_screen.dart`, `alert_settings_sheet.dart` | A/B hybrid / E | Bloom (this commit) | — | Alerts inbox redesigned as Pattern A/B hybrid on FfAurora with command hero card (dusk/moss/rose), split Geist numerals, FfPillBar filter, FfGroupedContainer sections, contextual CTAs, FfShape squircle swipe-to-dismiss, and calm empty state; alert settings in Pattern E |
| More | Branding preview | `settings/branding_preview_screen.dart` | — | Tokens | — | Replaced by the debug gallery (DS-10) |
| Accounts | Accounts list | `accounts/accounts_screen.dart` | C | Bloom (65ff966) | — | Screen in Bloom; sheet extracted and redesigned in DS-B11 with post-save row highlight |
| Accounts | Add/edit account sheet | `accounts/add_edit_account_sheet.dart` | E | Bloom (this commit) | — | Redesigned in Stillwater Bloom Pattern E: live `FfAccountPreviewCard`, `FfAccountTypeTiles`, institution autofill chips, duplicate warning, masked ID privacy assist, edit mode with baseline note and archive/delete |
| Loans | Loans list | `loans/loans_screen.dart` | C | Bloom (65ff966) | — | |
| Loans | Loan detail | `loans/loan_detail_screen.dart` | D | Bloom (65ff966) | — | Next-EMI and info sections inside are Tokens; hero figures use `FfHeroFigures` (DS-B7a) |
| Loans | EMI schedule, add/edit loan, payment account picker | `loans/widgets/emi_schedule_view.dart`, `add_edit_loan_sheet.dart`, `payment_account_picker.dart` | B / E | Tokens | — | |
| Goals | Savings goals list, detail, add/edit, contribution | `savings_goals/*.dart` | C / D / E | Tokens | — | Tide hero |
| Subscriptions | List, detail, add/edit, recurring suggestions | `subscriptions/*.dart` | C / D / E | Tokens | — | Sand hero; `FfMonthGrid` for payments |
| Investments | List, detail, add/edit | `investments/*.dart` | C / D / E | Tokens | — | Dusk hero |
| Lending | Lending & borrowing, record detail, sheets | `personal_debts/*.dart` | C / D / E | Tokens | — | Record detail has many leftover alpha tints |
| Ingestion | Needs review, CSV import, SMS/notification permission | `ingestion/*.dart` | B / E / G | Tokens | — | |
| Onboarding | Onboarding | `onboarding/onboarding_screen.dart` | G | Tokens | — | |

## Suggested order after Budgets

1. Insights (Analytics + charts restyle) — completes the four main tabs.
2. Add/edit transaction — the most-used form.
3. Savings goals, Subscriptions, Investments (pattern C/D, quick wins with tide/sand/dusk heroes).
4. Settings, Security, Backup (pattern F).
5. Remaining details, sheets, onboarding, lock.
6. DS-8 (Tide, Graphite, theme picker, reduced-effects setting), DS-9 (remove shims), DS-10 (gallery).
