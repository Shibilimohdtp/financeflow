# Prompt: Subscriptions redesign (DS-B15)

Paste everything below the line into a new Claude Code chat (Opus 5.5).

---

You are the lead product designer, UX designer and Flutter engineer for **FinanceFlow** (Flutter, Riverpod, Isar;
fully local, privacy-first, no backend). The app uses one design system, **Stillwater**, in its **Bloom** visual
language. Home, Money, Accounts, Loans, Savings goals, Needs review and Investments are already in Bloom, and several
more slices have landed since. Your job is to redesign **Subscriptions end to end**: the list screen, the subscription
detail screen, the **add / edit subscription bottom sheet** and the **recurring suggestions sheet**.

**This must be a creative redesign, not a re-skin.** Subscriptions is at "Tokens" status: it already has Geist, ink
buttons and squircle cards, and that is the problem. The layouts, the hierarchy and especially the add-subscription
sheet are still the old stacked-form design. Recolouring it, or only swapping widgets for their Bloom equivalents, is
the wrong outcome and will be rejected. Design the feature around what people actually want from it: *"What am I
committed to paying, what is due next, can I trust I will not be surprised, and how little effort is it to add
or fix one?"* Use Bloom's vocabulary (aurora canvas, a sand hero, squircles, light oversized numerals, ink pills with one
lime accent, ring, dot-matrix and month-grid viz, glass only where allowed) with our own signature, never copied from the
reference imagery.

## Read first, in this order (binding)

1. `AGENTS.md` (backup gate, standalone-startup gate, UI section).
2. `docs/design-system/bloom/README.md`, then `01-direction.md`, `02-foundations.md`, **`03-components.md` in full**
   (many shared components were added by slices DS-B7 to DS-B14 after the first Bloom docs were written; reuse them
   before building anything: asset/type tile rows, consequence line, allocation band, hero figures, stat tiles,
   previews, quick chips and others), `04-screen-recipes.md` (patterns C, D, E), `05-screen-status.md`, `06-workflow.md`.
3. `docs/design-system/CHANGELOG.md`: In flight, Decisions, Done rows. Note the newest decisions and any rule added
   by the Budgets, Goals, Investments and Needs review slices.
4. Look at the golden screenshots, then the code behind them: `docs/design-system/screenshots/ds-b6/b6_loans.png`
   and `b6_loan_detail.png` (list + detail), and the folders of the newest landed slices (`ds-b7*`, `ds-b8*`, `ds-b10`
   to `ds-b14*`, whichever exist: open them, they are the current bar). Read the Savings goals and Investments code as
   the closest siblings: `lib/features/savings_goals/` and `lib/features/investments/`. Their add/edit sheets are the
   model for how a Bloom creation sheet works (template tiles, live preview, consequence line).
5. The area itself, `lib/features/subscriptions/`: `subscriptions_screen.dart` (373), `subscription_detail_screen.dart`
   (552), `add_edit_subscription_sheet.dart` (418), `recurring_suggestions_sheet.dart` (150),
   `subscriptions_controller.dart` (161).
6. Model and logic: `lib/models/subscription.dart` (`Subscription`: merchant, normalizedMerchant, amount, currency,
   `SubscriptionFrequency` weekly / monthly / quarterly / yearly / custom, nextRenewalDate, lastPaymentDate,
   accountId, category, paymentMethod, sourceTransactionId, `SubscriptionStatus` active / paused / cancelled /
   needsReview, reminderDaysBefore, isReminderEnabled, notes; `daysUntilRenewal`), `lib/services/subscription_service.dart`
   (`calculateMonthlyTotal`, `calculateYearlyTotal`, `computeNextRenewalDate`, `detectRecurringSuggestions`),
   `lib/services/merchant_normalization_service.dart`, and the tests `subscription_service_test.dart`,
   `subscription_payment_test.dart`, `subscription_payment_widget_test.dart`
   (`grep -rln "Subscription" test`).
