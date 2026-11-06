# Prompt: Settings and More, second pass: a creative redesign (DS-B16)

Paste everything below the line into a new Claude Code chat (Opus 5.5).

---

You are the lead product designer, UX designer and Flutter engineer for **FinanceFlow** (Flutter, Riverpod, Isar;
fully local, privacy-first, no backend). The app uses one design system, **Stillwater**, in its **Bloom** visual
language. Most screens are now in Bloom. Your job is to redesign **the whole settings surface**: the More hub, the
App Settings page and everything nested under it, **and every bottom sheet and dialog in it**.

## Why a second pass

Slice DS-B9 already moved these screens to "Bloom" status (pattern F, a sand vault card, grouped `FfRow`s on the
aurora). It was a faithful application of the recipe, and it is still, honestly, **a list of rows with new colours**:
the More hub is a long menu that mixes feature modules (Accounts, Loans, Goals…) with preferences; "App Settings" is one
tall page of toggles; the theme and currency pickers are plain row sheets; Notification preferences, Security and
Backup are forms. The owner's verdict on this kind of result is: **a filter slapped on top is not acceptable.** Treat the
B9 layouts as the *baseline to beat*, not as a design to preserve. You are allowed, and expected, to change the
information architecture, the layouts and the interactions, as long as every existing setting, entry point and
behaviour is still reachable and still works.

The design question to answer: *"How does a person find, understand, trust and change a setting in a few seconds,
and feel in control of a privacy-first app?"* Make the settings area feel like the calm control room of the product,
with our own signature, using Bloom's vocabulary (aurora canvas, hero tones, squircles, light oversized numerals, ink
pills plus one lime accent, ring / dot-matrix / range-band viz, glass only where allowed, the floating dock). Never
copy the reference imagery.

## Read first, in this order (binding)

1. `AGENTS.md` (backup gate, standalone-startup gate, UI section).
2. `docs/design-system/bloom/README.md`, then `01-direction.md`, `02-foundations.md`, **`03-components.md` in full**
   (many shared components were added by slices DS-B7 to DS-B15: reuse before building), `04-screen-recipes.md`
   (patterns F and G, and E for sheets), `05-screen-status.md`, `06-workflow.md`.
3. `docs/design-system/CHANGELOG.md`: In flight, Decisions (read **all** decisions that mention More, Settings,
   `FfPageHeader`, hero tones, `FfButtonVariant.spark`, the debug gallery, the stored theme and `themeMode`), and the
   DS-B9a to B9d and DS-B13 Done rows.
4. Look at the screenshots of what B9 produced (`docs/design-system/screenshots/ds-b9*`, `ds-b13`) and at the best
   current examples: `ds-b6/*`, `ds-b11`, and the newest landed slices. Judge the B9 result critically next to them.
5. The code, all of it:
   - `lib/features/settings/` : `more_screen.dart` (309, the hub; `MoreVaultCard`), `settings_detail_screen.dart`
     (621, "App Settings": appearance, alerts and notifications, transaction ingestion, data reset, the theme and
     currency sheets), `settings_controller.dart`, `branding_preview_screen.dart` (leave alone), `settings_screen.dart`
     (a re-export shim)
   - `lib/features/security/` : `security_settings_screen.dart` (305), `lock_screen.dart` (308), and wherever PIN
     setup and biometric prompts live (`grep -rn "PIN\|pin" lib/features/security`)
   - `lib/features/backup/` : `backup_screen.dart` (484), `restore_preview_screen.dart` (385), `backup_controller.dart`
   - `lib/features/export/` : `export_screen.dart` (347), `export_controller.dart`
   - `lib/features/alerts/` : `alert_settings_sheet.dart` (385) and `alerts_inbox_screen.dart` (667, already redesigned
     as a hero + dismissible rows in B9d; touch only if the redesigned IA needs it)
   - `lib/features/ingestion/permissions/` : `sms_permission_screen.dart`, `notification_permission_screen.dart`,
     and `csv_import_screen.dart` (reached from More)
   - `lib/database/schemas/app_settings_entity.dart` (**read-only reference**: the full list of persisted settings;
     there are many, including some such as the Gemini flags that have no UI and **must not get one**),
     `lib/repositories` settings repo, `lib/theme/` (how `themeMode`, `AppThemePreference` and `FfEffects` are applied)
   - tests: `grep -rln "SettingsDetailScreen\|MoreScreen\|SecuritySettings\|LockScreen\|BackupScreen\|RestorePreview\|ExportScreen\|AlertSettings\|ingestion_settings" test`

