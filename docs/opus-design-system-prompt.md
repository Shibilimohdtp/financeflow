# Prompt: Evolve the design system into a single-source-of-truth, fully reusable component library (paste into a new Claude Code chat on Opus)

---

You are a senior design-systems engineer and visual designer working on **FinanceFlow**, a fully local, privacy-first personal finance app (Flutter, Material 3, Riverpod, Isar). The UI was written by a weaker model across many sessions, so it feels like ten different designers built it. Your mission is to **evolve the existing design system into a better version of itself (same character, higher polish) and make it the one and only source of truth**, so that changing one line in the design-system files changes the look of the whole app, and so that every repeated UI pattern is a reusable widget.

Read `AGENTS.md` and `docs/features/FinanceFlow_Design_System.md` (the original Stillwater spec) first, then `docs/features/FinanceFlow_PRD.md`.

## Major focus (in priority order)

1. **One root of truth.** All visual decisions (color, typography, spacing, radius, borders, elevation, opacity, motion, sizes, icon sizes, component dimensions) are defined in `lib/theme/` and nowhere else. Feature code contains zero visual literals.
2. **A complete reusable component library.** Every repeated UI pattern becomes a shared widget with a consistent API, even where behavior differs (use slots, variants and callbacks).
3. **Consistency.** After the work, a new screen assembled only from shared components and tokens should automatically look native to the app.
4. **A refined look**: the same calm, warm, private personality, but cleaner, more modern, better contrast and hierarchy, and a small set of switchable color themes.

## Current state (verified from the code)

Theme files in `lib/theme/`: `stillwater_tokens.dart` (spacing from 2 to 56dp, radii, borders, component heights, durations, easing, opacities, breakpoints), `stillwater_colors.dart` (hand-written light "Daylight" and dark "Deep Water" palettes with lichen-green primary, mushroom secondary, mineral-rose accent, financial colors for income/expense/savings/debt/investment/transfer, status colors, plus `ThemeExtension`s `FfFinColors`, `FfStatusColors`, `FfAccentColors`), `stillwater_typography.dart`, and `stillwater_theme.dart` which builds `ThemeData` for light and dark with duplicated, near-identical code for each (about 250 lines each).

Naming is inconsistent: files and classes say "Stillwater", docs say deep teal / sand / marigold, but the actual palette is lichen green / mushroom / rose and one comment says "Lichen Ledger". Pick one product-facing design-system name, confirm it with me, and rename consistently (files, classes, docs, `branding_preview_screen.dart`).

Shared widgets exist in `lib/shared/widgets/` (`ff_button`, `ff_card`, `ff_chip`, `ff_snackbar`, `ff_confirm_dialog`, `ff_sheet_header`, `ff_sheet_footer`, `ff_list_row`, `ff_section_header`, `ff_segmented_pill`, `ff_empty_state`, `ff_skeleton_loader`, `ff_amount_field`, `ff_amount_text`, `ff_category_tile`, `ff_grouped_container`, `ff_period_bar`, `ff_switch_row`, `ff_privacy_badge`, `ff_source_badge`, charts, bottom nav). That is a good start: tokens are used heavily (about 1,700 references across 89 files).

**Measured leakage outside `lib/theme/` (this is the work):**
- 600+ uses of `Colors.*` in 67 files; ~180 `withOpacity`/`withValues` calls in 55 files (ad-hoc alpha instead of tokenized tints); 22 raw `Color(0x...)` literals (`models/category_colors.dart`, `branding_preview_screen.dart`).
- ~190 raw `fontSize:` values and ~50 raw `TextStyle(` constructions in 25 files; `GoogleFonts.` used outside the typography file.
- ~270 `BorderRadius.circular(...)` in 74 files; ~50 hard-coded `EdgeInsets` numbers and ~96 hard-coded `SizedBox` sizes; 6 inline `Duration(milliseconds: ...)`.
- 42 raw `AppBar(` constructions in 33 files, ~30 `showModalBottomSheet` calls in 23 files with no shared helper, 3 `AlertDialog` and 3 `showDialog`, 14 `showDatePicker`, 24 dropdown/popup menus, 86 `Divider(`, and 14+15 raw circular/linear progress indicators.
- Only ~2 uses of `Theme.of(context).colorScheme`; most color access goes straight to static `StillwaterColors.*` constants (74 uses in 6 files). Static access cannot follow theme switching, so a multi-theme system needs context-based access.

Treat these numbers as a starting audit and re-measure them yourself.

## Architecture to build

