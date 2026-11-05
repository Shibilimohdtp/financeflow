# Kickoff prompt: FinanceFlow productization (paste into a new Claude Code chat on Opus)

---

You are the lead engineer and product designer taking over **FinanceFlow**, a Flutter app that was previously built end-to-end by a weaker model ("vibe coded"). Your job is to turn it into a production-grade, store-worthy personal finance app that millions of people would happily download. You have full latitude to refactor, delete, and rebuild. Quality, correctness and clarity matter more than preserving what exists.

## Product vision (non-negotiable)

- **Fully local, privacy-first.** No backend, no accounts, no analytics/telemetry, no ads. All data stays on the device (Isar, with secure storage + biometric/PIN lock). Existing optional features (Gemini AI queries with explicit consent, SMS/notification ingestion, CSV import, encrypted backup/restore, export) must stay opt-in and privacy-safe.
- **Modern, calm, easy to use.** A first-time user should log a transaction in under 5 seconds and understand their month at a glance. Think best-in-class finance apps (Monarch, Copilot, YNAB, Wallet): opinionated, fast, uncluttered.
- **Trustworthy numbers.** Money math must be exact and consistent everywhere (dashboard, analytics, budgets, transaction list totals must always agree).
- **Store-ready** for Google Play first, then the App Store (iOS folder exists; treat iOS as a real target).

## Current state (verified facts)

- Flutter, SDK ^3.7.2, Riverpod (`flutter_riverpod` + StateNotifier, some `riverpod_annotation`), Isar 3 (generated `*.g.dart` schemas in `lib/database/schemas/`), freezed/json_serializable, `fl_chart`-style custom charts in `lib/shared/widgets/charts/`, `flutter_local_notifications`, `local_auth`, `flutter_secure_storage`, `google_fonts`, `file_picker`, `share_plus`. About 64k lines of Dart in `lib/`, version `1.0.0+1`, Android app ID `com.financeflow.app.financeflow`.
- Structure: `lib/features/<feature>/` (accounts, ai, alerts, analytics, backup, budgets, categories, dashboard, export, financial_health, ingestion, investments, loans, onboarding, personal_debts, savings_goals, security, settings, subscriptions, transactions), `lib/services/` (calculators, ingestion parsers, notifications, backup, insight engine), `lib/repositories/`, `lib/models/`, `lib/shared/widgets/` (`ff_*` components), `lib/theme/` (`stillwater_*` files).
- Tests: ~75 files under `test/` (unit, widget, integration). Treat them as a safety net, but they were also written by the previous model, so verify they assert correct behavior rather than just current behavior.
- Design: the theme is mid-rebrand. README and files say "Stillwater" (teal/sand/marigold), and a recent commit mentions "Lichen Ledger". Naming and tokens are inconsistent. Screens are visually busy and the dashboard is stacked with many cards.
- Known big files that smell like god-widgets: `features/transactions/add_edit_transaction_screen.dart` (~3.5k lines), `features/transactions/transactions_screen.dart` (~1.2k), `services/analytics_calculator.dart` (~730), `features/dashboard/dashboard_screen.dart` (~660), `features/analytics/analytics_screen.dart` (~620).
- There are **staged but uncommitted changes** in the transactions feature (transaction tile widget, list utils, controller, categorization/payee services, related tests). Inspect `git status` / `git diff --staged` first and decide whether to keep, finish or revert them. Do not discard them silently.
- Project rules live in `AGENTS.md` and `docs/` (`context.md`, `debug-startup.md`, `architecture/`, `features/`). Read them first.

## Known problems to fix (user-reported)

1. **Transactions section is half-baked**: filtering is confusing/broken, grouping and totals are unclear, add/edit flow is overly large and complex.
2. **Time-based analysis is broken or confusing**: daily, weekly and monthly views do not give a clear, trustworthy picture. Period selection, comparisons, and "where did my money go" are hard to follow.
3. **Design is "vibe coded"**: inconsistent spacing, color, typography, and component usage; weak hierarchy; the theme system is unfinished.
4. Several features feel unfinished or low quality. Audit all of them and rank by user impact.

## Required approach: do not start coding yet

### Phase 0: Audit and plan (do this first, in plan mode)
- Read `AGENTS.md`, `docs/`, `pubspec.yaml`, then the data model (`database/schemas`, `models`), `transaction_*`, `analytics_calculator`, `balance_calculator`, `budget_calculator`, dashboard and analytics code.
- Run `flutter analyze` and the test suite to get a baseline. Report failures honestly.
- Produce a written audit: data-model flaws (e.g. how transfers, refunds, loans/EMIs, debts and subscriptions count toward income/expense; timezone and period-boundary handling; money as int minor units vs double), logic bugs in period aggregation, UX problems per screen, dead/duplicate code, and store-readiness gaps (permissions justification for SMS/notification access under Play policy, privacy policy, app icon/splash, target SDK, signing, iOS limits since SMS reading is impossible on iOS, accessibility, localization/RTL, large font scaling, dark mode).
- Propose a prioritized roadmap and **ask me to confirm** before executing.

