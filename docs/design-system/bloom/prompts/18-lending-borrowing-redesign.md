# Prompt: Lending & Borrowing redesign (DS-B18)

Paste everything below the line into a new Claude Code chat (Opus 5.5).

---

You are the lead product designer, UX designer and Flutter engineer for **FinanceFlow** (Flutter, Riverpod, Isar;
fully local, privacy-first, no backend). The app uses one design system, **Stillwater**, in its **Bloom** visual
language. Home, Money, Accounts, Loans, Budgets, Insights, Savings goals, Needs review, Investments and the add
transaction / add account sheets are already in Bloom, and more slices have landed since. Your job is to redesign
**Lending & Borrowing end to end**: the overview screen, the person-record detail screen, the **add / edit record
sheet**, the **repayment sheet** and the **add advance ("lend more / borrow more") sheet**, plus every widget inside
them.

**This is one of the most important features in the app, and the bar is top-notch.** It must be a creative redesign
of layout, UI and UX, never a re-skin. The area is at "Tokens" status: it has Geist, ink buttons and squircle cards,
and that is exactly the problem. The overview is two summary boxes, six filter pills and a stack of identical cards;
the detail screen is an 879-line stack of cards, lists and key-value rows with leftover alpha tints; the sheets are
long forms. Recolouring it, or swapping widgets for their Bloom equivalents, is the wrong outcome and will be
rejected. Design it around what people actually ask of this feature: *"Who owes me, whom do I owe, what is overdue
or due soon, what is my net position, and how few taps does it take to record that someone paid me back, or that I
lent more?"* Money between people is emotional and sensitive, so the design should feel calm, fair and clear, never
like a debt-collection screen. Use Bloom's vocabulary (aurora canvas, hero card, squircles, light oversized numerals,
ink pills with one lime accent, ring, band and timeline viz, glass only where allowed) with our own signature, never
copied from the reference imagery.

## Read first, in this order (binding)

1. `AGENTS.md` (backup gate, standalone-startup gate, UI section).
2. `docs/design-system/bloom/README.md`, then `01-direction.md`, `02-foundations.md`, **`03-components.md` in full**
   (many shared components were added by slices DS-B7 to DS-B17 after the first Bloom docs were written; reuse them
   before building anything: hero card and hero figures, allocation band, consequence line, amount hero, suggestion
   chips, segmented pill, stat tiles, type and asset tile rows, section header, progress ring, page header, and any
   monogram or renewal chip that the Subscriptions slice added), `04-screen-recipes.md` (patterns C, D, E),
   `05-screen-status.md`, `06-workflow.md`.
3. `docs/design-system/CHANGELOG.md`: In flight, Decisions, Done rows, and the newest rules.
4. Look at the golden screenshots, then the code behind them: `docs/design-system/screenshots/ds-b6/b6_loans.png`
   and `b6_loan_detail.png` (overview + detail, the closest sibling: EMI **Loans**, which is a different feature, see
   below) and the folders of the newest landed slices (`ds-b7*`, `ds-b8*`, `ds-b10` to `ds-b14*`, `ds-b15*`, whichever
   exist; open them, they are the current bar). Read `lib/features/loans/`, `lib/features/accounts/`,
   `lib/features/savings_goals/` and `lib/features/investments/` as siblings. The add transaction sheet and the add
   account sheet are the model for how a Bloom creation sheet works (amount hero, type tiles, live preview, consequence
   line).
5. The area itself, `lib/features/personal_debts/`: `lending_borrowing_screen.dart` (671),
   `money_record_detail_screen.dart` (879), `add_edit_money_record_sheet.dart` (570), `add_repayment_sheet.dart` (374),
   `add_advance_sheet.dart` (302), `money_records_controller.dart` (565).
6. Models and logic: `lib/models/money_record.dart` (521), `money_advance.dart`, `money_repayment.dart`,
   `lib/services/money_lending_calculator.dart` (378; the summary, the filter enum and the sort rules),
   `lib/repositories/money_record_repository.dart` (621), `lib/services/financial_operation_service.dart` (how a
   record is posted into transactions), and the tests: `test/widget/lending_borrowing_widget_test.dart`,
   `test/unit/money_lending_calculator_test.dart`, `money_advance_test.dart`, `money_record_validation_test.dart`,
   `test/integration/financial_operation_service_test.dart` (`grep -rln "MoneyRecord" test` for the rest).