## Coordination (check first)

- `git status`, `git log --oneline -10`, and the CHANGELOG **In flight** table. If another row touches a file you need,
  stop and ask me.
- **Do not edit** the feature screens that More links to (accounts, loans, goals, subscriptions, investments,
  lending, needs review, financial health, budgets, analytics, dashboard, transactions). You only navigate to them.
- Add new shared components to `lib/shared/widgets/` with a test, a component-sheet screenshot and `03-components.md`.
  Extend existing shared ones only compatibly, then run the full suite.
- In `05-screen-status.md` and `CHANGELOG.md` change only your own rows, re-reading each file right before editing.
  Commit only your own paths.

## Overlap with DS-B17

App Lock / Security / PIN / lock screen, Export, and CSV import also have their own prompt
(`17-lock-export-import-redesign.md`, DS-B17). Check the CHANGELOG In flight table. If DS-B17 is running or has
landed, **skip B16f, the Export part of B16g and any CSV import work**, keep only their entry rows working, and design
the Settings hub around them (status cards and links). If DS-B17 has not started, ask me which chat owns them before
touching those files.

## What exists today (verify, do not trust)

- **More hub**: vault card (backup freshness, lock state, "data stays on this device"), then sections "Your data"
  (8 rows), "Alerts", "Security and privacy", "Backup and export", "Appearance and preferences" (one row: App
  Settings). Rows have long subtitles.
- **App Settings**: Appearance (theme, "Ledger View" dense mode, currency), Alerts and notifications (master switch,
  preferences link, five category toggles, backup reminder), Transaction ingestion (notification detection, SMS
  detection, a disabled email row), Data reset (wipe all data with a confirm dialog), About-type rows, a long-press
  on the version row for the debug gallery (debug only).
- **Sheets and dialogs**: theme chooser, currency chooser, alert settings, PIN and lock flows, backup and restore
  passphrase steps, export options, wipe confirmation.
- Settings that are related live in unrelated places (alerts are in three places; ingestion is under App Settings
  while its permission screens are elsewhere; privacy is split between the vault card, Security and the hero).

## Design directions (starting points; improve them, justify every change)

### 1. Information architecture first

Propose and defend a better structure before drawing anything. A strong candidate:

- **Separate "modules" from "settings".** More today mixes navigation to features with preferences. Option: **More
  becomes the launcher** (a grid or carousel of squircle module tiles with domain tone and a live count or status
  such as "3 to review", "2 renew soon", never fake data) and **Settings becomes its own page** reached by a clear
  entry on More (and from the header), organised by intent, not by implementation.
- **Intent-based groups** such as *Look and feel*, *Privacy and security*, *Alerts*, *Automatic detection*,
  *Data and backup*, *About*. Each group's page opens with a **status hero or summary** (not a list).
- **Settings search**: a search pill at the top of Settings that finds any setting by name or by plain words
  ("dark", "pin", "sms", "reminder", "currency"), shows the result with its group, and jumps to it (scroll and
  highlight). It must be fully local and also works for screen-reader users. This is likely the single biggest UX win:
  evaluate it seriously and say what it costs.
- **Quick settings strip** on the hub: 4 to 6 round or squircle toggle tiles for the things people flip most (hide
  amounts, app lock, dark or light, alerts master, SMS detection), each with an icon, a word and an on/off state that is
  not colour-only. Long-press or tap-through opens the full control.
- Keep the vault card idea (backup freshness, lock, local-only) but decide whether it becomes the hero of a
  **"Privacy and data" page** instead, since a hub with a hero plus a quick strip plus a module grid risks being heavy.
  Decide what the hub's first screen contains on a 360×800 dp phone and justify it.

### 2. Appearance: show, don't list