7. Everything that consumes subscriptions (read, do not edit): Home's actionable strip
   (`lib/features/dashboard/widgets/actionable_items_section.dart`), Budgets' bills line
   (`lib/features/budgets/widgets/plan_bills_card.dart`, `plan_providers.dart`), alerts
   (`lib/features/alerts/`), needs review (`lib/features/ingestion/`), and backup/restore.
   Also how "mark as paid" and "record a payment" flow into `AddEditTransactionSheet.show(...)` from the detail screen.

## Coordination (check before anything else)

- `git status`, `git log --oneline -10`, and the CHANGELOG **In flight** table. If another row touches a file you need,
  stop and ask me.
- **Do not edit** `lib/features/dashboard/`, `lib/features/budgets/`, `lib/features/transactions/`,
  `lib/features/alerts/`, `lib/features/ingestion/`, `lib/features/settings/`. You only call into them. If you change a
  provider shape or route they depend on, tell me and make the smallest call-site fix.
- You may add shared components to `lib/shared/widgets/` (test + component-sheet screenshot + `03-components.md`).
  Extend existing shared ones only compatibly, then run the full suite.
- In `05-screen-status.md` and `CHANGELOG.md` change only your own rows, re-reading each file right before you edit.

## What exists today (verify, do not trust)

- List: totals plus a stack of subscription cards with the old row layout, a FAB to add, and an entry to the
  recurring suggestions sheet.
- Detail: facts as key-value rows, a payments list, actions (edit, pause/resume, cancel, delete, record payment).
- Add/edit sheet: stacked fields (merchant, amount, frequency, next renewal date, account, category, payment method,
  reminder, notes) with raw pickers.
- Suggestions sheet: a plain list of detected recurring merchants with an "add" action each.
- Each file has private section-label widgets and ad-hoc spacing.

## Design directions (starting points; improve them and justify what you change)

### List: "what am I committed to, and what is due next" (pattern C, sand hero)

- **Hero**: a sand `FfHeroCard` with the **monthly commitment** as a split amount (`moneyHero`), the yearly total as
  a quieter line, the active count, and a "next up" line ("Next: Music · in 3 days"). Use `calculateMonthlyTotal` and
  `calculateYearlyTotal`; do not invent figures. Hidden-amounts mode respected.
- **The next 30 days strip**: a compact horizontal timeline (or `FfMonthGrid`/dot row) showing which days renewals fall
  on and how much each day costs, tappable to jump to that subscription. It answers "when does money leave?" at a glance.
  It is the signature element of this screen, so make it good and keep it cheap to draw (no blur, no per-frame animation).
- **Grouped list, not one long list**: sections by urgency ("This week", "Later this month", "Next month and beyond",
  then "Paused" and "Cancelled" collapsed), with a sort and filter `FfPillBar` (By date, By cost, By category). Each
  card: a merchant monogram tile (initials in a tinted squircle, never brand logos or fetched images), name, amount
  with `/mo`-style frequency in the inline amount style, a **renewal chip with icon and words** ("in 3 days",
  "today", "overdue by 2 days") and a monthly-equivalent cost for non-monthly ones. Status is never colour only.
- **Suggestions as a moment, not a menu**: a dismissible card at the top ("We noticed 3 payments that repeat") that
  opens the suggestions sheet. It appears only when `detectRecurringSuggestions` finds something and is remembered as
  dismissed in a way that already exists or via a non-schema-changing mechanism (ask me before storing anything new).
- **Insight, one at most**: for example "Your three most expensive subscriptions are 62% of the total" or a yearly-cost
  callout, computed from the data; absent when not meaningful.
- **Empty state that sells the feature**: explains what subscriptions are for, offers "Add one" and "Find from my
  transactions" (opens the suggestions sheet), and shows a ghost of the next-30-days strip.

### Detail: one subscription, fully understood (pattern D, sand hero)

- **Hero**: merchant monogram, amount and frequency, and a **renewal ring** that shows how far through the current
  billing cycle you are, with "Renews in 9 days · 12 Dec" in words. Paused and cancelled states have their own
  calm treatment (icon plus words, hero tone muted, no countdown).
