# DS-B19 · EMI schedule (per-loan payment schedule) in Stillwater Bloom: audit and plan

Status: **proposal, awaiting owner approval.** No code has been changed. Visual migration can proceed on approval;
the three behaviour questions in section 8 need an answer first.

Scope: the full schedule screen opened from a loan's detail ("View Complete Amortization Schedule" and the calendar
icon in the app bar of [loan_detail_screen.dart](../../lib/features/loans/loan_detail_screen.dart)). It is
`EmiScheduleView` in [emi_schedule_view.dart](../../lib/features/loans/widgets/emi_schedule_view.dart) (563 lines).
The loan detail itself is already Bloom (DS-B6); this slice does not touch it, except the entry tile (section 6).

Why this is a separate slice: [CHANGELOG.md](CHANGELOG.md) (Slice status, DS-B7+ row) explicitly says the full EMI
schedule view "keeps its layout (tokens only)" for now. This plan is the next step for it.

---

## 1. Current state, read from the code

Structure today (top to bottom):

| Block | Code | What it does |
|---|---|---|
| App bar | `FfAppBar(title: '${name} Schedule')` (line 192) | Title only; no subtitle, no lender, no actions |
| Count bar | lines 197–235 | Three legacy-looking badges: "N Paid", "N Overdue", "N Upcoming" in a `Wrap`, built with `Container` + `BorderRadius.circular` |
| Overdue banner | lines 238–277 | Brick-tinted row: warning icon, "N overdue EMIs detected", "Mark All Paid" `FfButton` |
| Divider | line 279 | `FfDivider` |
| List | lines 281–470 | One flat `ListView.separated` of **every** installment (36–60+ rows), no grouping, no current-position anchor |
| Row | lines 289–467 | Whole row is an `InkWell`: tap = mark paid, or unpaid if already paid. Leading 32 px circle (check / `#n`), then date + status pill, then "P: … · I: …" line, then EMI amount + "Bal: …", then a 32 px icon button |
| Status pill | lines 503–562 | "Paid 3 Jul 2025" in success tint, "OVERDUE (5 d)" in error tint; upcoming rows have no label |

Problems (ordered by impact):

1. **No hierarchy or summary.** The screen opens on a row of tiny badges. The user's real questions — "how far along am I?",
   "what do I owe next?", "how much interest is left?", "when does it end?" — are not answered anywhere on the screen.
2. **Flat wall of rows.** 36–60 identical rows, no year or phase grouping, no "you are here" marker. The next due EMI is
   not highlighted, so the user scrolls to find it.
3. **Cryptic copy.** "P: ₹7,167 · I: ₹1,881" and "Bal: ₹1,50,000" use abbreviations. "OVERDUE (5 d)" is shouty and
   terse. Status is shown by colour + icon on the circle, but upcoming rows carry no words at all.
4. **Two competing interaction models.** The whole row toggles paid/unpaid, and a separate 32 px icon button does the
   same thing. Marking paid goes through an account picker and then a confirm dialog; undo goes through a destructive
   confirm. The tap target of the row and the icon button can both be hit by accident.
5. **Off-system visuals.** The screen uses `Container`/`BoxDecoration`, `BorderRadius.circular` (4 places), raw
   `EdgeInsets`/`SizedBox` numbers (9), `withValues(alpha: 0.12/0.15/0.08)` (8), `FontWeight.bold` (8), `Icons.*` (4),
   and `CurrencyFormatter.formatAmount` (6) instead of `FfAmountText`. No squircle, no aurora-free canvas treatment,
   no ink-pill actions, no `FfDueChip`/`FfDotMatrix`, no hero.
6. **Amount hiding is not wired.** `FfAmountText(isBlurred:)` exists, but no loan screen passes it, so this screen
   would show amounts while the rest of the app hides them.
7. **No summary of totals.** Principal, interest, total payable, interest paid so far, interest remaining, and the
   end date are all absent. The data exists in `LoanCalculator` / `loanScheduleProvider`.