7. Everything that consumes lending data (read, do not edit): the Add transaction purpose forms for debts
   (`lib/features/transactions/form/widgets/transaction_purpose_fields.dart`, they link a transaction to a record via
   `linkedMoneyRecordId`), reminders (`lib/services/notifications/notification_scheduler.dart`), alerts, needs review
   and duplicate matching (`lib/services/ingestion/duplicate_matcher.dart`), backup and restore, and the entry in
   `lib/features/settings/more_screen.dart` (it pushes `const LendingBorrowingScreen()`; that constructor must stay).

## Coordination (check before anything else)

- `git status`, `git log --oneline -10`, and the CHANGELOG **In flight** table. If another row touches a file you need,
  stop and ask me.
- **Do not edit** `lib/features/dashboard/`, `lib/features/budgets/`, `lib/features/transactions/`,
  `lib/features/loans/` (EMI loans, a different feature), `lib/features/alerts/`, `lib/features/ingestion/`,
  `lib/features/settings/`. You only call into them. If you change a provider shape or route they depend on, tell me and
  make the smallest call-site fix.
- If the Subscriptions slice (DS-B15) has not landed and you want a monogram tile or a status chip it would add, ask me
  before building a duplicate; do not both create it.
- You may add shared components to `lib/shared/widgets/` (test + component-sheet screenshot + `03-components.md`).
  Extend existing shared ones only compatibly, then run the full suite.
- In `05-screen-status.md` and `CHANGELOG.md` change only your own rows, re-reading each file right before you edit.

## What exists today (verify, do not trust)

- **Model.** A `MoneyRecord` is one *person plus one direction* (`MoneyRecordType` lent / borrowed): `personName`,
  `normalizedPersonName`, `originalAmount`, `transactionDate`, `dueDate`, notes, reminder switch and
  `reminderDaysBefore`, `settledAt`, `originTransactionId`, `isCustomSeparateObligation`. Under it sits a ledger of
  `MoneyAdvance`s (money handed over; the first is created with the record as `adv_<recordId>`, each with its own date,
  due date and optional account / transaction) and `MoneyRepayment`s (money paid back, optional transaction). Repayments
  are allocated across advances oldest-first (`calculateAllocatedAdvances` gives each `AdvanceAllocation` its repaid and
  remaining amount); the **effective due date** is the earliest unpaid advance's due date; overdue and due-soon are
  derived from unpaid allocations; status is active / due soon / overdue / partially paid / settled.
- **Linkage.** With "Record in transactions and update balance" on, the controller posts a transaction through the
  `FinancialOperationService` (purpose lending / borrowing, category `cat_personal_debt`, id `debt_origin_<recordId>`,
  `linkedMoneyRecordId`) in the same operation as saving the record. Repayments and advances can do the same.
  `updateRecord` refuses an original amount below what is already repaid. `markRecordSettled` sets `settledAt` only.
- **Overview** (`lending_borrowing_screen.dart`): app bar with the On-device shield (to remove), two `_SummaryBox`es
  (Owed to me, I owe; counts and overdue), six filter pills over **one** `MoneyRecordFilter` enum that mixes direction
  and status (all / owed to me / I owe / overdue / due soon / settled), a sorted list of near-identical record cards
  (person, amount, progress bar, status), an extended FAB, an empty state. Sorting is overdue, then due soon, then
  other by due date, settled last (`MoneyLendingCalculator.sortRecords`).
- **Detail**: remaining-balance card with progress and Total advanced / Total repaid, three buttons (record repayment,
  lend or borrow more, mark unsettled), an advances list with Repaid / Unpaid per advance, a separate repayment history
  list, a Relationship details key-value card (started on, next due, reminder, notes), edit and delete in the app bar,
  many leftover alpha tints.
- **Sheets**: a long add / edit form (segment I lent / I borrowed, toggle, account select, person field, amount,
  dates, notes, reminder switch with 1d / 3d / 7d), a repayment form and an advance form with raw date fields.
- Static colours: `MoneyRecordType.colorFor` and `MoneyRecordStatus.colorFor` read `StillwaterColors` (the model file is
  on the data-owned colour list for DS-9). The UI must stop reading them.
- **Do not confuse this feature with Loans** (EMI loans from banks, `lib/features/loans/`). Keep the two apart in
  copy, icons and navigation.

## Design directions (starting points; improve them and justify what you change)

### Overview: "where do I stand with people" (pattern C on `FfAurora`, replace the page title area with `FfPageHeader`)

