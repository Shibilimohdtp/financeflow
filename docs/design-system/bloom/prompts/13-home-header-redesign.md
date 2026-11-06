# Prompt: Home header redesign (DS-B13)

Paste everything below the line into a new Claude Code chat (Opus 5.5).

---

You are the lead product designer and Flutter engineer for **FinanceFlow** (Flutter, Riverpod, Isar; fully local,
privacy-first, no backend). The app uses one design system, **Stillwater**, in its **Bloom** visual language.

Your job is to redesign the **Home screen header (the app bar)** into something better. Today it is a single row on
the aurora: a small greeting-and-date line, the "FinanceFlow" wordmark in large type, an **"On-device" shield pill**,
and a bell button. The owner does **not** want the on-device shield pill or any widget like it in the header. Beyond
removing it, this is a real design task: the header is the first thing seen on the app's most-used screen, and it
should feel personal, calm and premium, set the tone for the balance hero right below it, and earn every element.

## Read first, in this order (binding)

1. `AGENTS.md` (backup gate, standalone-startup gate, UI section).
2. `docs/design-system/bloom/README.md`, then `01-direction.md`, `02-foundations.md`, `03-components.md`,
   `04-screen-recipes.md` (pattern A), `05-screen-status.md`, `06-workflow.md`.
3. `docs/design-system/CHANGELOG.md`: In flight, Decisions, Done rows for DS-B1…B6.
4. Golden screenshots: `docs/design-system/screenshots/ds-b4/home.png` (current header and hero),
   `ds-b3/bloom_components.png`, `ds-b5/money.png` (how another tab titles itself), `ds-b6/b6_accounts.png`.
5. Code:
   - `lib/features/dashboard/widgets/home_header.dart` (102 lines; `HomeHeader implements PreferredSizeWidget`, takes
     `unreadAlerts`, `onOpenAlerts`, and an `onOpenSettings` that is **currently unused**)
   - `lib/features/dashboard/dashboard_screen.dart` (486 lines; places it as the `Scaffold.appBar` inside `FfAurora`;
     also owns the FAB `Add`, the pull-to-refresh and the scroll view)
   - `lib/features/dashboard/widgets/total_balance_hero.dart` (the card directly below; it already has the
     privacy-blur toggle)
   - `lib/shared/widgets/ff_round_buttons.dart` (`FfCircleButton`, `FfCorner`), `ff_corner_badge.dart`, `ff_surfaces.dart`
     (`FfAurora`, `FfGlass`), `ff_navigation.dart` (`FfDock`), `ff_app_bar.dart` and how Money, Insights, Plan and More
     title themselves, so Home and its sibling tabs stay one family
   - `lib/app/router.dart` (shell, tab labels), `lib/core/formatting/date_formatter.dart`
   - tests: `grep -rln "HomeHeader\|On-device\|Alerts & Reminders\|FfPrivacyBadge" test lib` (find every test or
     widget that depends on the header or the privacy badge).

## What exists today (verify, do not trust)

- Left: `"{Good morning|afternoon|evening} · {full date}"` in `labelSm` / `textSecondary`, then **FinanceFlow** in
  `titleLg`. Right: `FfPrivacyBadge('On-device')`, then a soft `FfCircleButton` bell with an alerts dot.
- It is not tied to scrolling: it is a fixed app bar, so it eats vertical space while the person scrolls past the
  balance hero. The wordmark repeats on every visit and carries no information. `onOpenSettings` is unused.
- Other tabs use their own title treatment (check Money, Plan, Insights, More) and the `FfPrivacyBadge` is also used
  elsewhere (Accounts, Insights). **Only remove it from the Home header** unless I say otherwise; do not delete the
  shared widget if other screens use it.

## Design brief

Explore at least three directions in your plan with a described layout for each (and a recommendation), then build
the one I approve. Directions to consider, you may propose better:

- **A. Personal greeting header.** Large, light-weight greeting as the title ("Good evening"), date as the quiet
  subline, no wordmark. On the right: the alerts bell and a **hide-amounts eye toggle** (the same privacy-blur action
  the hero has today, so it is reachable without scrolling back up; if both stay, they stay in sync and the hero keeps
  its own for context, justify). If the app stores a user name, use it (`grep` the settings and onboarding for one);
  if not, do not invent one.
- **B. Collapsing header.** The header is part of the scroll view: a large greeting that scrolls away with the page and
  a slim glass bar that fades in (title + bell) once the hero is off screen. Weigh the cost: `FfGlass` blur is allowed
  only on a few surfaces, so decide whether the collapsed state uses blur or a plain surface, and make a reduced-effects
  fallback.
- **C. Tight utility row.** No title at all: a one-line date/greeting on the left and two round buttons on the right,
  so the balance hero is the first big thing. The least chrome, the most content.

For whichever you recommend, decide and justify:

1. **Identity without the shield.** The privacy-first promise is the product's core, but it should not be a pill on
   every visit. Propose where it lives instead (the More tab vault card from DS-B9, the hero's hide-amounts state, or a
   one-time first-run cue). Record that decision in `CHANGELOG.md` Decisions. Do not add any replacement badge to Home.
