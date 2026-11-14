# 04 · Screen recipes

Every screen is one of these patterns. Pick the pattern, follow its anatomy top to bottom, and copy structure from
the golden screen named. Spacing between blocks is `FfSpace.md` (16) inside a group and `FfSpace.lg`–`xl` (20–24)
between groups; the page margin is always `FfSpace.pageMargin`.

## A. Hero tab (top-level summary): Home, Plan/Budgets, Insights

Golden: Home (`dashboard_screen.dart`, `screenshots/ds-b4/home.png`).

```
FfAurora
└ Scaffold(backgroundColor: transparent)
  ├ non-sticky header inside scroll view: FfPageHeader(title: headline, subtitle: label, actions: FfCircleButton(s))
  ├ the ONE key figure: label (text.label) + FfAmountText(size: hero, style: split) + one FfCircleButton
  ├ hero: FfHeroCard (or FfCarousel of FfHeroCards), with an FfProgressRing as leading and FfInkButton.open
  ├ "needs attention" rows: compact FfCard / FfGroupedContainer, FfIconTile with FfCorner.warning
  ├ FfPeriodBar (if the screen is period-based) + summary FfCard (comfortable) with stat tiles / chart
  ├ secondary sections: FfSectionHeader(title, trailing: TextButton) + FfCard(s)
  └ privacy footer ("On-device & private") and bottom space for the FAB
```

Rules: one key figure; at most one hero card (a carousel counts as one); everything below the hero is solid cards.

## B. Everyday list: Money, Subscriptions list, Alerts inbox, Needs review

Golden: Money (`transactions_screen.dart`, `screenshots/ds-b5/money.png`).

```
Scaffold (plain surfacePage / FfAurora)
├ CustomScrollView
│ ├ FfPageHeader(title, subtitle, actions: FfCircleButton(s)) (pinned when searching / selecting)
│ ├ FfPeriodBar (if period-based)
│ ├ summary on the canvas: 2–3 figures (text.label + FfAmountText md, split), no card
│ ├ groups: pinned header (label + right-aligned totals, tabular) then rows in ONE compact card
│ │   (SliverPadding → DecoratedSliver(FfCard.decorationOf(context, density: compact)) → SliverList with FfDivider.inset)
│ └ bottom spacer so the FAB never covers the last row
```

Rows: leading `FfCategoryTile`/`FfIconTile` circle (40), `text.title`, metadata in `text.label` joined with " · ",
amount `FfAmountText(size: sm)` inline, spending neutral with "−", income green with "+". Wrap tiles that use
`InkWell` in a transparent `Material` so ripples draw above the card.

## C. Overview + item cards: Loans, Accounts, Savings goals, Investments, Subscriptions overview

Golden: Loans (`loans_screen.dart`, `screenshots/ds-b6/b6_loans.png`), Accounts (`b6_accounts.png`).

```
Scaffold (plain canvas)
├ FfAppBar(title, actions: FfPrivacyBadge)
├ FfHeroCard(tone by money kind, title: 'Total …', subtitle: counts) with FfAmountText(hero) + one quiet line
├ optional FfSegmentedPill (Active / Archived)
├ FfSectionHeader
├ item cards: FfCard(onTap) each with:
│   row: FfProgressRing(icon, value) [+ FfCornerBadge warning] · title (text.title) + subtitle (bodySm) · FfInkButton.open(small)
│   row: FfStatTile(label, FfAmountText lg split) · right column of text.label facts + FfBadge for status
│   line: "16% paid off" (text.label)
│   (simple items without progress → FfGroupedContainer of FfRow with FfIconTile instead)
└ closed/archived: FfGroupedContainer of FfRow
```

## D. Detail: Loan detail, Goal detail, Budget detail, Subscription detail, Investment detail, Transaction detail

Golden: Loan detail (`loan_detail_screen.dart`, `screenshots/ds-b6/b6_loan_detail.png`).

```
Scaffold (plain canvas)
├ FfAppBar(title: item name, subtitle: provider, actions: icon buttons for schedule/edit/delete)
├ FfHeroCard(tone, leading: FfProgressRing, title: the key question ('Left to pay'), subtitle: status)
│   └ FfAmountText(hero) · one quiet breakdown line · 3 small figures (FfHeroFigures)
├ attention: FfCard(variant: warning) / FfBanner with the corrective action (Pay, Mark paid)
├ progress card: FfCard → FfStatTile(big count + unit) + FfDotMatrix + counts line + FfMonthGrid (6 months)
├ trend card: FfCard → titleLg + FfLineChart (today's point selected)
├ details: FfSectionHeader + FfGroupedContainer of FfKeyValueRow
└ secondary actions: FfButton(outlined), privacy/trust note (FfCard tinted)
```