- **Facts as stat tiles** replacing the key-value rows: cost per month, per year, total paid so far (from linked
  transactions where the data exists), account, category, reminder.
- **Payment history as a picture**: `FfMonthGrid` or dot-matrix of the last 12 months (paid / missed / upcoming, with
  shapes and labels, never colour only) plus a day-grouped list of payments that opens the transaction. If payments
  show a changed amount, surface a small "price changed from ₹149 to ₹199" note, computed only from real data.
- **Actions in a sensible order**: primary ink "Record payment" (keeps today's flow into the add-transaction sheet),
  then Pause / Resume, Edit, Cancel subscription, and Delete last and separated, each with the existing confirm
  dialogs and wording unless I approve a change.
- **Reminder control inline**: a small row with `FfChip`s (1 / 3 / 7 days before, Off) that edits
  `reminderDaysBefore` / `isReminderEnabled` directly, so people do not need the full edit sheet for it.

### Add / edit subscription sheet: the creative centrepiece (pattern E)

- **Start from what it is**: a row of **type tiles** by generic category with a monogram or icon, never brand logos:
  Streaming, Music, Cloud and apps, Gaming, News and learning, Fitness, Insurance, Rent and utilities, Phone and
  internet, Other. Choosing one prefills category and a suggested name hint. Merchant name suggestions come from
  `MerchantNormalizationService` and past transactions (local only).
- **Amount-first**: a large light `FfAmountField` with the symbol, then **frequency pills** (Weekly, Monthly, Quarterly,
  Yearly, Custom). Switching frequency keeps the amount and updates the live line.
- **Renewal date by intention, not by calendar**: chips "Today", "Tomorrow", "In a week", "Same date next month" and
  "Pick a date", using `computeNextRenewalDate` for sensible defaults.
- **A live consequence line** under the form: "₹199 a month is ₹2,388 a year. Next payment 12 Dec." (computed with the
  existing functions; for custom frequency say plainly what the 30-day fallback means).
- **A live preview card** at the top of the sheet: the subscription card as it will appear in the list, updating as the
  person types (monogram, name, amount, renewal chip).
- **Smart, local assists**: last-used account as a chip (change opens `AccountPickerSheet`), the category as a chip,
  a duplicate warning ("You already track Music") that is inline, non-blocking and icon plus text, and, when launched
  from a suggestion, everything prefilled with a short "Detected from 4 payments" note.
- **Progressive disclosure**: reminder (chips), payment method and notes sit behind a single labelled row; in edit mode
  they open if they have values. Edit mode adds Pause / Cancel / Delete in a separated area with the existing dialogs.
- **Save explains itself**: inline errors with icon plus text; the primary button names what is missing instead of
  silently greying out. Keyboard-aware, Next/Done order, drag-to-dismiss asks only if the person typed something.

### Recurring suggestions sheet: review in seconds

- Replace the plain list with a **card-by-card review**: each suggestion shows the merchant, the detected amount and
  rhythm ("₹199 · every month · last 4 payments"), the evidence as a tiny dot row of the matched dates, and two clear
  choices, **Add** (opens the add sheet prefilled, or adds directly if you decide that is safe and I agree) and
  **Not a subscription**. Keep a visible list alternative (`FfSegmentedPill`), and make every gesture available as a
  button and a screen-reader action. Persisting "not a subscription" requires storage: if it does not already exist,
  **stop and ask me** (no schema change without approval and the backup gate).

## Hard constraints

- **Behaviour and data unchanged** unless I approve it in the plan: same model, controller, service functions and
  persisted values; the same `Subscription` for the same inputs; "record payment" still goes through
  `AddEditTransactionSheet.show`. **No Isar schema, generated-file or provider-bootstrap changes** (backup gate: stop
  and ask me). Never log financial data, merchants or notes.
- **No brand imagery, logos, fetched icons or network access.** Monograms and generic category icons only.
- Only shared `Ff*` components and tokens. No raw colours, sizes, radii, durations, `TextStyle(`, `Colors.*`. Remove
  every static `StillwaterColors` read. Replace the private `_SectionLabel`-style widgets with the shared section
  heading component.
- Amounts via `FfAmountText` / `FfAmountField` only. Bottom sheets via `showFfSheet` / `FfSheet` / `FfSheetFooter`.
- Accessibility: 48 dp targets, contrast ratchet green, no colour-only status (renewal chips, paid/missed/upcoming,
  paused/cancelled all carry icon plus words), semantics for the ring, strip and month grid, logical focus order,
  2× text without overflow (test it), amounts-hidden mode, reduced effects, light and dark.
- Performance: no blur or grain beyond the hero rules, no continuous animation, the 30-day strip and month grid are
  plain painted widgets built from already-loaded data.
- Keep keys, tooltips and semantics that tests rely on, or update the tests in the same commit and say why.
- Split files over ~500 lines as you go (`subscription_detail_screen.dart` is 552).
- Format only the files you touched. Never `dart format lib`. Commit only your own paths. Windows 11, PowerShell and
  Git Bash.

## Slices (one commit each; each updates `05-screen-status.md` and `CHANGELOG.md`)

- **B15a Shared pieces**: whatever the design needs and the system lacks (renewal chip, monogram tile, 30-day strip,
  hero-with-ring figure, if not already present), with tests, component-sheet screenshot and `03-components.md`.
- **B15b Add / edit sheet** (the centrepiece), including the live preview and consequence line.
- **B15c List** (hero, strip, grouped list, suggestions card, empty state).
- **B15d Detail** (hero ring, stat tiles, payment history, actions, inline reminder).
- **B15e Suggestions sheet** (card review).
- **B15f Polish**: states matrix, motion, consistency pass with Goals and Investments, docs.

**Pause for my review after B15b and after B15d** with the screenshots.

## Verification

- Before / after screenshots with `tool/screenshots/compare.py`, light and dark, for each screen and sheet in these
  states: empty, one subscription, many, with renewals today and overdue, paused / cancelled, non-monthly frequencies,
  validation errors, duplicate warning, edit mode, keyboard open, 2× text, hidden amounts, loading, error.
  **Open the PNGs and look at them**; compare against the Goals and Investments screens, and fix anything that looks
  like the old design with new colours.
- Tap-count comparison before vs after for: add a monthly subscription, add one from a suggestion, mark a payment,
  pause one, change the reminder.
- Widget tests for each new interaction (type tile prefill, frequency switch updates the line, date chips, duplicate
  warning, suggestion add / dismiss, inline reminder chips, record-payment hand-off, the grouping rules). Full suite
  green, `flutter analyze` clean, `dart run tool/design_system_audit.dart --shared` numbers not up.
- Say plainly what you could not verify (device feel, gestures on hardware, performance, grain). No device install
  without the backup gate: ask me to create and verify an encrypted FinanceFlow backup and keep the file and passphrase,
  wait for my explicit confirmation, then `adb install -r` only (never `adb uninstall`, `pm clear` or `flutter install`).

## Start

Do steps 0–1 of `06-workflow.md` only. Read everything above, run the coordination checks, take the baseline
(`flutter analyze`, the subscription tests, the audit, current screenshots of every screen and sheet), then return:

1. A map of Subscriptions today: screens, sheets, widgets, the data each shows, actions, callers and entry points,
   tests that pin texts or keys, the grouping and sort rules that exist, and the tap counts for the main tasks.
2. Your target design for each screen and sheet: top-to-bottom layout, the shared component per block, the creative
   idea that gives it character, and its empty, loading, error, hidden-amount, edit and 2× text states. Offer an
   alternative for your riskiest idea (the 30-day strip, or card-by-card suggestion review) and recommend one.
3. Shared components to add, behaviour or copy changes that need my approval, anything that needs new storage, risks,
   and questions.

Wait for my approval before building anything.