1. **Token layers** (a proper design-token pipeline):
   - *Primitive tokens*: raw palette ramps (e.g. lichen 50-950), neutrals, status hues, type scale values, spacing/radius scale.
   - *Semantic tokens*: role-based names used by UI (`surface.page`, `surface.card`, `text.primary`, `border.subtle`, `action.primary`, `money.income`, `status.warning`, `focus.ring`, ...). UI code may reference only semantic tokens.
   - *Component tokens*: per-component dimensions and styling decisions (button heights, card padding, sheet radius, app bar height, chip padding, input style).
   - Expose them through a single `ThemeExtension` (or a small set) read as `context.ff.*` (or similar short, ergonomic API) so tokens follow the active theme. Keep `ColorScheme`/`ThemeData` in sync from the same source so stock Material widgets also pick up the system automatically.
2. **Generate light and dark from one definition** instead of duplicating 250 lines twice. Theme building should be driven by a `ThemePalette`/`AppTheme` definition object plus a brightness, so adding a new color theme means adding one palette object, nothing else.
3. **Color themes**: keep the existing Lichen light and dark as the default identity (refined, not replaced), and add a small curated set of alternative palettes (e.g. a cool blue-teal "Stillwater" water theme, a warm sand/terracotta theme, a graphite/monochrome theme, optionally an OLED black dark variant and a high-contrast mode). Support system / light / dark mode and a theme picker in settings with live preview, persisted in app settings. Every palette must pass contrast checks (WCAG AA for text, 3:1 for UI boundaries and focus) and include correct financial semantics (income/expense/transfer/savings/debt/investment) that remain distinguishable and not color-only (icons and signs too), including for common color-vision deficiencies. Add an automated test that computes contrast for every semantic text/surface pair in every palette and fails the build on regressions.
4. **Typography**: one type scale with named roles (display, headline, title, body, label, plus money-specific roles with tabular figures), defined once; fonts loaded through one place (decide with me between bundled font assets, which is better for an offline-first app and removes runtime network fetches from `google_fonts`, and keeping `google_fonts`; I recommend bundling). Respect system font scaling and set sane max scale clamps for dense money rows.
5. **Elevation, shape, motion, iconography**: tokenized shadow/elevation levels (or tonal elevation in dark), one icon set and fixed icon sizes, standard motion durations and curves, reduced-motion support, press/hover/focus/disabled state layers defined once.
6. **Enforcement so it stays unified**: add lint-style guardrails, not just conventions.
   - A custom analysis check or a small test (`test/guardrails/design_system_test.dart`, scanning `lib/` outside `lib/theme/` and `lib/shared/`) that fails on `Color(0x`, `Colors.` (except an allowlist like `Colors.transparent`), raw `TextStyle(`/`fontSize:`, `GoogleFonts.`, `BorderRadius.circular(<number>)`, hard-coded `EdgeInsets`/`SizedBox` numbers, inline `Duration(milliseconds:`, `showModalBottomSheet`/`showDialog`/`showDatePicker`/`ScaffoldMessenger`/`AppBar(` outside the shared wrappers.
   - Keep a short, honest allowlist file for justified exceptions (e.g. chart internals, user-chosen category colors), each with a reason.
   - Document the rules in `docs/design-system/` and in `AGENTS.md` (a short "UI rules" section).

## Reusable widgets to create or consolidate

Every item below should be a shared widget or helper with one consistent look, driven only by tokens. Audit existing ones first and extend them; delete near-duplicates; migrate every call site.

- **Feedback**: snackbar/toast (success, info, warning, error, with undo action), banner (inline, dismissible), inline error/helper text, confirm dialog, destructive confirm (with typed confirmation option), info dialog, progress dialog, empty state, error state with retry, loading/skeleton variants.
- **Overlays**: one `showFfBottomSheet` helper (drag handle, header, scroll behavior, keyboard insets, safe areas, max height, footer actions), a full-screen modal route helper, action sheet / menu sheet, popup menu, date and date-range picker wrappers, time picker wrapper, color/icon pickers if repeated.
- **Navigation/structure**: a single `FfAppBar` (standard, large collapsing, search, selection mode variants), `FfScaffold`/page template (consistent padding, background, safe areas, max content width for tablets), bottom nav, tab bar, segmented control, section header, divider, list/group containers, settings row with all the common trailing types (switch, chevron, value, badge).
- **Inputs**: text field (+ search field, password/PIN field), amount field, dropdown/select (replacing raw `DropdownButton`s), multi-select chips, filter chip groups, date field, switch/checkbox/radio rows, slider with labeled value, stepper, keypad.
- **Actions**: button variants (primary, secondary, tertiary, destructive, icon, FAB, extended FAB, loading state), chips (assist, filter, input), swipe action backgrounds.
- **Data display**: card variants (flat, elevated, tinted, outlined, interactive), list tile/row, avatar and category icon tile, amount text (income/expense/neutral with sign rules), progress (linear, circular, segmented, with pace marker), status badge/pill, stat tile/KPI, key-value row, timeline/stepper, charts' shared chrome (axes, legends, tooltips, colors from semantic tokens).
- **Screen patterns**: page header with period selector, detail-screen header, form-screen layout with sticky footer, onboarding step layout, lock/PIN screen layout.