- **Net position hero.** One `FfHeroCard` with the figure that matters: net = owed to me minus I owe, as a light split
  numeral with plain words ("People owe you ₹X net" / "You owe ₹X net" / "All square"). Under it, a **two-sided
  balance band** (a new two-segment variant or an `FfAllocationBand` use) showing Owed to me against I owe, and
  `FfHeroFigures` for the two sides with counts. Choose the hero tone from the net direction and verify contrast; money
  tone colours are not used on heroes, so direction is carried by words and icons. Decide with me whether "owed to me"
  and "I owe" may use the income and expense colours elsewhere: they must never read as "income" and "expense" (a loan
  you gave is not income), so lean on icons, words and the debt tone.
- **Needs attention first.** A short lane above the list for what is overdue or due in the next 7 days, as swipeable
  cards (person monogram, "Ahmed · 12 days overdue · ₹4,000 left") each with one primary action: *Record repayment*
  (owed to me) or *Pay back* (I owe). Hidden when there is nothing; a calm "Nothing due this week" line is better than
  an empty block.
- **Direction and status are two different questions.** Today one enum mixes them. Propose a clearer control: an
  `FfSegmentedPill` for **Owed to me / I owe / All** and status lenses (Overdue, Due soon, Open, Settled) as quiet
  chips with counts. If this needs a two-axis filter state, show me the smallest change (UI-only state that maps to the
  existing `MoneyRecordFilter` and the existing `filterRecords`), and do not change the calculator's results.
- **People view (optional, ask me).** A *By person* toggle that groups records by `normalizedPersonName` and shows each
  person's **net** across directions ("Ahmed owes you ₹2,000 net"), derived from existing data only. This helps most
  when one person has several records. No new storage.
- **Person records, not generic cards.** Each row/card: a **monogram tile** (initials, a stable tone derived from the
  name, never a photo and no contacts access), the person's name, a direction line with icon and words ("owes you" /
  "you owe"), the remaining amount as a split figure, a thin repaid bar or small ring, and **one honest due chip** with
  words ("Overdue 12 days", "Due in 3 days", "Due 12 Dec", "Partly paid", "Settled 3 Mar"). One-tap inline action on the
  card for the common job (record repayment). Settled records collapse into a quiet *Settled* section so they stop
  competing with open ones. Lists sit in Bloom card groups with the shared section header and counts; the dock inset is
  respected; the FAB follows `FfDock.fabLocation` or becomes a clear spark add control, with two obvious starting points
  (*I lent* / *I borrowed*) rather than one generic "Add Record".
- **Empty state as onboarding**: two large tiles ("Someone owes me" / "I owe someone") that open the sheet with the
  direction preselected, and one sentence of reassurance that nothing leaves the phone. Filter-empty states are short
  and specific.

### Detail: one person, one fair ledger (pattern D)

- **Person-first hero**: monogram, name, a sentence ("Ahmed owes you", "You owe Sarah"), the remaining amount as the
  big split numeral, a ring for the repaid share, then `FfHeroFigures` (Lent / Repaid / Remaining, or Borrowed / Paid
  back / Left), and an honest due chip from the effective due date. The primary action is one ink button
  (*Record repayment* / *Pay back*) with a secondary *Lend more* / *Borrow more*; *Mark as settled / unsettled* lives in
  an overflow menu with a clear explanation (verify what `settledAt` changes before you word it).
- **One statement, not two lists.** Merge advances and repayments into a single chronological **ledger/timeline**:
  each entry has its icon, date, amount, optional note and linked-transaction hint, and the running balance after it.
  Advances show their allocation badge (Repaid / Partly repaid / Unpaid, with icon and words) and their own due date.
  One quiet line explains the rule, "Repayments clear the oldest advance first", so the allocation never feels
  arbitrary. Deleting an entry keeps today's confirm dialog (and undo if the pattern exists in the app).
- **Settle-up helpers.** A *Settle in full* shortcut that opens the repayment sheet prefilled with the remaining amount.
  Optional and needing my approval: a *Copy a gentle reminder* action that puts a friendly text on the clipboard or opens
  the system share sheet. It is only ever user-initiated, uses no phone numbers or contacts, and nothing is sent by the
  app.
- **Terms and reminder.** Relationship details become a compact facts card (`FfKeyValueRow`s: started, next due, notes)
  and the reminder becomes inline controls (switch plus 1d / 3d / 7d chips) that save immediately with a toast, as in
  the Subscriptions detail. Link to the origin transaction in Money where `originTransactionId` exists.