What works and must stay:

- Behaviour: mark paid (account picker → confirm → toast), unpaid (destructive confirm → toast), mark all overdue paid
  (account picker → confirm with total → toast). Keep all three flows and their copy's meaning.
- Live updates: the screen reads `allLoansStreamProvider` + `loanScheduleProvider`, so it reflects changes at once.
- The status model: `EmiPaymentStatus` (paid / overdue / upcoming) and `AmortizationScheduleItem` are unchanged.

## 2. Tests that pin this screen (must keep passing, or be updated with a reason)

From [emi_schedule_view_test.dart](../../test/widget/emi_schedule_view_test.dart) and
[loans_widget_test.dart](../../test/widget/loans_widget_test.dart):

| Pinned text / icon | Where | Plan |
|---|---|---|
| `'15 Paid'` (exact), `textContaining('Upcoming')`, `'N Paid'` after mark-all | both | **Keep** the phrase "15 Paid" as the wording of the paid count in the summary (see section 3, block 3) |
| `textContaining('Overdue')`, `'0 Overdue'` must be absent when cleared | loans_widget_test | Keep the word "Overdue" for the count; hide the block when zero |
| `'July 2025'`, `'Paid 3 Jul 2025'`, `'November 2025'`, `'Paid 3 Nov 2025'` | emi_schedule test | **Keep** the same text format for the row date and its paid line |
| Icons `Icons.undo_rounded` (paid rows), `Icons.check_circle_outline_rounded` (unpaid rows) | emi_schedule test | Keep these icons on the row action so the test still finds them |
| `'Macbook EMI Schedule'` as app bar title | loans_widget_test | **Change** to the loan name as title with "Payment schedule" as subtitle, or keep the title. Needs your OK (section 8, Q2) |
| `'Mark All Paid'`, `'Mark All Overdue EMIs Paid?'`, `'Mark All (n) Paid'`, `'n Paid'` | loans_widget_test | Keep the button label and dialog title exactly |

## 3. Target layout, block by block

Recipe: **Pattern D (detail)** from [04-screen-recipes.md](bloom/04-screen-recipes.md), with a list-heavy body. Golden:
[loan_detail_screen.dart](../../lib/features/loans/loan_detail_screen.dart) and `screenshots/ds-b6/b6_loan_detail.png`.
Canvas: `surfacePage` (plain, not aurora: it is a pushed sub-screen). Hero tone: **rose** (Loans, EMIs, debts; table in
[02-foundations.md](bloom/02-foundations.md)). Pale rose uses ink text.

```
Scaffold (surfacePage)
└ CustomScrollView
  ├ 1. FfAppBar(title: loan name, subtitle: "Payment schedule · {lender}")
  ├ 2. Hero: FfHeroCard(tone: rose, leading: FfProgressRing(value: paid share, icon: loan icon))
  │     title: "N of M EMIs paid"
  │     FfAmountText(hero, split) = remaining payable, label "Left to pay"
  │     FfHeroFigures: "Paid · ₹x" | "Next · #n on d Mon" | "Ends · Mon yyyy"
  ├ 3. Attention card (only when overdue > 0): FfCard(variant: warning)
  │     "2 EMIs overdue · ₹18,096" + FfButton "Mark all 2 paid" (same flow)
  ├ 4. Progress card: FfCard(comfortable)
  │     FfDotMatrix(total: M, done: paid) with the number in text beside it
  │     and the next step in spark (existing FfDotMatrix behaviour)
  ├ 5. Filter: FfSegmentedPill  All · Upcoming · Paid · Overdue      (needs Q1)
  ├ 6. For each year: FfSectionHeader(title: "2026", count: "4 of 12 paid")
  │     one FfGroupedContainer (compact) of schedule rows
  │     Next-due row: spark dot + "Next" chip; overdue rows: FfDueChip
  ├ 7. Totals card: FfCard(comfortable) with FfStatTile × 4
  │     Principal (paid / total), Interest (paid / total), Total payable, Closes on
  └ 8. Bottom spacer; privacy line "On-device & private" (FfPrivacyBadge) optional
```

