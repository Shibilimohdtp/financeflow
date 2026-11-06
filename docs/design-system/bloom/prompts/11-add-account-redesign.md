# Prompt: Add / edit financial account sheet redesign (DS-B11)

Paste everything below the line into a new Claude Code chat (Opus 5.5).

---

You are the lead product designer, UX designer and Flutter engineer for **FinanceFlow** (Flutter, Riverpod, Isar;
fully local, privacy-first, no backend). The app uses one design system, **Stillwater**, in its **Bloom** visual
language. Home, Money, Accounts and Loans already shipped in Bloom. Your job is to redesign the **Add / Edit
Financial Account bottom sheet** that opens from the Financial Accounts screen.

**This is not a reskin.** The Accounts screen above it is already Bloom (moss hero, account cards), and this sheet is
the one part that still looks like a generic form: a dropdown, four stacked text fields and a button. The brief is a
real improvement of layout, interaction and feel. Creating an account should take a few seconds, feel like creating
the card you will then see on Home, and explain itself. It must also be unmistakably Bloom.

## Read first, in this order (binding)

1. `AGENTS.md` (backup gate, standalone-startup gate, UI section).
2. `docs/design-system/bloom/README.md`, then `01-direction.md`, `02-foundations.md`, `03-components.md`,
   `04-screen-recipes.md` (**pattern E, form / sheet**), `05-screen-status.md`, `06-workflow.md`.
3. `docs/design-system/CHANGELOG.md`: In flight, Decisions, Done rows for DS-B1…B6.
4. Golden screenshots: `docs/design-system/screenshots/ds-b3/bloom_components.png`, `ds-b4/home.png`,
   `ds-b6/b6_accounts.png`, `ds-b6/b6_loans.png`.
5. Golden code: `lib/shared/widgets/ff_sheet.dart` (`showFfSheet`, `FfSheet`, `FfSheetHeader`, `FfSheetFooter`),
   `ff_amount_field` (`grep -rn "class FfAmountField" lib`), `ff_chip.dart`, `ff_segmented_pill.dart`,
   `ff_icon_tile.dart`, `ff_surfaces.dart` (`FfHeroCard`, hero tones), and the Bloom parts of
   `lib/features/accounts/accounts_screen.dart` and `lib/features/dashboard/widgets/home_accounts_carousel.dart`
   (they already map account type → hero tone and icon; **reuse that mapping, do not duplicate it**).
6. The sheet's own files:
   - `lib/features/accounts/accounts_screen.dart` (574 lines): the private `_AddEditAccountSheet` /
     `_AddEditAccountSheetState` live at the bottom of this file (about line 346 onward) and are opened by
     `_showAddEditAccountSheet` through `showFfSheet`. `_getAccountTypeIcon` is a static on the screen state.
   - `lib/features/accounts/accounts_controller.dart` (`saveAccount`, `archiveAccount`, `deleteAccount`).
   - `lib/models/account.dart` (`Account`, `AccountType`: bank, cash, creditCard, upi, investment, business).
   - the tests: `test/widget/accounts_management_widget_test.dart` (it opens the sheet and checks fields), and
     anything else found with `grep -rln "Add Financial Account\|AddEditAccount\|accounts_fab" test`.
   - every other place that creates or picks accounts and might want the same sheet or the same type tiles:
     `grep -rn "AccountType\." lib/features`.

## What exists today (verify, do not trust)

- `FfSheet` with header "Add Financial Account" / "Edit Account" and the subtitle "Stored 100% locally on device".
- Fields, in order: Account type (`FfSelect` dropdown with icons), Account name (required), Opening balance
  (required, numeric, `₹` prefix, `FfTextField`), Institution name (optional), Masked number / UPI ID (optional).
  Footer: "Add Account" or "Save Changes". On save it builds an `Account` (currency `INR`, `currentBalance` =
  existing current balance when editing, else the opening balance) and shows a toast.
- There is **no preview, no archive or delete from inside the sheet** (those live elsewhere on the screen), no
  guidance on what to put in each field, no duplicate-name check, and credit cards and investments are asked
  for an "opening balance" like a bank account.
- The sheet is a private class inside a 574-line screen file, so it cannot be tested or reused on its own.

## The UX goals

Treat these as the design brief, then argue with them in your plan where you have a better idea:

1. **Choose the type visually, first.** Replace the dropdown with a compact grid or horizontal row of **type
   tiles** (icon, short label) for Bank, Cash, UPI, Credit card, Investment, Business, each with its hero tone from
   the existing mapping, selection shown by the ink fill plus a check (never colour only), each at least 48 dp.
   Default selection is Bank for a new account. Changing the type adapts the rest of the sheet (point 4).
2. **A live preview card at the top.** The sheet's header area is a miniature of the account card the person will
   see on Home and Accounts (the same `FfHeroCard`/card styling and tone), updating as they type: the name (or a
   placeholder like "Your account name"), institution, masked identifier, type icon, and the opening balance as a
   split `FfAmountText`. This is the "this is Bloom" moment of the sheet; keep it cheap (no blur, no grain animation
   inside the sheet; effects belong to heroes and the dock only, and the preview may use the static gradient).
3. **Few fields, in a natural order.** Name → opening balance → (optional) details. Use `FfAmountField` for the
   balance with the currency symbol and a large light numeral. Optional institution and masked ID sit under one
   labelled disclosure row ("Add bank and number") that is open by default in edit mode if either has a value.
