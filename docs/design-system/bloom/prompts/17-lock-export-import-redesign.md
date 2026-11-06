# Prompt: App Lock & Biometrics, Export data and Import CSV statement redesign (DS-B17)

Paste everything below the line into a new Claude Code chat (Opus 5.5).

---

You are the lead product designer, UX designer and Flutter engineer for **FinanceFlow** (Flutter, Riverpod, Isar;
fully local, privacy-first, no backend). The app uses one design system, **Stillwater**, in its **Bloom** visual
language. Most screens are now in Bloom. Your job is to redesign three connected features **end to end, every screen,
sheet, dialog and widget in them**:

1. **App Lock & Biometrics**: the Security settings screen, the PIN setup / change / remove flows (today a bottom
   sheet with two text fields), the biometric opt-in, and the **lock screen** itself.
2. **Export data**: the export screen, its options, the generate step and the result.
3. **Import CSV statement**: choosing a file or pasting text, column mapping, the review session of parsed rows,
   committing, and undo.

**This must be a creative redesign, not a re-skin.** These screens were moved to "Bloom" or "Tokens" status by earlier
slices (a recipe-F settings page, a form with segmented pills, a dropdown-heavy import). They have the right colours and
fonts, and they are still **forms**: stacked fields, dropdowns and a button. A filter slapped on top is rejected.
Redesign each flow around the person's real goal and fear:

- *Lock:* "Am I protected, and can I set it up or change it in seconds without ever locking myself out?"
- *Export:* "What exactly will leave this app, in what shape, and where does it go?"
- *Import:* "Will my bank statement land correctly, will it duplicate what I already have, and can I take it back?"

Use Bloom's vocabulary (aurora canvas, hero tones, squircles, light oversized numerals, ink pills with one lime
accent, ring / dot-matrix / range-band viz, glass only where allowed) with our own signature, never copied from the
reference imagery.

## Read first, in this order (binding)

1. `AGENTS.md` (backup gate, standalone-startup gate, UI section).
2. `docs/design-system/bloom/README.md`, then `01-direction.md`, `02-foundations.md`, **`03-components.md` in full**
   (many shared components were added by slices DS-B7 to DS-B16: reuse before building), `04-screen-recipes.md`
   (patterns E, F, G), `05-screen-status.md`, `06-workflow.md`.
3. `docs/design-system/CHANGELOG.md`: In flight, Decisions (all that mention security, lock, backup, export, sheets,
   `FfPageHeader`, `FfButtonVariant.spark`, hero tones), and the Done rows for DS-B9b, B9c, B11, B13, B14.
4. Screenshots: what B9 produced for Security and Lock (`docs/design-system/screenshots/ds-b9*`), and the best
   current creation flows (`ds-b11`, the newest folders). Judge the current screens critically next to them.
5. The code, all of it:
   - **Lock**: `lib/features/security/security_settings_screen.dart` (305; `_showSetPinSheet` builds the PIN sheet
     inline with `TextEditingController`s, a `StatefulBuilder`, "Set Security PIN", 4 to 6 digits, confirm; remove-PIN
     confirm dialog), `lock_screen.dart` (308; the keypad `_buildPadKey`, `_buildBiometricButton`, `_buildDeleteKey`),
     the security service behind it (`grep -rn "setPin\|securityService\|SecurityService" lib`), how the app decides to
     show the lock (`lib/app/app.dart`, `router.dart`), and the settings flags `isPinEnabled`, `isBiometricEnabled`,
     `isScreenshotProtectionEnabled`, `isPrivacyBlurEnabled` in `lib/database/schemas/app_settings_entity.dart`
     (**read-only**). Tests: `security_screens_test.dart`, `security_privacy_audit_test.dart`.
   - **Export**: `lib/features/export/export_screen.dart` (347; `ExportFormat` csv / json, `ExportScope` all
     transactions / date range, generate and share steps), `export_controller.dart`, `lib/services/export_service.dart`
     (399). Test: `export_service_test.dart`.
   - **Import**: `lib/features/ingestion/csv_import_screen.dart` (**886 lines**: initial file selection view, paste
     box, sample data, the mapping sheet with one dropdown row per column, the review session view, parsed row widgets,
     `_SummaryPill`, bottom commit bar), `csv_import_controller.dart` (300; `CsvImportState` with headers, sample rows,
     `CsvColumnMapping`, `ImportReviewSession`, progress step, `lastCommittedIds`), the parser, mapper and import
     services (`grep -rln "CsvColumnMapping\|ImportReviewSession" lib`). Tests: `csv_import_widget_test.dart`,
     `csv_column_mapper_test.dart`, `csv_parser_test.dart`.
   - Entry points: More hub and settings (`lib/features/settings/`), the first-run flow, Needs review, and wherever
     "Import" or "Export" is linked.

