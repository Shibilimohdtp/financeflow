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
| Home | Dashboard & all widgets (header, balance, carousel, actionable, cash flow, budgets, loans, goals, recent transactions) | `dashboard/dashboard_screen.dart`, `dashboard/widgets/*` | A | Bloom (this commit) | — | One section pattern (title, count, `FfSectionLink`), one `FfSpace.xl` gap. Cash flow as a picture, budget card with pace (DS-B7d reuses it), goals ring with next goal, Needs attention strip; matching skeletons, `HomeCardError` retry, budget setup card. Header redesigned in DS-B13 (Direction A: personal greeting in `displaySm`, date subline, privacy eye toggle, alerts bell, no wordmark, no shield pill, non-sticky scroll). Comparison sheets in `screenshots/ds-b13/`. |
| Home | Month selector header | `dashboard/widgets/month_selector_header.dart` | — | Tokens | DS-B7 chat | Not imported anywhere (Budgets has a private copy); delete in B7d |
| Money | Transactions list & all widgets (search pill, summary card, day headers, filter sheet, active chips, tiles) | `transactions/transactions_screen.dart`, `widgets/*` | B / E | Bloom (07fbca8) | — | Redesigned on FfAurora with tactile stadium search pill, Bloom squircle summary card with flow indicator, frosted floating day headers, tokenized active filter chips, squircle swipe tiles, full Pattern E filter & sort sheet, and FfDock.fabLocation FAB |
| Money | Filter sheet, active filter chips | `transactions/widgets/transaction_filter_sheet.dart`, `active_filter_chips.dart` | E / B | Bloom (07fbca8) | — | Bloom Ledger Lens filter sheet with visual account/category selectors, amount presets, squircle inputs, and tokenized active chips |
| Money | Add/edit transaction (full screen + sheet + form) | `transactions/add_edit_transaction_screen.dart`, `add_edit_transaction_sheet.dart`, `transaction_form.dart`, `form/widgets/*`, `widgets/transaction_pickers.dart` | E | Bloom (this commit) | — | Fully redesigned in Stillwater Bloom. Amount first with type-tinted `FfAmountHero` card, Geist 300 money numerals, live consequence line. `FfSegmentedPill` persistent type switcher, squircle category row with full sheet trigger, quick date pills, responsive payee suggestions, purpose subforms (loan EMI, debts, investments, subscriptions), edit mode with provenance & destructive delete, zero static `StillwaterColors`, zero leaks in screen or pickers. Screenshots in `../screenshots/ds-b10/`. |
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
| Goals | Savings goals list, detail, add/edit, contribution | `savings_goals/*.dart` | C / D / E | Bloom (this commit) | — | Tide hero, Pattern C list with milestone callout, Pattern D detail with progression chart & hero figures, Pattern E templates & consequence |
| Subscriptions | List, detail, add/edit, recurring suggestions | `subscriptions/*.dart` | C / D / E | Tokens | — | Sand hero; `FfMonthGrid` for payments |
| Investments | List, detail, add/edit | `investments/*.dart` | C / D / E | Tokens | — | Dusk hero |
| Lending | Lending & borrowing, record detail, sheets | `personal_debts/*.dart` | C / D / E | Tokens | — | Record detail has many leftover alpha tints |
| Ingestion | Needs review | `ingestion/needs_review_screen.dart`, `widgets/*` | B | Bloom (this commit) | — | Redesigned triage queue with Focus mode (1-by-1 card triage, swipe accelerators, source evidence, trust indicators) and List mode, filter chips with counts, bulk actions, and calm zero-state |
| Ingestion | CSV import, SMS/notification permission | `ingestion/csv_import_screen.dart`, `permissions/*` | E / G | Tokens | — | |
| Onboarding | Onboarding | `onboarding/onboarding_screen.dart` | G | Tokens | — | |

## Suggested order after Budgets

1. Insights (Analytics + charts restyle) — completes the four main tabs.
2. Add/edit transaction — the most-used form.
3. Savings goals, Subscriptions, Investments (pattern C/D, quick wins with tide/sand/dusk heroes).
4. Settings, Security, Backup (pattern F).
5. Remaining details, sheets, onboarding, lock.
6. DS-8 (Tide, Graphite, theme picker, reduced-effects setting), DS-9 (remove shims), DS-10 (gallery).