4. **Type-aware wording and help, without changing the data model.**
   - Labels, hints and the placeholder name adapt: Bank "HDFC Salary", Cash "Wallet", UPI "PhonePe UPI",
     Credit card "ICICI Amazon card", Investment "Zerodha", Business "Shop account".
   - Credit card and similar: decide, **with me**, how "opening balance" should read (for example "Amount you owe
     now" or "Outstanding") and how the sign is stored. **Do not change how balances are stored or computed.**
     Inspect how credit-card balances are treated across `lib/` first and present exactly what happens today.
   - A one-line helper under each field in `text2` (what to enter, why optional).
5. **Smart assists, all local.**
   - Institution suggestions as `FfChip`s from a small built-in list of common Indian banks, wallets and brokers
     (static data in the shared layer; no network). Picking one can suggest a name if the name is empty.
   - A **duplicate-name warning** (inline, icon plus text, not blocking) when an active account already has that name.
   - Masked-identifier privacy hint: "Last 4 digits only, never the full card number" and a gentle inline warning if
     the person types more than 4 digits for a card or bank account (UPI IDs are exempt). Warn, do not block.
6. **Edit mode is its own state.** Title "Edit account", values filled, the preview shows the current balance, and
   below the form a separated area with **Archive / Unarchive** and **Delete** using the existing controller methods
   and the shared confirm dialog (wording as on the Accounts screen today; tell me if you change it). A short note
   explains that editing the opening balance does not rewrite history if that is what the code actually does
   (verify; if the behaviour is surprising, report it and propose a fix instead of silently changing it).
7. **Inline validation and a Save that explains itself.** Errors appear beside the field with an icon plus text
   (never colour only). Save is ink, full width in `FfSheetFooter`, and while the name is empty the button states
   what is missing instead of being a silent grey. After save: the toast stays, and the new account is visible
   in the list immediately (scroll to it or briefly highlight it; propose one).
8. **Keyboard and sheet behaviour.** The sheet is keyboard-aware, the focused field scrolls above the keyboard,
   Next/Done move through fields, Done on the last field saves when valid, drag-to-dismiss asks only if the person has
   typed something, and 2× text scrolls instead of overflowing.
9. **Reuse.** Extract the sheet into its own file (`lib/features/accounts/add_edit_account_sheet.dart`, public
   `showAddEditAccountSheet(context, {Account? account})`), and make the **type tile row** and the **account preview
   card** shared components if another screen can use them (for example the account picker or onboarding). Do not
   over-generalise: share only what at least two places will use, and say which.

## Hard constraints

- Behaviour and data are unchanged: the same `Account` is produced for the same inputs (id, currency `INR`,
  `currentBalance` rule, timestamps, archive flag). No Isar schema, generated-file or provider-bootstrap changes
  (that triggers the backup gate; stop and ask me). Never log financial data.
- Accessibility per `01-direction.md`: 48 dp targets, contrast ratchet green, no colour-only status, 2× text
  without overflow (test it), screen-reader labels for tiles and the preview, amounts-hidden mode respected,
  reduced-effects safe, light and dark.
- Amounts via `FfAmountText` / `FfAmountField` only. Only shared `Ff*` components and tokens; no raw colours, sizes,
  radii or `TextStyle(`. Remove `FfSelect` from this flow if nothing else needs it, but do not delete the shared
  component unless `grep` shows zero other users.
- Keep keys, tooltips and semantics that tests rely on (`accounts_fab` and the field labels the existing test
  finds), or update those tests in the same commit and say why.
- Format only files you touched. Never `dart format lib`. Commit only your paths. Windows 11, PowerShell and Git Bash.

## Slices (one commit each, each updating `05-screen-status.md` and `CHANGELOG.md`)

- **B11a: extract**, behaviour-preserving: move the sheet into its own file with `showAddEditAccountSheet`,
  no visual change, existing tests green, add unit/widget tests for save, edit and validation.
- **B11b: shared pieces**: the account type tile row and the account preview card (+ tests, component sheet
  screenshot, `03-components.md`).
- **B11c: the new sheet**: layout, type-aware copy, live preview, assists (suggestions, duplicate warning, masked-ID
  hint), validation, keyboard behaviour.
- **B11d: edit mode**: archive / unarchive / delete, edit-state preview, post-save highlight.

## Verification

- Before / after screenshots with `tool/screenshots/compare.py`, light and dark, for: new account (empty), filled
  bank account, credit card, UPI, cash, validation errors, duplicate-name warning, edit mode with archive and delete,
  keyboard open, 2× text, hidden amounts. **Open the PNGs and look at them**; fix what you see.
- A short before/after count of taps and fields to create the three most common accounts (bank, cash, credit card).
- Widget tests: type switch updates labels and preview, preview reflects typed values, duplicate warning, Save
  explains what is missing, edit mode actions call the controller, keyboard-inset layout, 2× text. Full suite green,
  analyze clean, `dart run tool/design_system_audit.dart --shared` not up.
- Say plainly what you could not verify (device feel, real keyboard). No device install without the backup gate:
  ask me to create and verify an encrypted backup and keep the file and passphrase, wait for my confirmation, then
  `adb install -r` only (never `adb uninstall`, `pm clear` or `flutter install`).

## Start

Do steps 0–1 of `06-workflow.md` only. Read, take the baseline (`flutter analyze`, the accounts tests,
`dart run tool/design_system_audit.dart --shared`, current screenshots of the sheet), then return:

1. A map of the current sheet: fields, validation, save logic, callers, tests that pin texts or keys, and what the
   code actually does for credit-card balances and for editing the opening balance.
2. Your proposed layout block by block (top to bottom) with the shared component for each, and a description of the
   empty, filled, error, keyboard-open and edit states.
3. Your recommendations on the open decisions: wording for credit cards and investments, which assists ship, the
   post-save highlight, which pieces are shared.
4. Missing shared pieces, test and copy changes, risks, and questions.

Wait for my approval before building anything.