## Coordination (check first)

- `git status`, `git log --oneline -10`, and the CHANGELOG **In flight** table. **The Settings redesign (DS-B16,
  `prompts/16-settings-redesign.md`) also lists Security / PIN / lock (its slice B16f), Export (inside B16g) and the CSV
  import screen.** If a DS-B16 row is in flight or those slices have landed, stop and ask me which chat owns these
  files. Default: this task (DS-B17) owns them, and DS-B16 skips B16f, the Export part of B16g and the CSV import
  screen. Record that in `CHANGELOG.md` In flight and Decisions when you start.
- **Do not edit**: the More hub and settings pages other than the single entry rows you must keep working, dashboard,
  budgets, transactions list, Needs review, and the backup/restore screens. You only navigate to them.
- Add shared components to `lib/shared/widgets/` with a test, component-sheet screenshot and `03-components.md`. Extend
  existing shared ones only compatibly, then run the full suite.
- In `05-screen-status.md` and `CHANGELOG.md` change only your own rows, re-reading each file right before editing.
  Commit only your own paths.

## What exists today (verify, do not trust)

- **Security settings**: toggles and rows for PIN, biometrics, screenshot protection and similar; "Set Security PIN"
  opens a sheet with a "4-6 digit PIN" text field and a "Confirm PIN" field; removal is a confirm dialog. The hardware
  keystore note is a subtitle.
- **Lock screen**: calm aurora, squircle mark, PIN dots and a keypad (Bloom pattern G since B9b), biometric button.
- **Export**: a format pill (CSV or JSON), a scope list (all transactions or a date range), a primary
  "Generate & Save Export" button, and after generation a "Share / Save to Downloads" action.
- **Import**: pick a file, paste, or load sample data; a mapping sheet with a dropdown row per field (date, merchant,
  debit, credit, …); a review list of parsed transactions with a summary and a bottom commit bar; undo of the last import
  exists in state.

## Design directions (starting points; improve them, justify every change)

### 1. App Lock & Biometrics: a protection hub and a guided setup