- Edit and delete move to an overflow menu with a destructive confirm; the screen keeps working for settled records.

### Add / edit record sheet: the creative centrepiece (pattern E)

Today it is a long vertical form. Turn it into a short, guided, mostly one-hand flow:

- **Direction first**, as two big tiles with an icon and a sentence ("I lent money" / "I borrowed money"). The rest of
  the sheet reads in the chosen direction (labels, consequence line, preview), and the tone changes subtly.
- **Person**: a field with suggestions from people already in the records (and from `externalCounterpartyName` of
  existing transactions only if it is already loaded; nothing new is fetched). Typing a known name shows a hint such
  as "Ahmed already owes you ₹2,000. Add to that record instead?" which opens the advance sheet for that record. Merging
  records or changing the add behaviour needs my approval; the hint alone does not.
- **Amount** as the shared amount hero (`FfAmountHero` / `FfAmountField`) directly under the person.
- **Dates as chips**, not raw pickers: *Today / Yesterday / Pick* for the date, and *In a week / In 2 weeks / End of
  month / In 3 months / Pick a date* for the due date (a due date is required by the model; do not invent "no due
  date" without asking me).
- **Account and the transaction link** as one row, not a toggle plus a select: "Record in my accounts" off by default
  exactly as today, and when on, the account tile row and a **consequence line** that tells the truth ("Takes ₹5,000
  from HDFC Salary now" / "Adds ₹5,000 to HDFC Salary now"). The existing insufficient-balance and validation behaviour
  stays.
- **Reminder** as inline chips (Off, same day, 1 day, 3 days, 7 days) mapped to the existing fields; notes as an optional
  line.
- A **live preview**: the finished record as it will appear in the list ("Ahmed owes you ₹5,000 · due 12 Dec"). Primary
  button label reads the action ("Record loan to Ahmed", "Record money from Sarah"); edit mode shows the real values,
  keeps the "cannot be below repaid" rule with a friendly inline message, and offers delete with confirm.

### Repayment and advance sheets

- **Repayment**: amount hero with quick chips (*Full ₹X*, *Half*, the next-due amount if it can be derived), a
  visual **allocation preview** ("Clears the 3 Mar advance and ₹500 of the 14 Mar one") from the existing allocation
  function, a date chip row, the account row with the consequence line, and clear over-payment validation. After saving,
  a toast with *Undo* if the app's pattern supports it, and a gentle "All settled" moment when the balance reaches zero.
- **Advance (lend more / borrow more)**: same family as the repayment sheet; shows the new total and what the new due
  date will do to the effective due date; the record-in-transactions row as above.
- Both open as `FfSheet`s with the person, the current remaining balance and the direction in the header.

## Hard constraints

- **Behaviour and data unchanged** unless I approve it in the plan: same model, controller, repository and calculator
  results for the same inputs; the same transactions posted through `FinancialOperationService` with the same ids,
  purposes and linkage; FIFO allocation untouched; validation messages kept or improved in wording only. **No Isar
  schema, generated-file or provider-bootstrap changes** (backup gate: stop and ask me). Never log financial data,
  names, notes or amounts.
- **Privacy**: no contacts permission, no phone numbers, no photos, no network, no automatic sending. People are
  represented by monograms only. The privacy blur / hide-amounts setting must hide every amount on every screen and
  sheet; names stay visible unless the app already hides them.
- Only shared `Ff*` components and tokens. No raw colours, sizes, radii, durations, `TextStyle(`, `Colors.*`. Remove
  every use of the model's `colorFor` getters and every alpha tint in the UI; if the model getters become unused,
  say so and ask me before removing them from `money_record.dart`. Use `FfSectionHeader`, `FfKeyValueRow`, `FfStatTile`
  and the other shared pieces in place of the private `_SectionHeader`, `_DetailTile`, `_SummaryBox` and
  `_FilterChipItem`.
- Amounts via `FfAmountText` / `FfAmountField` only. Sheets via `showFfSheet` / `FfSheet` / `FfSheetFooter`. Remove the
  `FfPrivacyBadge` from the app bar (headers no longer carry the shield).
- Accessibility: 48 dp targets, contrast ratchet green, **no colour-only status** (overdue, due soon, partly paid,
  settled, owed-to-me versus I-owe all carry an icon plus words), semantics for the ring, band and ledger, logical focus
  order, 2× text without overflow (test it), amounts-hidden mode, reduced effects, light and dark.
- Performance: no blur or grain beyond the hero rules, no continuous animation, the band and ledger are plain painted
  or list widgets built from already-loaded data. Provider reads stay as they are (`filteredMoneyRecordsProvider`,
  `moneyLendingSummaryProvider`, the per-record streams); derive grouping in the UI layer or a pure helper with tests.
- Keep keys, tooltips and semantics that `lending_borrowing_widget_test.dart` relies on, or update the tests in the same
  commit and say why. Keep the `LendingBorrowingScreen()` constructor and `AddEditMoneyRecordSheet` / `AddRepaymentSheet`
  / `AddAdvanceSheet` entry points working for every current caller.
- Split files over ~500 lines as you go (`money_record_detail_screen.dart` 879, `lending_borrowing_screen.dart` 671,
  `add_edit_money_record_sheet.dart` 570), behaviour-preserving and with no visual change, in a commit of their own.
- Format only the files you touched. Never `dart format lib`. Commit only your own paths. Windows 11, PowerShell and
  Git Bash.

## Slices (one commit each; each updates `05-screen-status.md` and `CHANGELOG.md`)

- **B18a Split and shared pieces**: behaviour-preserving split of the three large files, then whatever the design needs
  and the system lacks (person monogram tile, due chip, two-sided balance band, ledger entry row), with tests,
  component-sheet screenshot and `03-components.md`. Remove the colour getters from the UI.
- **B18b Add / edit record sheet** (the centrepiece), with the preview and the consequence line.
- **B18c Repayment and advance sheets**, with the allocation preview.
- **B18d Overview** (hero, attention lane, controls, record rows, settled section, empty state, optional people view).
- **B18e Detail** (person hero, ledger, settle-up, facts, inline reminder, menu).
- **B18f Polish**: states matrix (loading, error, empty, hidden amounts, 2× text, light and dark, reduced effects),
  motion, consistency pass with Loans and Accounts, docs.

**Pause for my review after B18b and after B18e** with the screenshots.

## Verification

- `flutter analyze` clean; `dart run tool/design_system_audit.dart --shared` numbers not up; the full test suite green.
- Golden screenshots through `tool/screenshots/compare.py`, before and after, for the overview (empty, one record, many
  records with overdue, hidden amounts), the detail (open, partly repaid, settled), and every sheet (create, edit,
  validation error), light and dark, 1× and 2× text, saved under `docs/design-system/screenshots/ds-b18*/`.
- New tests: the net position and band maths from a fixed record set, the filter and status controls, the due-chip
  wording at the boundaries (today, tomorrow, 7 days, yesterday), monogram stability, the ledger ordering and running
  balance, the repayment allocation preview against `calculateAllocatedAdvances`, the consequence-line text per
  direction, the known-person hint, the inline reminder save, and a flow test: add a record with "record in my
  accounts" on, repay it in two parts, and see it settle with the balances right.
- `financial_operation_service_test.dart`, `money_lending_calculator_test.dart` and the money record unit tests must pass
  untouched.
- Say plainly what you could not verify (device feel, hardware gestures, performance, grain). No device install without
  the backup gate: ask me to create and verify an encrypted FinanceFlow backup and keep the file and passphrase, wait
  for my explicit confirmation, then `adb install -r` only (never `adb uninstall`, `pm clear` or `flutter install`).
  Never test with my real data.

## Start

Do steps 0–1 of `06-workflow.md` only. Read everything above, run the coordination checks, take the baseline
(`flutter analyze`, the lending tests, the audit, current screenshots of every screen and sheet), then return:

1. A map of Lending & Borrowing today: screens, sheets, widgets, the data each shows, actions, callers and entry
   points, tests that pin texts or keys, the filter and sort rules, how a record posts into transactions, and the tap
   counts for the main tasks (add a record, record a repayment, lend more, see what is overdue, settle up).
2. Your target design for each screen and sheet: top-to-bottom layout, the shared component per block, the creative idea
   that gives it character, and its empty, loading, error, hidden-amount, edit, settled and 2× text states. Offer an
   alternative for your riskiest idea (the net-position hero with the balance band, or the merged ledger) and
   recommend one.
3. Shared components to add, behaviour or copy changes that need my approval (the people view, the two-axis filter, the
   reminder text, the known-person hint), anything that needs new storage, risks, and questions.

Wait for my approval before building anything.