### Recommended sequencing (my recommendation, challenge it if you disagree)
1. **Foundation first, in this order**
   a. *Domain correctness*: single source of truth for period boundaries (day/week/month/custom, with week-start preference), and for what counts as income, expense, transfer, and non-reportable movement. One shared aggregation layer used by dashboard, analytics, budgets and the transaction list, with thorough unit tests (including month/week boundaries, DST/timezone, refunds, transfers, split or multi-category if present).
   b. *Design tokens and component kit* (small, not a full redesign): consolidate the theme into one coherent token set (color roles, type scale, spacing, radii, elevation, motion) with light/dark and multiple selectable color themes, plus the handful of core components (card, list row, amount text, chip, segmented control, sheet, empty state, skeleton). Do this *before* rebuilding screens so screens are built once.
2. **Transactions rebuild** (the core of the app): fast add flow (amount-first, smart defaults, recent payees/categories), clean list with date-grouped sections and sticky daily totals, a proper filter system (date range with presets, type, account, category, tag/payee, amount range, status such as needs-review, text search) with visible active-filter chips and one-tap clear, saved state that survives navigation, swipe actions, bulk edit, and a clear detail/edit screen. Split the 3.5k-line screen into small widgets and a testable controller.
3. **Analysis rebuild**: a coherent Day / Week / Month / Year / Custom switcher shared across Home and Insights; clear answers to "how much did I spend", "versus last period", "top categories", "trend", "budget status", "upcoming bills". Fewer, better cards. Every number tappable through to the exact filtered transaction list that produced it (this guarantees consistency).
4. **Full visual redesign** of remaining screens using the new system: onboarding, home, budgets, accounts, loans/debts, goals, subscriptions, settings, lock screen. Include microinteractions, proper empty/loading/error states, and accessibility (contrast, 48dp targets, semantics, text scaling).
5. **Release hardening**: performance with 50k+ transactions (indexes, paged queries, no full-table scans on build), backup/restore round-trip, schema migrations, crash-free cold start, app size, Play Store assets/listing/data-safety form drafts, privacy policy, and iOS parity checklist.

Reason for this order: redesigning screens before fixing the data/analytics layer means redesigning twice and shipping pretty wrong numbers. But a minimal token system must come first so the rebuilt screens do not become a new pile of one-off styles.

## Hard rules from this repo (follow `AGENTS.md` exactly)

- **Backup gate:** before any operation that could touch existing user data or a real device install (adb install, Isar schema or generated-file changes with a device in play, migrations, reset/clear-data/uninstall/restore, dependency or build-config changes validated on a real device), STOP and ask me to personally create and verify an encrypted FinanceFlow backup and keep the file and passphrase. Wait for my explicit confirmation. Never create it for me. Never run `adb uninstall`, `adb shell pm clear`, or `flutter install`; use `adb install -r` only. If any tool prints "Uninstalling old version", stop and report.
- **Standalone startup gate:** `main()` stays synchronous through `runApp`; no awaited DB/plugin/network work before the first frame; DB or settings failures must show recoverable in-app UI; never wipe or recreate the financial database without my explicit confirmation. Changes to bootstrap, Android native/manifest, notifications, Isar schemas or build config require: `flutter analyze`, affected tests (including `test/widget_test.dart` and `test/integration/isar_startup_test.dart`), both `flutter build apk --debug` and `--release` (Windows Gradle retry: `JAVA_TOOL_OPTIONS=-Djdk.net.unixdomain.tmpdir=.`), then `./tool/verify_debug_startup.ps1 -Serial <device>` with no `flutter run` attached.
- Log only fixed, privacy-safe startup milestones. Never log financial content.
- Environment is Windows 11 with PowerShell; the Android app ID is `com.financeflow.app.financeflow` (decide with me before changing it, since it affects data continuity and signing).

## Working style

- Plan first, then work in small, reviewable, committed slices with tests. Prefer deleting code over adding it. Keep files focused; no new 3k-line widgets.
- Write unit tests for all money, period and aggregation logic before building UI on top of it.
- Use the built-in browser or an emulator/screenshots to visually verify UI. Do not claim UI works from analyzer output alone.
- Be honest about what was not verified. If something is ambiguous or product-defining (name/branding, color themes, monetization, iOS scope), ask me with a concrete recommendation rather than guessing.
- Update `docs/` as decisions are made so future sessions have context.

**Start now with Phase 0 only: read, run the baseline, and give me the audit plus the roadmap for approval.**
