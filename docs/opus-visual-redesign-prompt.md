# Prompt: Re-skin the Stillwater design system to a new visual direction (paste into a new Claude Code chat on Opus)

---

You are a senior product designer and design-systems engineer working on **FinanceFlow**, a fully local, privacy-first personal finance app (Flutter, Material 3, Riverpod, Isar). The shared design system (**Stillwater**: tokens, `context.ff`, one theme builder, shared `Ff*` components) has been built over the last sessions. Your job now is to **give it a new, more modern and elegant visual direction by changing the system itself, not by hand-editing screens**, so the whole app picks it up.

## Step 0: read before anything else

1. `AGENTS.md` (backup gate, standalone-startup gate, and the **UI and design-system work** section).
2. `docs/design-system/CHANGELOG.md`: slice status, the **In flight** table, and Decisions. Add your work to the In flight table when you start and update the log in the commit that finishes it. Another chat (Budgets) owns `lib/features/budgets/`, `lib/services/budgets/`, `lib/models/budget.dart`, `lib/core/money/money_math.dart`: do not touch them.
3. `docs/design-system/00-audit-and-proposal.md`, `README.md`, `lib/theme/` (tokens, palettes, `FfTheme.build`), `lib/shared/widgets/`, and `test/theme/` (parity, accessibility and contrast guardrails).
4. **The reference images** in `docs/design-system/reference/` (12 files; the large `We turned «loan management»...jpg` is the best overview, the numbered `.jpg`s are close-ups). **Look at every one of them with the image viewer before designing.** They are a mood and component reference from a designer's concept for a loan/credit-score app. Use them as strong inspiration and keep the overall look and feel, but make it our own (see "How closely to follow the reference" below): no copying their layouts pixel for pixel, their names, brands, copy, or photography/backdrops.
5. Process rules from earlier sessions (see memory): format only the files you touched (never `dart format lib`), and commit only your own paths with `git commit -- <paths>`, because the working tree is shared with other chats.

## How closely to follow the reference (important)

Do **not** copy the reference blindly or reproduce it screen for screen. Treat it as **strong inspiration**: the finished system should still clearly *feel* like this design (the airy aurora canvas, big squircle cards, grainy gradient hero cards, light oversized numerals, ink-black pills plus one electric accent, dot-matrix and lime-bubble data viz, glass pills and a floating dock), but with **deliberate, slight changes that make it FinanceFlow's own**. Someone who saw both should recognize the same family of design, yet see ours as a distinct product with its own identity.

Ways to make it ours (propose your own too, and show them in the proposal):
- Our palette and hero gradients derived from Lichen (olive, mushroom, mineral rose) with our own accent tuning, instead of the reference's exact colors.
- Our own signature details: for example a custom shape/corner personality, a distinctive progress motif, our own icon style and illustration-free card patterns, and our own take on the dock and glass pill.
- Our own type pairing and numeral treatment tuned for money (tabular figures, currency/locale handling, dense-row variants).
- Finance-appropriate adaptations: calmer lists, privacy cues ("on-device" badge), income/expense/transfer semantics, accessibility upgrades.
- Restraint: use the flashy elements (grain, blur, glass, lime) where they add meaning, and keep everyday screens clean.

In the proposal, add a short **"Inspired by / Made ours"** table: for each major reference element, say what we keep, what we change, and why. Aim for roughly "same spirit, about 70-80% recognizable, with our own signature on top"; if you think a different balance serves the app better, say so and let me decide.

## What the reference shows (my reading of it; verify against the images)

**Overall feel:** airy, premium, tactile, quietly playful. A bright canvas, very large soft shapes, few colors, huge light numerals, and one electric accent.

