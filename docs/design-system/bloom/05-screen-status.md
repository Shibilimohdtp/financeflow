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
| Home | Dashboard | `dashboard/dashboard_screen.dart` | A | Bloom (759f13b) | — | |
| Home | Header, balance, accounts carousel, loans hero | `dashboard/widgets/home_header.dart`, `total_balance_hero.dart`, `home_accounts_carousel.dart`, `home_loans_overview.dart` | A | Bloom (759f13b) | — | |
| Home | Cash flow, actionable, recent, goals cards | `dashboard/widgets/cash_flow_card.dart`, `actionable_items_section.dart`, `home_recent_transactions.dart`, `savings_goals_overview_card.dart` | A | Bloom shell, inner layout Tokens | — | Inner layouts can be refined (e.g. cash flow chart → `FfLineChart`, goals → tide hero) |
| Home | Budget overview card | `dashboard/widgets/budget_overview_card.dart` | A | Bloom shell, inner Tokens | DS-B7 chat | Redo together with Budgets |
| Home | Month selector header | `dashboard/widgets/month_selector_header.dart` | — | Tokens | DS-B7 chat | Not imported anywhere (Budgets has a private copy); delete in B7d |
| Money | Transactions list | `transactions/transactions_screen.dart` + `widgets/transaction_tile.dart`, `transaction_list_summary.dart`, `transaction_day_header.dart`, `pending_review_task_card.dart` | B | Bloom (1482d5a) | — | |
| Money | Filter sheet, active filter chips | `transactions/widgets/transaction_filter_sheet.dart`, `active_filter_chips.dart` | E / B | Tokens | — | Chips are old `InputChip`s |
| Money | Add/edit transaction (full screen + sheet + form) | `transactions/add_edit_transaction_screen.dart`, `add_edit_transaction_sheet.dart`, `transaction_form.dart`, `widgets/transaction_pickers.dart` | E | Tokens (pickers and screen still read static `StillwaterColors`) | — | Biggest form (~2,700 lines); split before redesign |
| Money | Transaction detail | `transactions/transaction_detail_screen.dart` | D | Tokens | — | |
| Plan | Budgets list | `budgets/budgets_screen.dart` | A | **Legacy** | **DS-B7 chat** | In progress: plan in `../ds-b7-plan.md` |
| Plan | Budget detail | `budgets/budget_detail_screen.dart` | D | Legacy | DS-B7 chat | |
| Plan | Add/edit budget | `budgets/add_edit_budget_sheet.dart` | E | Legacy | DS-B7 chat | Raw sheet + pickers |
| Plan | Budget card, insights card, visual summary | `budgets/widgets/*.dart` | A/C | Legacy | DS-B7 chat | Three overlapping summaries → merge |
| Plan | Placeholder | `budgets/budgets_placeholder_screen.dart` | — | Legacy | DS-B7 chat | Not referenced anywhere in `lib/`; delete |
| Insights | Analytics | `analytics/analytics_screen.dart`, `widgets/analytics_metrics_hero.dart`, `analytics_cash_flow_card.dart`, `expense_category_breakdown.dart` | A | Bloom (7f05c84) | DS-B8b | Pattern A on FfAurora, dusk hero card, single insight card, restyled charts |
| Insights | Financial health | `financial_health/financial_health_screen.dart` | D | Bloom (431c504) | DS-B8c | Pattern D with wellness score hero, 4 indicator cards on FfRangeBand with CTAs |
| More | Settings hub | `settings/more_screen.dart`, `settings_screen.dart`, `settings_detail_screen.dart` | F | Bloom (this commit) | DS-B9 chat | Redesigned on FfAurora with sand vault hero and split files |
| More | Security, lock | `security/security_settings_screen.dart`, `lock_screen.dart` | F / G | Bloom (this commit) | DS-B9 chat | Security in Pattern F; Lock in Pattern G with calm aurora, squircle mark, and zero static colours |
| More | Backup, restore preview, export | `backup/backup_screen.dart`, `restore_preview_screen.dart`, `export/export_screen.dart` | F | Bloom (this commit) | DS-B9 chat | Backup in Pattern F status hero, restore preview 2-step breakdown, export with pills & privacy badge |
| More | Alerts inbox, alert settings | `alerts/alerts_inbox_screen.dart`, `alert_settings_sheet.dart` | B / E | Bloom (this commit) | DS-B9 chat | Alerts inbox in Pattern B with FfIconTile and spark unread dot, fixed 10dp font; alert settings in Pattern E |
| More | Branding preview | `settings/branding_preview_screen.dart` | — | Tokens | — | Replaced by the debug gallery (DS-10) |
| Accounts | Accounts list | `accounts/accounts_screen.dart` | C | Bloom (65ff966) | — | Add/edit account sheet inside the file is Tokens |
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