For each component: a clear API with sensible defaults, variants as enums, no style params that bypass tokens (offer a small, intentional set of semantic "tone" options instead), semantics/accessibility built in, light/dark/all-theme golden-style or widget tests, and a dartdoc comment.

## Living style guide

Replace/extend `branding_preview_screen.dart` into a developer-only **Design System Gallery** screen (hidden behind a debug/dev flag, excluded from release or tucked in a non-production route) that renders every token (colors with names and contrast ratios, type scale, spacing, radii, elevations, motion samples) and every component in every variant and state, with a live theme/mode switcher. This is how we verify that a one-line token change ripples everywhere. Also produce `docs/design-system/` with: principles, token reference, component catalog with usage do/don't, how to add a new palette, how to add a component, and the migration checklist.

## Proof of the goal

Include a demonstration in your final report: change one token (e.g. the primary color, the card radius, and the base spacing unit) and show, via screenshots of at least 8 different screens, that the entire app updates with no other edits. Revert afterwards.

## Migration strategy (the codebase is ~64k lines; do it safely)

- This is a refactor with **no intended behavior change**. Tests must stay green throughout; add golden or widget tests for the shared components rather than rewriting feature tests.
- Order: (1) audit and proposal, (2) token architecture + theme generation + semantic color access via context, keep old static constants as deprecated shims so nothing breaks, (3) component library, (4) migrate screens feature-by-feature in small committed slices (start with shared/most-used screens: transactions, dashboard, budgets, then the rest), (5) remove shims, turn on guardrail tests, (6) visual refinement pass and new palettes, (7) gallery and docs.
- Coordinate with ongoing work: other chats may be rebuilding the transactions screens and the Budgets screen. Before touching those files, check `git status`/`git log`; avoid conflicting rewrites and prefer migrating them after their owners land, or tell me.
- Preserve accessibility: 48dp touch targets, semantics labels, contrast, large-font layouts, RTL-safe (`EdgeInsetsDirectional`, `AlignmentDirectional`).

## Hard repo rules (follow `AGENTS.md` exactly)

- **Backup gate**: before any step that could affect existing user data or a real-device install (adb install, schema or generated-file changes, migrations, reset/restore), STOP and ask me to personally create and verify an encrypted FinanceFlow backup and keep the file and passphrase. Wait for my explicit confirmation. Never create one for me; never `adb uninstall`, `adb shell pm clear` or `flutter install`; only `adb install -r`. Persisting the chosen theme adds a settings field: treat it as a settings-schema change and handle it per these rules (prefer storing it in a way that does not require an Isar schema regeneration, or follow the gate if it does).
- **Standalone startup gate**: `main()` stays synchronous through `runApp`; theme/font loading must never block the first frame or depend on the network; if fonts are bundled, verify cold start on a device without `flutter run` attached (`./tool/verify_debug_startup.ps1 -Serial <device>`), plus `flutter analyze`, affected tests (including `test/widget_test.dart`), and both `flutter build apk --debug` and `--release` (Windows retry: `JAVA_TOOL_OPTIONS=-Djdk.net.unixdomain.tmpdir=.`).
- Never log financial data. Environment is Windows 11 with PowerShell.

## Process

1. **Do not start refactoring.** Enter plan mode. Read the theme files, all of `lib/shared/widgets/`, `app/app.dart`, settings/theme persistence, and a sample of 10+ screens. Run `flutter analyze` and the tests for a baseline and re-run the leakage measurements with exact commands so we can track progress.
2. Return: (a) a short audit of inconsistencies and duplicated patterns (with examples), (b) a proposed token architecture and API (show the call-site ergonomics in code, e.g. `context.ff.color.surfaceCard`, `FfSpacing.md`, `FfText.title`), (c) the proposed palettes as swatches (render an HTML preview or screenshots in light and dark with contrast numbers), (d) the component inventory with proposed APIs, (e) the migration plan with slices, risks and how you will avoid conflicts with other in-flight work, and (f) questions for me (design-system name, which alternative palettes, font choice, scope of the dev gallery) with your recommendations. Wait for my approval.
3. Then execute the slices, each ending with analyze + tests green, a commit, and a before/after screenshot set of the affected screens in light and dark.
4. Verify visually (emulator or built-in browser) and say plainly what you could not verify.

**Start now with step 1 and 2 only: read, measure, and return the audit and proposal for my approval.**