- **Canvas:** near-white with a soft pastel "aurora" wash (lavender, peach, mint) fading across the page, not a flat color. Cards float over it.
- **Shape language:** very large-radius *squircle* (superellipse) cards, roughly 36-48 dp on hero/summary cards, with no hard borders; surfaces are separated by shadow, tone and space. Circular outline icon buttons (back, more) with a hairline stroke. Pills for filters and search.
- **Hero cards:** rich gradient surfaces with fine film grain (olive-to-lime green, dusty rose-to-peach), white type on them, a thin ring icon at top-left, and a dark circular "↗" action button at top-right. A soft inner highlight on the edge gives them a glassy, pillowy feel.
- **Typography:** a clean grotesk in light and regular weights (not bold). **Large numerals with small, lighter unit parts**, e.g. `24` + `/38`, a small `$` before `12.340`, `23` + `%`. Labels are small and gray-toned; titles are regular weight, large and calm. Some labels in a slanted/italic style in one variant.
- **Accent:** a single electric **lime/chartreuse** used sparingly for the active marker, chart tooltip bubble, check badges, small counters and highlights, always as a fill with **dark ink** on it, paired with near-black (ink) for primary pills, arrow buttons and the selected tab. Warning states use a small orange triangle badge on the icon corner.
- **Selection pills:** selected = solid near-black pill with white text; unselected = transparent with hairline outline.
- **Data viz:** thin strokes, tiny dots, faint dashed gridlines, a **lime value bubble** on the selected point with a dashed vertical guide and a small triangle marker on the axis; **range bands** (pastel red/amber/green rounded segments with scatter dots) with a marker line; **dot-matrix progress** (rows of dots that fill in) instead of bars; stepped dotted bar textures on hero cards; a **month-grid timeline** of rounded tiles with lime check or "x" circles.
- **Glass:** frosted translucent pills and bars (e.g. "Recent Changes", "Create Dispute") over gradients; a **floating dock** navigation made of circular icon buttons with the selected one filled black.
- **Icons:** thin (about 1.5 px), rounded, outlined, set in circular tiles.
- **Motion cues implied:** carousels of cards peeking from the right edge, the lime bubble sliding along a chart, dots filling in.

## Why this is feasible quickly

Because DS-1 to DS-5c are done, color, type, radius, spacing, elevation and the shared components all flow from `lib/theme/` and `lib/shared/widgets/`. A new look should be mostly **new token values, a new palette, a few new style primitives, and targeted component changes**, followed by screen migration (DS-7), which picks it up. Where the reference needs genuinely new things (gradient grain cards, dot-matrix progress, lime tooltip chart, floating dock, glass pill), add them as **shared components**, not per-screen code.

## Decisions to make with me (propose, recommend, then wait for my answer)

The changelog records that "the current Lichen look stays the default identity (refined, not replaced)". Notably, the reference's olive-lime gradient card is close to Lichen green, so a natural direction is an **evolution of Lichen**, not a switch. Present options with rendered previews and give a recommendation:

- **A. Evolve Lichen into this style** (recommended starting point): airy aurora canvas, lichen-to-lime hero gradients, ink black and a lime accent, large squircles, light numerals. One new default look, plus the existing alternates (Tide, Graphite) re-skinned in the same language.
- **B. Add it as a separate palette/style preset** (a "Studio" or similar, switchable in settings) and keep today's look as the default until I decide.
- **C. Hybrid**: new shape/typography/components for everything, palette stays Lichen with only the lime accent added.

Also decide with me:
- The typeface. The reference looks like a light grotesk (neo-grotesque; similar in spirit to Neue Montreal/Inter Display/General Sans). Recommend **one open-licensed (OFL) family with light/regular/medium weights and tabular figures**, bundled in `assets/fonts/` with its license in the README there (as done for Manrope/Fraunces). Compare Manrope (already bundled) at light weights against 1-2 candidates in a rendered type specimen before choosing. Fraunces may be dropped or kept for moments only if it still fits.
- Whether the "big numeral + small light unit" treatment becomes the standard for every money display (via `FfAmountText`), and how it degrades for dense rows (transaction lists need a calmer, smaller, still-tabular style).
- Whether glass/blur and grain are used on hero surfaces only (recommended) or more widely.

## Hard constraints: make it beautiful *and* usable

This is a finance app used daily, often one-handed, on mid-range Android phones. The reference is a marketing concept, so adapt where needed:

- **Accessibility is not optional.** Lime on white fails contrast: use lime only as a *fill* with dark ink text on it (never lime text on light). Hairline-gray labels on gradients must still meet contrast: the existing `test/theme/palette_accessibility_test.dart` ratchet must stay green, with the new pairs (text on gradient hero cards at their lightest and darkest points, text on glass, ink on lime) added to `FfContrastRules`. Keep the income-vs-expense colour-blindness separation. Never rely on color alone for status. Keep 48 dp touch targets. Support large font scaling and clamp big hero numerals so they never overflow.
- **Light and dark.** Design the dark counterpart properly (deep ink canvas with a subtle dark aurora, lime accent, the same squircle language), plus the optional pure-black variant already in the plan. Every palette in both modes.
- **Performance.** Blur (`BackdropFilter`), large gradients and noise textures are expensive on low-end devices and inside scrolling lists. Use them only on a few hero surfaces, prefer pre-rendered/pre-baked gradients and a small tiled grain PNG over runtime shaders, avoid blur inside `ListView` items, add a reduced-effects fallback (solid surfaces) when the platform reports reduced motion/transparency or low performance, and measure frame times on the real device if I connect one.
- **Squircles.** Check the installed Flutter version for `RoundedSuperellipseBorder`/`ContinuousRectangleBorder`; implement one shared `FfShape`/shape token so the whole app switches shape language from one place.
- **Density.** The airy look must not turn the transactions list into a sparse one. Define two density modes for rows and cards (comfortable for summary and hero areas, compact for lists), both token-driven.
- **Offline-first.** No network fonts or images at runtime.
- **Brand independence.** Don't import any logos, bank names, or photography from the reference. Imagery in the app is generated by tokens, gradients and icons.