## E. Form / sheet: Add/edit transaction, loan, goal, budget, account…

```
showFfSheet → FfSheet
├ FfSheetHeader(title, subtitle, close)
├ scrolling body: FfAmountField (hero amount first when money is the point), FfChip rows for type choices,
│   FfTextField / FfSelect / date via pickFfDate, toggles as FfRow.toggle in FfGroupedContainer
├ live preview where useful (e.g. "₹6,500 a month · ₹217 a day")
└ FfSheetFooter with one primary FfButton (+ text button)
```

Full-screen forms (Add transaction) follow the same order inside a Scaffold with `FfAppBar`. No section labels in
ALL CAPS; use `text.label` sentence case.

### E1. Sheet system (DS-B20, approved by the owner 2026-11-14; screenshots in `../screenshots/ds-b20/`)

All sheets share **one skeleton**. The body follows **one of four archetypes**, chosen by the sheet's job. Each
domain keeps its own tone (the hero tone of its money kind), so a loan sheet still feels like Loans and a goal
sheet like Goals. Sheets do not all have to look the same, but they all have the same structure.

#### The skeleton (every sheet)

```
showFfSheet → FfSheet                          content-sized, grows to FfSheetTokens.maxHeightFraction (0.9)
├ FfSheetHeader                                handle · title · one-line subtitle · close (X)
│   hairline under it ONLY while the body is scrolled (FfSheetBody tells it)
├ FfSheetBody                                  scroll + standard padding (FfSheetTokens.paddingH)
│   └ FfSheetGroup(label:, children:) …         archetype A / B / C / D; itemGap inside, groupGap between
└ FfSheetFooter (A, B; optional for C)        one full-width primary FfButton; hairline only when body scrolls under it
```

| Rule | Detail |
|---|---|
| Title | Sentence case, `text.titleLg` (no bold override). "New loan", "Edit account", "Add repayment", "Notifications". Create → "New ‹thing›"; edit → "Edit ‹thing›"; add to an existing thing → "Add ‹thing›" |
| Subtitle | One short line saying what this sheet is for, not how to fill it, not privacy claims. `text.bodySm`, `textSecondary`. "A spending limit for one category", "Money you're setting aside for something" |
| Header trailing | Close X only. No privacy badges in sheet headers (the on-device cue lives on top-level screens) |
| Dismiss | The X, swipe down, or tap outside. **No Cancel button** |
| Footer | One full-width primary `FfButton`. A secondary action, if really needed, is `FfButtonVariant.text` above it. Destructive actions (Delete) sit at the end of the body as a text/destructive button, never in the footer |
| CTA verbs | Fixed: **Create** ‹thing› (new standalone object), **Add** ‹thing› (an item to a list or to an existing object: account, holding, repayment, money to a goal), **Save changes** (edit). Sentence case |
| Disabled CTA | Where a sheet already disables its CTA until valid, the label says what is missing ("Enter amount", "Enter account name"). Sheets that validate on tap keep doing so (behaviour unchanged) |
| Height | Content-sized, capped at 0.9. No sheet sets its own height |
| Colour | Tones from `context.ff.hero(...)` / `FfTone`; no literals |

#### Shared building blocks inside the body