- **Theme chooser as live preview cards**: Light / Dark / System as three squircle cards, each rendering a tiny
  miniature of Home (aurora, hero, a few rows) in that palette, selected state by ink border plus check. Applying is
  instant. It reads `AppThemePreference` and writes the existing `themeMode` string; **no schema change**.
- **Density**: "Ledger view" renamed in plain words with a before/after mini illustration of comfortable vs compact
  rows (the toggle maps to the existing dense-mode flag).
- **Currency**: a searchable sheet with the common ones pinned first and a one-line honest note that it changes
  display only and does not convert (keep today's wording intent).
- **Palettes, pure black and reduced effects are DS-8, not this slice.** If you think the theme area should be
  designed *ready* for them (a slot for more palettes, a "Reduce effects" switch), design the slot but do not ship
  controls that have no persisted field. If a persisted field is needed, **stop and ask me** (no schema change without
  approval and the backup gate).

### 3. Alerts and notifications: understand before toggling

- A **status hero**: master switch state, how many categories are on, and whether OS notification permission is
  granted, with the fix action one tap away.
- Categories as a **compact matrix** of rows × two channels (in-app alert, system notification), or a segmented control
  per category, so the person sees everything at once instead of five stacked switches.
- **Lock-screen privacy with a live example**: a small rendered notification that shows what appears with
  "hide sensitive content" on versus off.
- The alert settings sheet is merged into this design (one place, not three).

### 4. Automatic detection (SMS, notifications, imports)

- A page explaining, in plain words and with a simple diagram built from shared pieces, **what is read, where it
  stays (on this device), and what is never done**. Each source (Notification, SMS, Email-coming-soon, CSV import) is
  a **status card**: state with icon and words, permission status, last detection time if the data exists, and the
  primary action (Allow, Open system settings, Pause). The permission screens (`sms_permission_screen`,
  `notification_permission_screen`) are redesigned as pattern G, calm, reassuring, with a clear "why we ask".
- The disabled email row stays visibly "coming soon", never looks broken.

### 5. Security and privacy: a protection checklist

- **Protection ring**: "4 of 5 protections on" as an `FfProgressRing` with a plain list (app lock, biometrics,
  hide amounts, screenshot protection, hide sensitive notifications), each item an actionable row. Calm, never
  alarmist, no scare copy.
- **App lock setup as a guided sheet**: step 1 choose PIN, 2 confirm, 3 optional biometrics, with PIN dots and a 48 dp
  keypad shared with the lock screen. Auto-lock timeout as `FfSegmentedPill` options.
- **Lock screen** (pattern G) is polished to match: squircle mark, dots, keypad, biometric button, errors that are not
  colour-only, reduced-effects safe. Behaviour unchanged.

### 6. Backup, restore, export, reset: safe by design

All of these are **backup-gated flows: change UI only, never behaviour, file format, encryption, passphrase handling
or schema.**
- **Backup**: a freshness ring hero ("Last backup 3 days ago", encrypted yes/no, size), the primary ink action, and the
  existing "keep your passphrase" warning made unmissable with icon plus words; steps shown as a short progress
  checklist while it runs.
- **Restore preview**: a clear *what will happen* summary (counts of accounts, transactions, loans… that will be
  replaced), a two-step confirm, and a visible "your current data will be replaced" line. Wording of destructive
  confirmations stays unless I approve a change.
- **Export**: format cards (CSV, JSON, spreadsheet, report) each with one line on what it contains, a range chip row,
  and a result sheet with the saved path and share action.
- **Data reset**: moved into a clearly separate **Danger zone** at the bottom of the Data page, the confirmation sheet
  lists exactly what will be erased and requires a deliberate step (hold to confirm or type a word; propose one) while
  keeping today's actual erase behaviour. Offer "Back up first" as the primary path inside the sheet.

### 7. About

A calm about card (version, build, "stored only on this device", licences link if it exists, the debug gallery
long-press retained for debug builds). No marketing.

## Hard constraints

- **Behaviour and data unchanged.** Every setting that exists today stays reachable and keeps its persisted key and
  semantics. **No Isar schema, generated-file or provider-bootstrap changes** (backup gate: stop and ask me). Never log
  financial data, passphrases, PINs or settings contents. No network, no analytics.
- **Backup gate for devices**: never install on a real device without me creating and verifying an encrypted
  FinanceFlow backup and confirming; `adb install -r` only; never `adb uninstall`, `pm clear` or `flutter install`.
  Never exercise backup, restore, wipe or lock flows on a device from this task.
- Only shared `Ff*` components and tokens. No raw colours, sizes, radii, durations, `TextStyle(`, `Colors.*`. Remove
  every static `StillwaterColors` read. Replace private `_SectionLabel`-style widgets with the shared section heading.
- Accessibility: 48 dp targets, contrast ratchet green, no colour-only state (every on/off, granted/denied, set/not
  set carries icon or words), semantics for rings, tiles, the settings search and the keypad, logical focus order,
  2× text without overflow (test it), amounts-hidden mode, reduced effects, light and dark.
- Performance: no blur or grain beyond the hero rules; theme previews are static painted widgets, not live copies of
  the app; no continuous animation; settings search is an in-memory filter over a const index.
- Keep keys, tooltips and semantics that tests rely on, or update the tests in the same commit and say why. Keep the
  existing entry points working (`onOpenSettings`, router tabs, deep links from alerts and Home).
- Split any file over ~500 lines. Format only files you touched; never `dart format lib`. Windows 11, PowerShell and
  Git Bash.

## Slices (one commit each; each updates `05-screen-status.md` and `CHANGELOG.md`)

- **B16a Settings index and shared pieces**: the const settings index (id, title, plain-words keywords, group,
  destination), search, quick toggle tile, status hero, theme preview card, protection ring row, status card, PIN
  keypad if shared; tests, component-sheet screenshot, `03-components.md`.
- **B16b IA and hub**: More as launcher, Settings page and its group pages, search, quick strip.
- **B16c Appearance** (theme cards, density, currency sheet).
- **B16d Alerts and notifications** (+ the alert settings sheet).
- **B16e Automatic detection** and the two permission screens.
- **B16f Security, PIN setup sheets, lock screen.**
- **B16g Backup, restore preview, export, Danger zone** (UI only).
- **B16h About, polish, states matrix, docs.**

**Pause for my review after B16b and after B16f** with screenshots.

## Verification

- Before / after screenshots with `tool/screenshots/compare.py`, light and dark, for every screen, sheet and dialog in
  these states: first screen of the hub on 360×800, search with results and with no results, each toggle on and off,
  permissions granted and denied, lock set and not set, backup fresh / stale / never, restore preview, export,
  Danger zone confirm, keyboard open, 2× text, hidden amounts, reduced effects. **Open the PNGs and look at them**;
  compare with the best current screens and fix anything that still reads as "rows with new colours".
- Effort comparison before vs after: find and change the theme, turn off an alert category, set up app lock, make a
  backup, export a CSV, find "SMS" from nothing. Report taps and the search shortcut.
- Widget tests for each new interaction (search matches words and jumps, quick toggles, theme card applies, category
  matrix, guided PIN setup, protection ring count, danger confirm). Full suite green, `flutter analyze` clean,
  `dart run tool/design_system_audit.dart --shared` numbers not up, and the startup-related tests
  (`test/widget_test.dart`, `test/integration/isar_startup_test.dart`) if you touch anything near bootstrap.
- Say plainly what you could not verify (device feel, permissions on hardware, biometrics, gestures, grain).

## Start

Do steps 0–1 of `06-workflow.md` only. Read everything above, run the coordination checks, take the baseline
(`flutter analyze`, the tests listed, the audit, current screenshots of every screen and sheet), then return:

1. A map of the whole settings surface today: every screen, sheet and dialog, every persisted setting and where it
   appears, entry points, tests that pin texts or keys, and your honest critique of the B9 result.
2. Your proposed information architecture (tree of pages and groups), with the recommendation on the launcher/settings
   split, search and quick settings, and the first screen of the hub on a 360×800 phone.
3. Top-to-bottom layouts for every screen and sheet with the shared component per block, the creative idea that gives
   each its character, and their states. Offer an alternative for your riskiest idea (search, the launcher split, or
   hold-to-confirm reset) and recommend one.
4. Shared components to add, anything that needs a persisted field or copy change (needs my approval), risks near
   backup / restore / lock, and questions.

Wait for my approval before building anything.