### Block details

**1. App bar.** `FfAppBar(title: loanName, subtitle: 'Payment schedule · $lender')`. No text button. Back only.
The existing "Schedule" word moves to the subtitle (see Q2).

**2. Hero.** One hero per screen. Title is the answer to "how far am I", not a label: `N of M EMIs paid`.
The big figure is the **remaining payable** (principal + interest still to pay), `FfAmountText(size: hero, style: split)`,
with a quiet label "Left to pay" above it. `FfProgressRing(value: paid / total)` is the leading icon ring.
`FfHeroFigures` (3 figures, first starts / last ends):
- Paid · ₹ amount paid so far
- Next · "#16 · 3 Sep" (or "Overdue" in words when overdue > 0; never colour alone)
- Ends · "Sep 2028"

Hero colours come from `context.ff.hero(FfHeroTone.rose)`. No money-tone colours on the hero (repo rule).

**3. Attention card.** Shown only when `overdueItems.isNotEmpty`. Replaces the current brick banner, which is a plain
Row. Warning variant card (`FfCard(variant: FfCardVariant.warning)`) with `FfIconTile(corner: FfCorner.warning)`.
Its button calls the **same** `_markAllOverduePaid` flow. Text: "2 EMIs overdue · ₹18,096" and "Mark all 2 paid".
Keep the copy "Mark All Paid" (test) if Q2 keeps the old wording; otherwise change the test in the same commit.

**4. Progress card.** `FfDotMatrix(total: M, done: paid)`. The number is always in text next to it ("15 of 36 paid").
Missed months say "overdue" in words, never only a dot colour. This card may be merged into the hero if the hero
gets too tall on 320 px screens; decide at the first screenshot.

**5. Filter.** `FfSegmentedPill` with All · Upcoming · Paid · Overdue, each with its count. It only changes which rows
the list shows; the totals and hero do not change. **Behaviour addition, needs approval (Q1).** Without it, the
list is simply all rows, grouped by year, with the next due row opened by default.

**6. Rows (the core of the redesign).** Each row is one installment. Proposed as one shared widget,
**`FfScheduleRow`** (see section 4), so Loan detail's "Next EMI" can reuse it later:

| Part | Content | Token / component |
|---|---|---|
| Leading | Circle with the state: paid = spark fill + ink check; overdue = `statusError` tint; next = ink ring; upcoming = quiet `#n` | `FfIconTile`-style circle, colours from `FfTint` / `FfTone` (no raw alpha) |
| Title | Due date "3 Sep 2026" (`titleSm`); "Paid 3 Sep 2026" when paid (keeps test text) | `context.ff.text.titleSm` |
| Subtitle | "Principal ₹7,167 · Interest ₹1,881" (`label`, secondary colour) | replaces "P: · I:" |
| Status | `FfDueChip(dueDate, settledAt, isSettled)` for overdue and paid; "Next" chip for the next due; nothing for future rows. Overdue words: "Overdue · 5 days" (replaces "OVERDUE (5 d)") | **reuse `FfDueChip`**, do not edit it (DS-B18 owns the file, see section 7) |
| Trailing | EMI amount `FfAmountText(size: sm, style: inline)`; "Balance ₹1,50,000" under it (`labelSm`) | `FfAmountText` only |
| Action | Paid row: "Undo" text action (48 dp), unpaid row: "Mark paid" (ink pill, `FfButton(size: sm)`) for the next and overdue rows only. Future rows: no visible button | `FfButton`; old icon tooltips kept as semantics |

Interaction change (see Q3): today the **whole row** is the tap target. Proposed: the row itself opens nothing,
and the explicit action button does the work. This prevents accidental mark-paid while scrolling and matches the
"ink acts" principle. If you want to keep row-tap, the action button stays as the visible affordance.

