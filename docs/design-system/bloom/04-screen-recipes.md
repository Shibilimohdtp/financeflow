# 04 · Screen recipes

Every screen is one of these patterns. Pick the pattern, follow its anatomy top to bottom, and copy structure from
the golden screen named. Spacing between blocks is `FfSpace.md` (16) inside a group and `FfSpace.lg`–`xl` (20–24)
between groups; the page margin is always `FfSpace.pageMargin`.

## A. Hero tab (top-level summary): Home, Plan/Budgets, Insights

Golden: Home (`dashboard_screen.dart`, `screenshots/ds-b4/home.png`).

```
FfAurora
└ Scaffold(backgroundColor: transparent)
  ├ header drawn on the aurora (no bar fill): label line + title, FfPrivacyBadge, FfCircleButton(s)
  │   (see HomeHeader: PreferredSizeWidget + SafeArea + AnnotatedRegion for status-bar icons)
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
Scaffold (plain surfacePage, NO aurora)
├ FfAppBar(title) with actions: FfCircleButton(s) (filter with FfCorner.dot when active), FfPrivacyBadge(iconOnly)
├ search pill (outlined stadium, 48 dp, opens FfAppBar.search) — only if the list is searchable
├ FfPillBar / FfChip row for the most-used filter
├ FfPeriodBar (if period-based)
├ summary on the canvas: 2–3 figures (text.label + FfAmountText md, split), no card
├ groups: pinned header (label + right-aligned totals, tabular) then rows in ONE compact card
│   (SliverPadding → DecoratedSliver(FfCard.decorationOf(context, density: compact)) → SliverList with FfDivider.inset)
└ bottom spacer so the FAB never covers the last row
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
│   └ FfAmountText(hero) · one quiet breakdown line · 3 small figures (label above, labelLg value, tabular)
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
