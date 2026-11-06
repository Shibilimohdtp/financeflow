# Prompt: Add / edit transaction redesign (DS-B10)

Paste everything below the line into a new Claude Code chat (Opus 5.5).

---

You are the lead product designer, UX designer and Flutter engineer for **FinanceFlow** (Flutter, Riverpod, Isar;
fully local, privacy-first, no backend). The app uses one design system, **Stillwater**, in its **Bloom** visual
language. Home, Money, Accounts and Loans already shipped in Bloom. Your job is to redesign the **add / edit
transaction flow**, the most-used screen in the app.

**This is not a reskin.** Recolouring the existing form with Bloom tokens is explicitly the wrong outcome. The
brief is a real improvement of layout, interaction and speed: a person should be able to log a normal expense in
about five seconds and three taps, and the rare complex cases (loan EMI split, debt, investment, subscription,
transfer) should be clear without cluttering the common case. The result must also look unmistakably like Bloom.

## Read first, in this order (binding)

1. `AGENTS.md` (backup gate, standalone-startup gate, UI section).
2. `docs/design-system/bloom/README.md`, then `01-direction.md`, `02-foundations.md`, `03-components.md`,
   `04-screen-recipes.md` (**pattern E, form / sheet**), `05-screen-status.md`, `06-workflow.md`.
3. `docs/design-system/CHANGELOG.md`: In flight, Decisions, Done rows for DS-B1…B6.
4. Golden screenshots: `docs/design-system/screenshots/ds-b3/bloom_components.png`, `ds-b4/home.png`,
   `ds-b5/money.png`, `ds-b6/b6_loans.png`, `ds-b6/b6_loan_detail.png`.
5. Golden code: `lib/shared/widgets/ff_sheet.dart`, `ff_amount_field` (`grep -rn "class FfAmountField" lib`),
   `ff_chip.dart`, `ff_segmented_pill.dart`, `ff_round_buttons.dart`, `ff_category_tile.dart`, `ff_surfaces.dart`,
   and the transactions list in `lib/features/transactions/transactions_screen.dart` (the entry point and the
   filter sheet that was already moved to `FfSheet`).
6. The flow's own files, all under `lib/features/transactions/`:
   - `add_edit_transaction_screen.dart` (**2,734 lines**; one `State` class with the whole flow)
   - `add_edit_transaction_sheet.dart` (56 lines; a compatibility wrapper whose `show()` pushes the full-screen route)
   - `transaction_form.dart` (282 lines; pure `TransactionFormValues`, `TransactionFormErrors`, validation and the
     built `Transaction`; unit-testable, **keep as the logic core**)
   - `widgets/transaction_pickers.dart` (`AccountTileButton`, `CategoryPickerSheet`, `AccountPickerSheet`)
   - callers: `lib/app/router.dart`, `transactions_screen.dart`, `transaction_detail_screen.dart`,
     `lib/features/ingestion/needs_review_screen.dart`, `lib/features/subscriptions/subscription_detail_screen.dart`
   - their tests (`grep -rln "AddEditTransaction\|TransactionForm" test`), plus
     `docs/features/` for the product rules, and `lib/services/merchant_normalization_service.dart`.

## What exists today (verify, do not trust)

- Despite the name "sheet", it is a **full-screen route** (`AddEditTransactionScreen.push`). `AddEditTransactionSheet`
  only forwards to it, with `headerTitle`, `saveLabel`, `sourceContext` and `onSave` hooks that other flows use
  (editing, needs-review confirmation, subscription payment). **Those entry points and parameters must keep working.**
- The screen has these sections in code: type selector (income / expense / transfer-like), purpose and amount row,
  merchant field with suggestions and focus handling, purpose-specific fields (loan EMI with principal / interest / fee,
  debt, investment, subscription, internal transfer), category section, account section, date section, "more details"
  (notes, tags, payment method), and a sticky action bar.
- Status is **Tokens**: it reads shared tokens, but pickers and the screen still read static `StillwaterColors`
  in places. The layout is the old long scrolling form.
- Pure logic already lives in `transaction_form.dart`. The UI should become a thin layer over it.

## The product and UX goals

Treat these as the design brief, then argue with them in your plan where you have a better idea:

1. **Amount first.** The sheet opens on a large, light, split-style amount (`moneyHero`) with the currency symbol
   and an obvious cursor. The amount is the hero of the sheet, on a tinted surface that follows the type
   (expense rose-ish, income moss, transfer tide; pick from `02-foundations.md`, and never rely on colour alone:
   the type pill, sign and label also say it). Evaluate an **in-sheet numeric keypad with calculator operators**
   versus the system keyboard and recommend one. If you recommend the custom keypad, keys are 48 dp or bigger and it
   works with a screen reader and hidden-amount mode.
2. **Type is one tap and always visible.** A `FfSegmentedPill` (Expense, Income, Transfer) pinned under the grabber.
   Changing it keeps the entered amount and re-applies sensible defaults (as `_changeType` does today).
3. **Smart defaults, minimal typing.**
   - Account: last used for this type, shown as a chip, one tap to change.
   - Date: "Today" chip plus "Yesterday" and a calendar chip, not a date-picker-first flow.
   - Category: a **horizontal row of the most likely categories** (by payee match, then by recency and frequency)
     with a "More" tile that opens the full `CategoryPickerSheet`. Picking a payee suggestion fills category and
     account.
   - Payee: a field with recent payees as `FfChip`s; normalisation via `MerchantNormalizationService` stays.
4. **Progressive disclosure.** The common expense shows: amount, type, payee, category row, account chip, date chip,
   Save. Everything else sits behind clearly labelled rows ("Add note, tags or payment method", "Link to loan",
   "Link to subscription"). Purpose-specific modes (EMI split, debt, investment) appear as a **purpose selector** that
   swaps in a compact, well-explained sub-form, and the amount stays the hero. The user must never face all fields at
   once, and a field must never be hidden if it is required and empty.