2. **Wordmark.** Keep a small "FinanceFlow" mark or drop it? If kept, it is a quiet element (not `titleLg`), and the
   greeting leads.
3. **Right-hand actions.** Bell with the unread dot (keep the tooltip text `Alerts & Reminders, N unread` and the
   48 dp target), plus at most one more action. Candidates: hide amounts, search (jump to Money search), settings
   (use the unused `onOpenSettings` or delete it). Every action must justify its place; two is the limit.
4. **Greeting logic.** Time-of-day greeting boundaries (today: <12, <17, else), locale-safe date, updating if the app
   stays open across a boundary or midnight (a minute timer is fine if cheap, or refresh on resume), and wording that
   respects the calm voice in `01-direction.md` (no exclamation marks, no emoji).
5. **Scroll behaviour and space.** Decide fixed vs scrolling vs collapsing, and show the effect on the first-screen
   content: the balance hero and the start of the accounts carousel should be visible without scrolling on a typical
   phone (about 360×800 dp), at 1× and at 1.3× text.
6. **Status bar and aurora.** The system UI overlay style follows light/dark (exists today); the header must be correct
   in light, dark and with a large cutout or gesture-navigation insets.
7. **Interaction.** Pull-to-refresh and the FAB are unchanged. Tapping the greeting does nothing unless you propose
   something useful (for example opening a month/period or profile) and I approve it.

## Hard constraints

- Behaviour and data unchanged: alerts count, `onOpenAlerts`, privacy blur setting (`setPrivacyBlurEnabled` through
  `settingsControllerProvider`). No Isar schema, generated-file or provider-bootstrap changes (backup gate; stop and
  ask me). Never log financial data. Do not add network, analytics or tracking.
- Only shared `Ff*` components and tokens. No raw colours, sizes, radii or `TextStyle(`. If you need a new shared piece
  (for example a collapsing `FfLargeHeader` that Money and Insights could reuse later), build it as a shared component
  with a test, a component-sheet screenshot and a `03-components.md` entry. Share it only if at least two tabs will
  plausibly use it, and say which.
- Accessibility per `01-direction.md`: 48 dp targets, contrast on the aurora in light and dark (the ratchet stays
  green), semantics that read the greeting and date once, correct heading semantics, text scale 2× without overflow or
  clipped actions, tooltips on icon buttons, no colour-only unread indicator (keep the unread count in the tooltip and
  semantics).
- Performance: no new blur on the always-visible bar unless justified, with a reduced-effects fallback; no continuous
  animation; a collapsing header must not rebuild the whole page per scroll tick (use a scroll controller driven
  `AnimatedBuilder`/sliver, not `setState`).
- Keep keys, tooltips and semantics that tests rely on, or update those tests in the same commit and say why. Remove
  any test that asserted the On-device pill on Home, and replace it with one that asserts its absence.
- Format only files you touched. Never `dart format lib`. Commit only your paths. Windows 11, PowerShell and Git Bash.

## Coordination

- Another chat may be redesigning the Home **widgets** (DS-B12: cash flow, budgets, goals, actionable). You own
  `home_header.dart` and the app-bar part of `dashboard_screen.dart`; they own the widgets and the body order. Make a
  minimal edit in `dashboard_screen.dart` (the `appBar:` / header slot and, for a collapsing header, the scroll view
  wrapper) and re-read the file right before you edit it. In `05-screen-status.md` and `CHANGELOG.md` change only your
  own rows. Commit only your paths.

## Slices (one commit each)

- **B13a** Header v2 on the approved direction, the shield pill removed, tests updated.
- **B13b** If chosen: collapsing behaviour, reduced-effects fallback, scroll tests.
- **B13c** Polish: states matrix, screenshots, status and changelog.

## Verification

- Before / after screenshots with `tool/screenshots/compare.py`, light and dark, for: top of Home at 1×, at 1.3× and
  2× text, with and without unread alerts, with amounts hidden, scrolled (for a collapsing header: mid-collapse and
  fully collapsed), and a narrow 320 dp width. **Open the PNGs and look at them**; compare the first-screen content
  against `ds-b4/home.png`.
- Widget tests: greeting boundaries by injected clock, bell tooltip with and without unread, action callbacks, the
  absence of the On-device pill, collapse behaviour. Full suite green, analyze clean, audit numbers not up.
- Say plainly what you could not verify (device status-bar overlay, real scroll feel).

## Start

Do steps 0–1 of `06-workflow.md` only. Read, take the baseline (`flutter analyze`, dashboard tests, the audit, current
screenshots), then return:

1. A map of the current header and everything that depends on it (callers, tests, the shared badge's other users).
2. Three header directions, each with a described layout, what it does on scroll, and its pros and cons, and your
   recommendation.
3. Where the privacy-first message moves to, what happens to the wordmark and the unused settings callback, and the
   first-screen content you will gain.
4. Missing shared pieces, test changes, risks, and questions.

Wait for my approval before building anything.