| Block | Rule |
|---|---|
| Group label | `FfFieldLabel` (`text.label`, sentence case, `textSecondary`) above a chip row, tile grid or segmented pill. Never ALL CAPS, never letter-spaced, never bold `FfSectionHeader` inside a sheet |
| Text field | `FfTextField` with its **label above the box** (same `FfFieldLabel` style), hint inside, helper/error below. No placeholder-only fields, no notched/floating labels |
| Amount field | `FfAmountField`: the **₹ is always visible** (also when empty and unfocused), digits group as you type in the app's convention (Indian: 1,00,000.00), hint is `0` (never a fake example like "1,00,000"), value read back with `FfAmountField.parse`. Edit mode shows the stored value grouped ("3,246.32") |
| Choice | Chips (`FfChip`, wrap) for up to ~8 short options; icon tiles (`FfChoiceTiles`, 3-up grid, stacked icon over label by default, label may wrap to 2 lines, check in the corner, never truncated, never a horizontal scroller) for icon-led kinds (up to 9, as asset classes); `FfSegmentedPill` for 2–4 modes; more than 8 → a short row of likely options + "All ‹things›" that opens a Pattern C picker. Selected = ink fill; tiles also show a check. Horizontal chip scrollers only for suggestions (`FfSuggestionChips`), never for a required choice |
| Dates | Quick chips (Today / Yesterday / …) + a calendar chip that shows the chosen date |
| Live line | `FfConsequenceLine` under the input it explains |
| Optional extras | One collapsible "More details" row (`FfDisclosureRow`) at the end of the form |
| Gaps | `FfSpace.md` inside a group, `FfSpace.xl` between groups |

#### Archetypes

**A · Amount-first** — the amount *is* the point (one number the user types).
```
FfAmountHero(tone, label: 'Amount borrowed', consequence: live line)   ← first, autofocus on create
group label + choices / fields
FfDisclosureRow('More details')
```
Hero surface: `surfaceCard` with a **faint** tone wash (`FfTint.faint`) and no tinted border, so it reads as active,
not disabled. ₹ in the tone colour, digits ink. Used by: Loan, Budget, Goal contribution, Repayment, Advance,
Investment value update, Add transaction (reference).

**B · Entity** — the user is describing a *thing* with identity (name, kind, schedule, person).
```
FfEntityPreviewCard(tone, leading: icon | monogram, title, subtitle, figure, status chip)   ← live, not tappable
kind choice (tiles or chips)
name field, amount field, schedule…
FfDisclosureRow('More details')
```
The preview is the only place the figure is shown large; the amount input below it is an ordinary `FfAmountField`
(`md`). Preview surface is a solid comfortable `FfCard` with the domain tone on the leading tile and figure; the
**account** preview alone keeps its gradient (it is a miniature of the Home account hero). Empty name → a neutral
person/flag icon, never initials made from placeholder text. Used by: Account (moss), Savings goal (tide), Investment
(dusk), Subscription (sand), Lending record (rose).

**C · Choice** — pick one or several things and close.
```
optional FfTextField.search (more than ~10 items)
FfGroupedContainer of FfRow (selected → trailing check) | FfChoiceTiles | chips
footer only when the choice is multi-select or must be confirmed ("Show 24 transactions", "Apply")
```
Used by: `FfSelect`, period chooser, category / account pickers, payment account picker, filter & sort, theme and
currency pickers, recurring suggestions, CSV column mapper.

**D · Settings** — toggles that apply immediately.
```
group label + FfGroupedContainer(FfRow.toggle …)   ← no footer, changes save as they happen
```
Used by: Notifications (alert settings). The guided PIN sheet is a Pattern G flow inside the skeleton.

#### Domain tones in sheets

| Sheet | Archetype | Tone |
|---|---|---|
| Account | B | moss (gradient preview) |
| Savings goal / contribution | B / A | tide |
| Investment / value update | B / A | dusk |
| Loan | A | rose (`FfTone.debt` on the hero) |
| Budget | A | rose (plan) |
| Subscription | B | sand |
| Lending record / repayment / advance | B / A | rose; lent vs borrowed shown by icon + words |
| Notifications | D | none |

## F. Settings-style: Settings, Security, Backup, Export, Alert settings

```
Scaffold (plain canvas) → FfAppBar → sections: FfSectionHeader + FfGroupedContainer(FfRow / FfRow.toggle …)
```

No heroes, no aurora. Destructive rows use `FfRow(destructive: true)` and `FfDialog.confirmTyped`.

## G. Secure / onboarding: Lock, onboarding, permission screens

Calm full-screen layouts on `surfacePage` (lock screen on `surfaceInk`), display roles (light Geist) for the
title, one primary `FfButton`, privacy copy. Onboarding may use `FfAurora`.

## States every screen must handle

Loading (skeletons shaped like the content), empty (`FfEmptyState` with the next action), error (`FfEmptyState` with
"Try again"), amounts hidden (`isBlurred` everywhere), 2× text (no overflow; split amounts shrink), dark mode,
reduced effects, RTL (`EdgeInsetsDirectional`), and 48 dp targets with semantic labels.