5. **Live feedback.** Show a one-line consequence under the form where it helps ("Cash balance after: ₹12,400",
   "This pays EMI #7: ₹18,200 principal + ₹4,100 interest"), computed from existing services, never invented.
   Validation is inline and human (`TransactionFormErrors`), shown beside the field with icon plus text, and the
   Save button explains why it is disabled instead of silently greying out.
6. **Edit mode is different from add mode.** Editing opens at the summary with the changed field in focus, shows
   "Edited" context, a destructive "Delete" at the bottom (shared confirm dialog), and keeps the existing save label hooks.
7. **Keyboard and focus.** Next / Done actions move through fields in a logical order, the sheet scrolls the focused
   field above the keyboard (the merchant-field scroll logic exists and must not regress), Save is always reachable.
   Dismissing with unsaved changes asks first (the `_onWillPop` behaviour exists).
8. **Speed.** Open in one frame with no spinner for the common path; no heavy blur or grain inside the sheet (effects
   belong to heroes and the dock only). Any provider that loads lists should already be warm or show a skeleton.
9. **Presentation.** Decide, with reasoning, between (a) a **tall modal bottom sheet** (`FfSheet`, drag to dismiss,
   keyboard-aware, the amount area is a gradient-tinted `FfHeroCard`-style header) and (b) the current full-screen
   route restyled. The product calls this the "add transaction bottom sheet", so default to (a) unless you find a
   real problem (for example the EMI sub-form needs the whole screen). Say what you decided and why. Either way every
   caller keeps working through `AddEditTransactionSheet.show`.

## Hard constraints

- Behaviour and data are unchanged: the same `Transaction` objects are produced for the same inputs. No Isar schema,
  generated-file or provider-bootstrap changes (that triggers the backup gate; stop and ask me). Never log financial data.
- All accessibility rules in `01-direction.md`: 48 dp targets, contrast ratchet green, no colour-only status, 2×
  text without overflow (test it), screen-reader labels and a sensible focus order, amounts hidden mode respected,
  reduced-effects safe, light and dark.
- Amounts via `FfAmountText` / `FfAmountField` only. Only shared `Ff*` components and tokens; missing pieces become
  shared components (component + test + screenshot + `03-components.md`), never one-off code. No raw colours, sizes,
  radii or `TextStyle(`. Remove every static `StillwaterColors` read in this flow.
- Keep keys, tooltips and semantics that tests rely on, or update those tests in the same commit with the reason.
- Format only files you touched. Never `dart format lib`. Commit only your paths.
- Windows 11, PowerShell and Git Bash.

## Process: the file is too big to redesign in place, so refactor first

Slices, one commit each, each updating `05-screen-status.md` and `CHANGELOG.md`:

- **B10a: behaviour-preserving split.** Break `add_edit_transaction_screen.dart` into a state/controller, section
  widgets and purpose sub-forms in a new folder (for example `lib/features/transactions/form/`), with **no visual
  change** and all existing tests green. Move decisions into `transaction_form.dart` or small pure classes where they
  can be unit-tested. Add tests for the paths that are only reachable through UI today.
- **B10b: shared pieces.** Whatever the design needs and the system lacks (amount hero with type tint, calculator
  keypad if chosen, suggestion-chip row, summary row, consequence line). Component sheet screenshot updated.
- **B10c: the common path.** New expense / income / transfer layout, defaults, suggestions, inline validation,
  keyboard handling, presentation (sheet or route).
- **B10d: complex purposes and edit mode.** Loan EMI split, debt, investment, subscription link, more-details rows,
  delete, unsaved-changes guard, entry points (needs-review, subscription payment, detail edit).
- **B10e: polish.** Pickers (`CategoryPickerSheet`, `AccountPickerSheet`, `AccountTileButton`) in Bloom, motion,
  empty states (no accounts, no categories), states matrix screenshots.

## Verification (this is a UX task, so prove it)

- Before / after screenshots with `tool/screenshots/compare.py`, light and dark, for: empty add expense, filled
  expense with suggestions, income, transfer, EMI split, edit mode, validation errors, keyboard open (use a
  keyboard-inset test), 2× text, hidden amounts. **Open the PNGs and look at them**; fix what you see.
- A written **tap count and field count comparison** for the five most common tasks (expense with known payee,
  expense new payee, income, transfer, EMI payment): before vs after, in the plan and again in the final report.
- Widget tests for the new interactions (type switch keeps amount, suggestion fills category and account, disabled
  Save explains why, unsaved-changes guard, every external caller). Full suite green, analyze clean, audit numbers
  not up.
- Say plainly what you could not verify (device feel, keyboard on real hardware, performance). Do not install on a
  device without the backup gate: ask me to create and verify an encrypted backup and keep the file and passphrase,
  wait for my confirmation, and use `adb install -r` only (never `adb uninstall`, `pm clear` or `flutter install`).

## Start

Do steps 0–1 of `06-workflow.md` only. Read, take the baseline (`flutter analyze`, the transaction tests,
`dart run tool/design_system_audit.dart --shared`, current screenshots of the flow), then return:

1. A map of the current flow: sections, fields, purposes, entry points, state, tests that pin texts or keys, and the
   tap count for the five common tasks.
2. Your proposed layout block by block (top to bottom) for the common path and for each purpose, with the shared
   component for each block, and a sketch or short description of the open, keyboard-open and error states.
3. Your recommendations on the open decisions: sheet vs full-screen, custom keypad vs system keyboard, which
   suggestions are shown, what the consequence line says.
4. Missing shared pieces, test and copy changes, risks, and questions.

Wait for my approval before building anything.
