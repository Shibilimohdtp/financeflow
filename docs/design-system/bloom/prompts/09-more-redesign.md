# Prompt: More tab redesign (DS-B9)

Paste everything below the line into a new Claude Code chat (Opus 5.5).

---

You are the lead product designer and Flutter engineer for **FinanceFlow** (Flutter, Riverpod, Isar; fully local,
privacy-first, no backend). The app uses one design system, **Stillwater**, in its **Bloom** visual language.
Home, Money, Accounts and Loans already shipped in Bloom. Your job is to redesign the **More tab** and the
settings-type screens behind it so they are indistinguishable in quality and style from those screens.

## Read first, in this order (binding)

1. `AGENTS.md` (backup gate, standalone-startup gate, UI section).
2. `docs/design-system/bloom/README.md`, then `01-direction.md`, `02-foundations.md`, `03-components.md`,
   `04-screen-recipes.md` (**pattern F, settings**, and **G, secure/onboarding** for the lock screen),
   `05-screen-status.md`, `06-workflow.md`.
3. `docs/design-system/CHANGELOG.md`: In flight, Decisions, Done rows for DS-B1…B6.
4. Golden screenshots: `docs/design-system/screenshots/ds-b3/bloom_components.png`, `ds-b4/home.png`,
   `ds-b5/money.png`, `ds-b6/b6_loans.png`, `ds-b6/b6_loan_detail.png`.
5. Golden code for the shell and tone: `lib/features/dashboard/dashboard_screen.dart`,
   `lib/features/loans/loans_screen.dart`, and `lib/shared/widgets/` (`ff_grouped_container.dart`, `ff_row.dart`,
   `ff_section_header.dart`, `ff_sheet.dart`, `ff_chip.dart`, `ff_surfaces.dart`).
6. The files in scope:
   - `lib/features/settings/` (`settings_screen.dart` is 1,011 lines and holds both the hub and a private
     `_SettingsDetailScreen`; `settings_controller.dart`; `branding_preview_screen.dart`)
   - `lib/features/security/` (`security_settings_screen.dart`, `lock_screen.dart`)
   - `lib/features/backup/` (`backup_screen.dart`, `restore_preview_screen.dart`) and `lib/features/export/export_screen.dart`
   - `lib/features/alerts/` (`alerts_inbox_screen.dart`, `alert_settings_sheet.dart`)
   - their tests (`grep -rln "SettingsScreen\|SecuritySettings\|BackupScreen\|ExportScreen\|AlertsInbox\|AlertSettings" test`).

## What exists today (verify, do not trust)

- The More tab is `SettingsScreen` (router label "More"). Status is **Tokens**: Geist, ink buttons and squircle
  cards already apply, but it still opens with a floating `SliverAppBar` and the hierarchy is not redesigned.
- The lock screen still reads static `StillwaterColors`.
- Backup, restore preview and export are **backup-gated flows**: this slice changes UI only, never behaviour,
  file formats, encryption, passphrase handling or schema.
- `branding_preview_screen.dart` is replaced later by the debug gallery (DS-10); do not invest in it.

## The task

Redesign More as **pattern F** on `FfAurora`, with the detail screens following the same pattern. Keep behaviour,
settings keys and data untouched. Suggested target, which you should challenge in your plan:

**More (hub)**
1. Large "More" header on the aurora (no floating `SliverAppBar`), on-device privacy chip.
2. A **vault card**: an `FfHeroCard` in a quiet tone (moss or sand; justify) showing what matters: backup
   freshness ("Last backup 3 days ago", or a clear warning with a lime-fill "Back up now"), lock on or off, and
   "All data stays on this device". Status needs icon plus words, never colour only.
3. Grouped sections as `FfGroupedContainer` + `FfRow`s with `FfIconTile` leading icons, in this order: Your data
   (Accounts, Loans, Goals, Subscriptions, Investments, Lending, Needs review), Alerts, Security and privacy,
   Backup and export, Appearance and preferences, About. Tile tone follows the destination's hero tone. Keep every
   existing entry point.
4. Settings pages: `FfSegmentedPill` for exclusive choices, switches for booleans, `FfSheet` for pickers, inline
   help in `text2`, destructive actions last and separated, confirmed with the shared dialog.
5. Split `settings_screen.dart` into small files (hub, detail, rows) as you go; behaviour stays identical.

**Security and lock (F / G)**
Security settings as pattern F. Lock screen as pattern G: calm aurora, a centred squircle mark, PIN dots, 48 dp
keypad targets, biometric button, error text that is not colour only, safe under reduced effects. Replace the static
`StillwaterColors` reads with `context.ff`.

**Backup, restore preview, export (F)**
Backup: a status hero (last backup, size, encrypted yes or no) and the primary ink action. Make the existing "keep
your passphrase" warning prominent, with an icon and words. Restore preview: a clear summary of what will be replaced
before the confirm step, which stays a deliberate two-step. Export: format choices as pills, range via `FfPeriodBar`
or a sheet. **Do not change the wording of destructive confirmations without telling me.**

**Alerts**
Inbox as pattern B (day groups, tiles with status icon plus text, the swipe or menu actions that exist today). Alert
settings sheet as pattern E.

## Rules

- Follow `06-workflow.md` exactly: In flight row (list your exact files), baseline, plan, build, verify with
  before/after screenshots that you actually open and look at, record in `05-screen-status.md` and `CHANGELOG.md`,
  commit only your paths.
- Only shared `Ff*` components and tokens; missing pieces go into the shared system (component + test +
  screenshot + `03-components.md`). No raw colours, sizes, radii or `TextStyle(`.
- Never log financial data, passphrases or PINs. Do not change any field of `AppSettingsEntity`; theme and style
  preferences stay in `themeMode`. No Isar schema or generated-file changes.
- Keep keys, tooltips and semantics that tests rely on, or update the tests in the same commit with the reason.
- Format only the files you touched. Never `dart format lib`.
- Backup, restore and lock flows must still work end to end in widget tests. Do not exercise them on a real device.
  **Backup gate**: before any device install, stop and ask me to create and verify an encrypted backup and keep the
  file and passphrase; wait for my confirmation. Never `adb uninstall`, `pm clear` or `flutter install`;
  `adb install -r` only.
- Another chat may be redesigning **Insights** in parallel. Do not touch `lib/features/analytics/`,
  `lib/features/financial_health/` or the chart widgets, and when you edit `05-screen-status.md` or `CHANGELOG.md`
  change only your own rows, re-reading the file right before you edit it.
- Windows 11, PowerShell and Git Bash.

## Slices (one commit each, update status and changelog in each)

- **B9a** More hub, split of `settings_screen.dart`, settings detail pages.
- **B9b** Security settings and lock screen.
- **B9c** Backup, restore preview, export (UI only).
- **B9d** Alerts inbox and alert settings sheet.

## Start

Do steps 0–1 of `06-workflow.md` only: read, baseline (`flutter analyze`, the tests listed above,
`dart run tool/design_system_audit.dart --shared`), then return a short plan: current map of every screen in scope
(sections, rows, actions, tests that pin texts or keys) → target layout block by block with the component for each →
missing shared pieces → test and copy changes → risks (especially anything near backup, restore or lock) → questions
with your recommendation. Wait for my approval before building.