## Deliverables and process

1. **Do not start coding.** Enter plan mode. Examine the images, the theme, and the components. Run `flutter analyze`, the theme tests, and `dart run tool/design_system_audit.dart --shared` to record the baseline.
2. Return a **proposal** containing:
   - a one-paragraph design direction and its principles,
   - the **"Inspired by / Made ours"** table described above (what we keep, change and add as our own signature),
   - the **palette**: aurora canvas stops, card/surface tints, ink, lime accent, hero gradient pairs (green, rose/peach, and 1-2 more for account/loan/goal variety, assignable by tone/category), semantic status colors, light and dark. Render it as an HTML/PNG preview with contrast numbers (the repo has `docs/design-system/palette_render.py` and `palette_check.py` to build on),
   - the **type scale** with a specimen showing the big-numeral + unit treatment,
   - the **shape, elevation, blur and grain tokens**,
   - the **new and changed components** with proposed APIs: hero gradient card, squircle card, circular outline icon button, ink action button (the ↗), pill filter row, glass pill/bar, dot-matrix progress, range-band meter, lime-bubble chart with dashed guide, month-grid timeline tile, floating dock navigation (and how it coexists with the current bottom navigation and the 5-tab structure), stat tile with unit suffix, badge with warning corner, carousel with peeking cards,
   - **mock screens**: render at least three real FinanceFlow screens (Home/dashboard, Transactions list, an Accounts or Loans detail) in the new language as images or a gallery page using the real components, light and dark,
   - the **slice plan** that fits the changelog (which existing slices change: DS-6 data display/charts and DS-8 refinement absorb most of this; DS-7 screen migrations follow), risks, and what is deliberately not copied,
   - questions for me with recommendations.
   Wait for my approval before building.
3. Then build in small committed slices, each ending with analyze, tests, guardrails and the leakage script green, a before/after screenshot set (`tool/screenshots/` and `compare.py` exist), and a CHANGELOG update:
   - tokens + palette + type + shape (no screen edits),
   - component changes and new components with widget tests (light/dark/each palette, large text),
   - the gallery updated so every new token and component is visible,
   - then screen-by-screen migration of the high-traffic screens first (Home, Transactions, Accounts), leaving Budgets for its own chat.
4. **Proof of the goal:** after the token slice, show that changing one token (accent color, card radius, base spacing) restyles the app everywhere without other edits.

## Hard repo rules (from `AGENTS.md`)

- **Backup gate:** before any step that could affect existing user data or a real-device install (adb install, schema or generated-file changes, migrations, reset/restore), STOP and ask me to personally create and verify an encrypted FinanceFlow backup and keep the file and passphrase; wait for my explicit confirmation. Never create one for me. Never run `adb uninstall`, `adb shell pm clear`, or `flutter install`; use `adb install -r` only.
- **Standalone-startup gate:** adding fonts/assets/noise textures or changing `pubspec.yaml` is a build-configuration change: keep `main()` synchronous through `runApp`, run `flutter analyze` and the affected tests (including `test/widget_test.dart`), build both `flutter build apk --debug` and `--release` (Windows retry: `JAVA_TOOL_OPTIONS=-Djdk.net.unixdomain.tmpdir=.`), and run `./tool/verify_debug_startup.ps1 -Serial <device>` without `flutter run` attached once a device is available (it may still be pending from DS-3; say so).
- Persist any theme/style choice in the existing `AppSettingsEntity.themeMode` string (no Isar schema change, per the recorded decision); if you need more, ask me first.
- Never log financial data. Environment: Windows 11, PowerShell.

Verify UI visually (emulator, golden screenshots, or the built-in browser) and say plainly what you could not verify.

**Start now with step 0 and step 1-2 only: look at the images, read the system, record the baseline, and return the proposal for my approval.**