- **Hub page (pattern F, creative):** a hero with the lock state as a ring or a lock mark plus words ("Locked with PIN
  and fingerprint", "Not protected"), then plain rows for each control grouped by what it protects: *Opening the app*
  (PIN, biometrics, when to lock if such a setting exists), *Screen privacy* (hide amounts by default, screenshot
  protection, app-switcher blur) with a small illustration of what each does built from shared pieces, and a
  **"Lock now"** test action. Never alarmist copy, never colour-only state.
- **PIN setup, change and remove as one guided flow** (a tall sheet or full-screen pattern G flow, your call): step 1
  enter PIN, step 2 confirm, step 3 offer biometrics with an honest explanation of what is stored where. **Replace the two
  text fields with PIN dots and a 48 dp keypad**, the same shared keypad the lock screen uses (extract it as a shared
  component with tests, used by both). Wrong confirmation shows a clear message, dots reset, no colour-only error,
  haptics. Changing a PIN asks for the current one only if the current behaviour does. Removing a PIN keeps the existing
  confirm wording unless I approve a change. Minimum length rules stay exactly as today (4 to 6 digits).
- **Recovery honesty:** state plainly, from what the code actually does, what happens if the PIN is forgotten. If the
  answer is "nothing can recover it", say so calmly before the person finishes setup. Do not invent a recovery feature.
- **Lock screen polish (pattern G):** biometric prompt on open if enabled with a visible fallback to PIN, a clear
  failed-attempt message, any existing lockout behaviour surfaced in words, nothing financial visible, safe at 2× text and
  in landscape, reduced-effects safe. Behaviour unchanged.

### 2. Export: an "export studio" that shows what leaves the app

- **Choose what**: scope as large **selectable cards** with icon and one-line explanation instead of two list rows; the
  date range as **range chips first** (This month, Last 3 months, This financial year, All time, Custom) with the
  picker only for Custom. Use only the scopes and formats the code supports today; do not add data kinds.
- **Choose how**: format as two **format cards** (CSV for spreadsheets, JSON for raw data), each with a tiny schematic
  of what the file looks like (columns / keys drawn from shared pieces, not real user data) and who it is for.
- **A live summary before generating**: "1,248 transactions · 1 Apr 2025 to 6 Nov 2026 · about 210 KB" computed locally
  and cheaply from existing data (if a size estimate is not cheap or reliable, show the count and range only, never a
  made-up size). Hidden-amounts mode respected.
- **Be honest about privacy:** a calm, visible note that export files are **not encrypted** and contain readable
  financial data, with a link to the encrypted backup if the person wants a safe copy. This is the signature moment of
  the screen: trust through clarity.
- **Generating and result:** a short progress checklist (collecting, formatting, saving), then a result sheet with
  file name, size, location, primary ink **Share**, secondary **Save to Downloads** (the two actions that exist), and
  "Done". Errors are human and recoverable with a retry.

### 3. Import CSV statement: a guided three-step flow

- **Stepper at the top** (shared `FfPillBar` or step dots): *Choose*, *Match columns*, *Review*. The person always knows
  where they are and can go back without losing work.
- **Step 1, Choose:** three large source cards (Pick a file, Paste text, Try a sample) with one line on each, a short
  "works with most bank and card statements" tip and a privacy line ("The file is read on this device and never
  uploaded"). Selecting a file shows its name, row count and detected delimiter before moving on.
- **Step 2, Match columns, as a preview table instead of five dropdowns:** render the first 3 to 5 rows as a compact
  table with the header names as chips. Auto-detected matches are labelled ("Date, detected") with icon plus words;
  tapping a header chip opens a small sheet to reassign (Date, Merchant, Debit, Credit, Ignore). Show a live
  **parsed preview** line per sample row ("12 Nov · Swiggy · -₹420") so the effect of the mapping is visible before
  committing. Warn inline when a required field is unmapped.
- **Step 3, Review:** a summary hero ("84 found") with an `FfAllocationBand` or ring of *Ready*, *Possible duplicates*,
  *Skipped*, using whatever categories the session already computes. Rows grouped under those headings with per-row
  include/exclude, bulk include/exclude, a visible duplicate cue (icon plus words, never colour only), and category
  and account assignment as chips. A commit bar with a **consequence line** ("Adds 84 transactions to HDFC Salary").
- **After commit:** a success state with counts and an **Undo import** action (uses `lastCommittedIds`) and
  "Review in Money". The undo window and behaviour stay exactly as today.
- **Large files and errors:** progress that says what step it is on, a graceful message for an unreadable or empty
  file with a way to pick another, and no jank on thousands of rows (lazy lists).

## Hard constraints

- **Behaviour and data unchanged.** The same PIN rules and storage (hardware keystore through the existing service),
  the same biometric API use, the same export file contents and formats, the same CSV parsing, mapping, de-duplication,
  commit and undo logic. **No Isar schema, generated-file or provider-bootstrap changes** (backup gate: stop and ask me).
  If a new persisted field seems needed, stop and ask. Never log or print PINs, statements, merchants, amounts or file
  contents; `security_privacy_audit_test.dart` must stay green and you should extend it for new code paths.
- **Backup gate for devices:** never install on a real device without me creating and verifying an encrypted FinanceFlow
  backup and confirming; `adb install -r` only; never `adb uninstall`, `pm clear` or `flutter install`. Do not exercise
  the lock, PIN or biometric flows on a device from this task, and do not import or export real data.
- **Standalone-startup gate:** the lock screen is shown from app startup. If you touch anything that runs before the
  first frame (app.dart, router, providers used by the lock), follow the full gate in `AGENTS.md`: keep `main()`
  synchronous, run `test/widget_test.dart` and `test/integration/isar_startup_test.dart`, and the two APK builds.
- Only shared `Ff*` components and tokens. No raw colours, sizes, radii, durations, `TextStyle(`, `Colors.*`. Remove
  every static `StillwaterColors` read. Replace private `_SectionLabel`-style widgets with the shared section heading.
- Accessibility: 48 dp targets (the keypad especially), contrast ratchet green, no colour-only state (set / not set,
  granted / denied, match / unmapped, duplicate / ready), semantics for the keypad, PIN dots (announce count of digits
  entered, never the digits), the step flow, the parsed preview table and the summary, logical focus order, 2× text
  without overflow (test it), amounts-hidden mode, reduced effects, light and dark.
- Performance: no blur or grain beyond the hero rules, no continuous animation, review lists are lazy, the mapping
  preview only renders a handful of rows.
- Keep keys, tooltips and semantics that tests rely on, or update the tests in the same commit and say why.
- Split files over ~500 lines (`csv_import_screen.dart` at 886 first, as a behaviour-preserving commit). Format only
  files you touched; never `dart format lib`. Windows 11, PowerShell and Git Bash.

## Slices (one commit each; each updates `05-screen-status.md` and `CHANGELOG.md`)

- **B17a Split and shared pieces:** behaviour-preserving split of the CSV import screen with tests for what is only
  reachable through the UI today; shared PIN dots + keypad component (used by lock and setup), step indicator, source
  card, format card, summary hero if missing; tests, component-sheet screenshot, `03-components.md`.
- **B17b App Lock hub + guided PIN flow** (set, change, remove, biometric opt-in).
- **B17c Lock screen** polish on the shared keypad.
- **B17d Export studio** (choose, summary, privacy note, progress, result).
- **B17e Import CSV: choose + match columns.**
- **B17f Import CSV: review, commit, undo, errors.**
- **B17g Polish:** states matrix, consistency pass, docs.

**Pause for my review after B17b and after B17e** with screenshots.

## Verification

- Before / after screenshots with `tool/screenshots/compare.py`, light and dark, for every screen, sheet and dialog in
  these states: lock off / PIN only / PIN and biometric, setup steps including mismatch error, remove confirm, lock
  screen with and without biometrics and after a failed attempt, export with each scope and format, export result and
  error, import at each step with a clean file / duplicates / unmapped required column / empty file / huge file,
  success with undo, keyboard open, 2× text, hidden amounts, reduced effects. **Open the PNGs and look at them**;
  compare with the best current screens and fix anything that still reads as a form with new colours.
- Effort comparison before vs after: set a PIN, enable biometrics, change a PIN, export last 3 months as CSV, import a
  typical statement with auto-detected columns, fix one wrongly mapped column, undo an import. Report taps and steps.
- Widget tests for each new interaction (keypad entry and mismatch, the guided steps, range chips, format cards, the
  mapping preview and reassignment sheet, duplicate handling, commit and undo, the privacy note). Full suite green,
  `flutter analyze` clean, `dart run tool/design_system_audit.dart --shared` numbers not up.
- Say plainly what you could not verify (device keystore and biometrics, real file pickers and share sheets, gestures,
  large-file performance, grain).

## Start

Do steps 0–1 of `06-workflow.md` only. Read everything above, run the coordination checks, take the baseline
(`flutter analyze`, the tests listed, the audit, current screenshots of every screen, sheet and dialog), then return:

1. A map of the three features today: screens, sheets, dialogs, widgets, state and services behind them, entry points,
   tests that pin texts or keys, what the code actually does for forgotten PIN, lockout, change PIN, export contents,
   duplicate detection and undo, and the tap counts for the main tasks.
2. Your target design for each flow: top-to-bottom layouts, the shared component per block, the creative idea that
   gives each its character, and the states. Offer an alternative for your riskiest idea (the shared PIN keypad flow, the
   mapping preview table, or the export live summary) and recommend one.
3. Shared components to add, anything that needs a persisted field or a wording change (needs my approval), risks near
   lock and startup, and questions.

Wait for my approval before building anything.