Semantics per row: "Installment 3, 3 Sep 2026, ₹9,048, paid 3 Sep 2026, principal ₹7,167, interest ₹1,881".

**7. Year sections.** `FfSectionHeader(title: year, count: "4 of 12 paid")`, no ALL-CAPS labels (direction rule).
Sticky headers are optional; start non-sticky (simpler, matches Money's frosted headers only on that screen).

**8. Totals card.** `FfCard(comfortable)` with 4 `FfStatTile`s in a 2 × 2 grid:
Principal (paid of total), Interest (paid of total), Total payable, Closes on (date). All amounts `FfAmountText(size: md)`.
This answers "how much interest is left" which the screen does not answer today.

## 4. Shared pieces to add (never as one-off code)

| Piece | Why | Rule |
|---|---|---|
| `FfScheduleRow` (new, `lib/shared/widgets/ff_schedule_row.dart`) | One installment row with state, date, principal/interest line, status chip, amount and action | Add to [03-components.md](bloom/03-components.md) in the same commit; widget test in `test/widget/components/` (light, dark, 2× text, reduced effects, semantics, RTL) |
| `FfDotMatrix`, `FfHeroCard`, `FfHeroFigures`, `FfStatTile`, `FfSegmentedPill`, `FfSectionHeader`, `FfDueChip`, `FfCard`, `FfGroupedContainer` | Already exist | Use as is. `FfDueChip` is owned by DS-B18 right now: read only |
| Contrast | Rose hero text and the state colours are existing pairs | Add a `FfContrastRules` entry only if `FfScheduleRow` draws a new colour pair (e.g. the ink ring on `surfaceCard`) |

No new tokens are expected. If the spark check needs a new pair, that goes into `FfContrastRules` as the rule says.

## 5. Copy changes

| Now | Proposed | Why |
|---|---|---|
| "P: ₹x · I: ₹y" | "Principal ₹x · Interest ₹y" | No abbreviations |
| "Bal: ₹x" | "Balance ₹x" | Same |
| "OVERDUE (5 d)" | "Overdue · 5 days" | Sentence case, plain |
| "{name} Schedule" as title | "{name}" title + "Payment schedule · {lender}" subtitle | Bloom title pattern (Q2) |
| "N Upcoming" badge | "N upcoming" count in the filter pill | Plain |
| "Paid 3 Jul 2025" (pill) | unchanged | Test pins it |

## 6. Entry point (the one Tokens-status piece outside the screen)

[loan_detail_screen.dart](../../lib/features/loans/loan_detail_screen.dart) lines 181–183 (`_openSchedule`) and lines
316–320 (the "View Complete Amortization Schedule" tile, still Tokens): restyle that tile as an `FfCard` row with an
`FfInkButton.open` (↗), since the schedule is a drill-down. Keep the same `MaterialPageRoute` so navigation tests stay
unchanged. This is a small change in the loan detail file, so it needs its own before/after capture.

## 7. Coordination and files

In flight today (from [CHANGELOG.md](CHANGELOG.md)):

- **DS-B18 (Lending)** owns `lib/shared/widgets/ff_due_chip.dart` and `ff_balance_band.dart`: this slice only **uses** `FfDueChip`.
- **DS-B15 (Subscriptions)** touches `ff_monogram_tile.dart`, `ff_renewal_chip.dart`, `ff_renewal_strip.dart`: no overlap.
- **DS-B16 (Settings)** touches `lib/shared/widgets/` broadly: `ff_schedule_row.dart` is a new file, so it should not clash, but add the In flight row before starting and check `git status` first.

Nobody has an In flight row for `lib/features/loans/`. This slice takes it, with these files:

- `lib/features/loans/widgets/emi_schedule_view.dart` (rewrite; split into private widgets, target under 500 lines)
- `lib/features/loans/loan_detail_screen.dart` (entry tile only, lines ~181–183 and ~316–320)
- `lib/shared/widgets/ff_schedule_row.dart` (new) + `test/widget/components/schedule_row_components_test.dart` (new)
- `test/widget/emi_schedule_view_test.dart`, `test/widget/loans_widget_test.dart` (copy updates only, with a reason each)
- `tool/screenshots/loans_schedule_screenshots_test.dart` (new), `docs/design-system/screenshots/ds-b19/`
- `docs/design-system/bloom/03-components.md`, `05-screen-status.md`, `../CHANGELOG.md`

**No data, schema or startup change is planned.** So the backup gate and the standalone-startup gate in `AGENTS.md`
are not triggered. If Q1 leads to a persisted filter preference, that changes the answer (settings schema → backup gate).
Keep the filter in widget state only.

## 8. Questions for you (each has my recommendation)

1. **Filter pills (section 3, block 5):** add All · Upcoming · Paid · Overdue? **Recommend yes**, in widget state only.
   It becomes useful at 40–60 rows. Alternative: no filter, just year sections with the next-due row first.
2. **Title and copy:** title the screen with the loan name and put "Payment schedule" in the subtitle? **Recommend yes.**
   This changes one test string (`'Macbook EMI Schedule'`) in the same commit, with the reason written in the commit message.
3. **Row interaction:** make the row non-tappable and use an explicit "Mark paid" / "Undo" button only? **Recommend yes**,
   to prevent accidental payments while scrolling. The account picker and confirm dialog stay exactly as they are.
4. **Totals card:** keep it at the bottom, or move it above the list as a second summary? **Recommend bottom**, so the
   hero and progress card are the only things above the rows.
5. **Amount hiding:** should this screen hide amounts with the app's "hide amounts" toggle, like Home? **Recommend yes**,
   wired the same way Home does it (`isBlurred: isPrivacyBlur`, as in `budget_overview_card.dart`). Confirm the toggle is the global one when you approve.

## 9. Build plan (after approval)

| Step | Work | Gate |
|---|---|---|
| B19a | `FfScheduleRow` shared widget + component test + gallery entry + `03-components.md` row | `flutter analyze`, component test |
| B19b | Rewrite `EmiScheduleView` (hero, attention, progress, filter, year sections, totals) using only tokens and shared widgets; keep all three mark-paid flows | screen tests updated, 320 px and 2× text test |
| B19c | Loan detail entry tile restyle | loan detail tests |
| B19d | Screenshot test `loans_schedule_screenshots_test.dart`; before/after light and dark; **look at the PNGs** (overflow, clipped amounts, rose hero contrast, empty states, 60-row list) | `compare.py` |
| B19e | Record: `05-screen-status.md` (Loans → EMI schedule: Bloom), `CHANGELOG.md` (In flight removed, Done row, Decisions, leakage row), commit only own paths | `dart run tool/design_system_audit.dart --shared`: numbers must not go up |

## 10. Verification and definition of done

- Light and dark, 2× text, 320 px width, amounts hidden, reduced effects, empty (no installments), loading (skeleton
  shaped like hero + rows), error (loan missing: `FfEmptyState` with back), RTL.
- Tests: `emi_schedule_view_test.dart`, `loans_widget_test.dart`, `test/widget/components/`, `test/theme/`,
  `test/widget_test.dart`, then `flutter test -j 2 --timeout 90s`.
- Keep keys, tooltips and semantics; add semantics for each row (section 3, block 6).
- Not verifiable here without a device: real grain on the rose hero and real touch feel. Say so in the Done row.

## 11. Risks

- A 60-row list with a sticky-free year header can be slow if rows rebuild on every provider tick. Keep rows `const`
  where possible; select only the schedule provider.
- Rose hero with ink text must pass 4.5:1 at its lightest point (existing `FfHeroContrastRules`). Check in the screenshot.
- Moving actions from row-tap to a button changes muscle memory. Q3 is the owner's call.
- The hero figure "Left to pay" must match the Loan detail's "Left to pay" exactly, or the two screens disagree.
  Use the same calculation (`loanRemainingBalanceProvider`), not a new one.
