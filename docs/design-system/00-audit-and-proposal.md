# Design system: audit and proposal (Phase DS-0)

Status: **proposal, waiting for owner approval** (2026-11-05). Nothing in `lib/` has been refactored yet.
Progress and ownership live in [CHANGELOG.md](CHANGELOG.md). Read that first in any new chat.

Inputs: [`docs/opus-design-system-prompt.md`](../opus-design-system-prompt.md) (the brief), `AGENTS.md`,
`docs/features/FinanceFlow_Design_System.md` (original Stillwater spec), `docs/features/FinanceFlow_PRD.md`.

## 1. Baseline (re-measured, reproducible)

```bash
flutter analyze                      # No issues found
flutter test -j 2 --timeout 90s      # 515 tests, all passed
dart run tool/design_system_audit.dart            # lib/ minus lib/theme/
dart run tool/design_system_audit.dart --shared   # also minus lib/shared/ (guardrail scope)
```

| Check (lib/ minus lib/theme/, 224 files) | Hits | Files |
|---|---:|---:|
| `Colors.*` other than `transparent` | 9 | 4 |
| `Colors.transparent` (allowed) | 36 | – |
| `Color(0x…)` literals | 22 | 2 |
| `withOpacity` / `withValues(alpha)` ad-hoc tints | 182 | 55 |
| static `StillwaterColors.*` (cannot follow a theme switch) | 75 | 6 |
| raw `fontSize: <n>` | 158 | 50 |
| `TextStyle(` constructions | 49 | 24 |
| `GoogleFonts.` outside theme | 0 | 0 |
| `BorderRadius.circular(` (any) / with a number | 248 / 6 | 73 / 3 |
| `EdgeInsets` with numbers | 25 | 18 |
| `SizedBox(width/height: <n>)` | 96 | 42 |
| inline `Duration(milliseconds:)` | 6 | 4 |
| raw `AppBar(` / `SliverAppBar(` | 36 | 33 |
| `showModalBottomSheet` | 31 | 23 |
| `showDialog` / `AlertDialog` | 6 | 3 |
| `showDatePicker` / range / time | 17 | 14 |
| `DropdownButton*` / `PopupMenuButton` | 22 | 15 |
| `Divider(` | 72 | 37 |
| raw progress indicators | 29 | 22 |
| ad-hoc `BoxDecoration(` containers | 206 | – |
| raw Material buttons vs `FfButton` | 28 vs 59 | – |

Note on the brief's figure of "600+ `Colors.*`": a naive `grep 'Colors\.'` also matches `finColors.`,
`statusColors.`, `secColors.` and `accentColors.` (275 reads of the theme extensions, which are fine). Raw
`Colors.` use is small; the real leakage is ad-hoc alpha tints, font sizes, sizes and one-off containers.

Worst files: `add_edit_transaction_screen` (72), `emi_schedule_view` (32), `needs_review_screen` (32),
`money_record_detail_screen` (31), `lock_screen` (29), `settings_screen` (28), `loan_detail_screen` (26),
`branding_preview_screen` (25), `transaction_pickers` (24), `add_edit_loan_sheet` (22), `transaction_tile` (21).

## 2. Audit: inconsistencies and duplicated patterns

**Bugs users can see**
1. **The Undo action on every snackbar is unreadable in light mode.** It is primary `#535B36` on the ink
   snackbar `#24291E`, a contrast of **2.07:1** (needs 4.5:1). `FfSnackbar` passes `colorScheme.primary`.
   It is used 97 times, including undo after delete.
2. **Release builds very likely render the system font, not Manrope.** `google_fonts` downloads fonts at
   runtime, but the release manifest has no `INTERNET` permission (only `src/debug` does). So debug
   and release look different. It also means a "fully local" app makes a request to Google in debug. To be
   confirmed on the device when it is reconnected.
3. 61 uses of `fontSize: 11`, 53 of `10`, 5 of `9` and 2 of `10.5`. 10 and 9 are below the smallest scale role
   (`labelSmall` 11) and are hard to read on a phone. They ignore the type scale, so they don't follow
   the theme's font or line heights.
4. Light-mode `textTertiary` (#606559) and `textSecondary` (#55594F) differ by so little that the hierarchy is
   invisible. Hairline borders on cards are 1.3:1. That is fine as decoration, but inputs and chips that use them
   as their only boundary miss 3:1.
5. Lichen's income green and expense raspberry are ΔE 5.8 apart under deuteranopia (about 1 in 16 men), so they
   read as nearly the same colour. Signs (+/−) help, but tiles and charts rely on colour alone.

**Inconsistency**
- 29 different alpha values (0.02 to 0.85) for "tinted" backgrounds; 15 different icon sizes (11 to 44); 14
  different literal `SizedBox` gaps (1, 2, 3, 5, 6, 10…) beside the 4dp scale.
- 206 hand-built `Container(decoration: BoxDecoration(...))` blocks, compared with 55 `FfCard` uses. Each picks its own radius,
  border and fill.
- Bottom sheets are hand-rolled 31 times: 27 set `isScrollControlled`, 1 sets `useSafeArea`, 2 show a drag
  handle, 3 set their own shape. Each one builds its own handle, header, padding and keyboard inset.
- `FfButton` hard-codes `TextStyle(fontSize: 12/14)` and `36.0`. `FfListRow` and `FfSwitchRow` each draw their own icon
  tile (`alpha 0.12`, `radiusSm`), while `FfCategoryTile` uses `radiusMd` with the same tint, so there are two different
  "icon tile" shapes.
- `lock_screen` paints with static `StillwaterColors.darkSecInk` and raw `TextStyle(fontSize: 22)`;
  `transaction_tile` uses `Colors.white/black.withValues(...)` for chips.
- `StillwaterTheme` builds light and dark in two near-identical 250-line blocks with literals of their own
  (`height: 72`, icon `size: 22`, drag handle `Size(32, 4)`, dialog `elevation: 4`).
- `context.finColors` and the other getters fall back to static constants, and only 54 call sites read `colorScheme`.

**Naming**
The system is "Stillwater" in files, classes and the spec. A comment calls the palette "Lichen Ledger". The modes are
"Daylight" and "Deep Water". The spec's palette (deep teal, sand, marigold) is not the shipped one (lichen,
mushroom, rose). The dark accent is commented "Marigold" but is pink.

## 3. Proposed token architecture and API

Three layers, one root (`lib/theme/`), generated for any palette × brightness.

```
lib/theme/
  tokens/primitives.dart   raw ramps & scales: hex values, type-size numbers, 4dp unit (private to lib/theme)
  tokens/foundation.dart   FfSpace, FfRadius, FfBorder, FfIconSize, FfMotion, FfOpacity, FfBreakpoint (const)
  tokens/components.dart   FfButtonTokens, FfCardTokens, FfSheetTokens, FfFieldTokens, FfRowTokens… (const)
  palettes/ff_palette.dart FfPalette(id, name, light: FfColorSet, dark: FfColorSet)
  palettes/lichen.dart  tide.dart  sandstone.dart  graphite.dart
  ff_colors.dart           FfColors  (ThemeExtension, semantic roles)
  ff_text.dart             FfText    (ThemeExtension, type roles incl. money)
  ff_theme.dart            FfTheme.build(palette, brightness, {pureBlack, highContrast}) → ThemeData
  ff_context.dart          extension FfContext on BuildContext { FfThemeData get ff }
```

Why two access styles. Colour and type change with the theme, so they are read from context. Space, radius,
size and motion are the same in every theme, so they stay `const`. Const keeps `const` widgets possible and has no
lookup cost. It is still one line to change: `FfSpace` is defined as multiples of `FfSpace.unit`, and
`FfRadius.card` is a component token pointing at the scale.

```dart
// Foundations (const, theme-invariant)
abstract final class FfSpace {
  static const double unit = 4;
  static const double xxs = unit * 0.5, xs = unit, sm = unit * 2, md = unit * 3,
      lg = unit * 4, xl = unit * 5, xxl = unit * 6, x3l = unit * 8, x4l = unit * 10;
  static const EdgeInsetsDirectional page = EdgeInsetsDirectional.symmetric(horizontal: xl);
}
abstract final class FfRadius {
  static const double sm = 8, md = 12, lg = 16, xl = 24, sheet = 28;
  static const BorderRadius card = BorderRadius.all(Radius.circular(lg));   // component alias
}

// Semantic colours and text (theme-following)
final ff = context.ff;
Container(
  padding: const EdgeInsetsDirectional.all(FfSpace.lg),
  decoration: BoxDecoration(color: ff.color.surfaceCard, borderRadius: FfRadius.card,
      border: Border.all(color: ff.color.borderSubtle)),
  child: Text('Spent this month', style: ff.text.label),
);
Text(amount, style: ff.text.moneyLg.copyWith(color: ff.color.moneyExpense)); // inside FfAmount only
ff.color.tint(ff.color.moneyIncome, FfTint.subtle)  // replaces ad-hoc .withValues(alpha: 0.12)
```

Semantic colour roles, the only colour names UI code may use:
`surfacePage, surfaceCard, surfaceRaised, surfaceSunken, surfaceSelected, surfaceInverse, surfaceSecure`;
`textPrimary, textSecondary, textTertiary, textDisabled, textOnAction, textInverse, textLink`;
`borderSubtle, borderControl, borderStrong, focusRing`;
`actionPrimary, actionPrimaryContainer, onActionPrimaryContainer, actionInverse` (snackbar action);
`accent, accentContainer, onAccentContainer`;
`moneyIncome, moneyExpense, moneyTransfer, moneySavings, moneyDebt, moneyInvestment` (+ `…Container`);
`statusSuccess, statusWarning, statusInfo, statusError` (+ `…Container`); `scrim, shadow`; `chart(i)`.

Type roles (one scale, Manrope, Fraunces only for `display`): `display, headline, title, titleSm, body, bodySm,
label, labelSm, caption, overline` and money roles `moneyHero, moneyLg, moneyMd, moneySm` (tabular figures).
Money rows clamp the text scale to 1.3×; everything else follows the system scale up to 2×.

`FfTheme.build` writes `ColorScheme`, `TextTheme` and every Material component theme from the same
`FfColors` and `FfText`, so stock widgets pick the system up automatically. Adding a theme means adding one
`FfPalette` file and one line in `FfPalettes.all`.

**Theme persistence without a schema change.** `AppSettingsEntity.themeMode` is already a free-text `String`.
It becomes `"mode=dark;palette=tide;black=1"`, and the old values `system`, `daylight` and `deep_water` still parse.
No Isar regeneration is needed. Installing a build on the Pixel still follows the backup gate.

**Shims.** `StillwaterTokens`, `StillwaterColors`, `StillwaterTheme.daylight/deepWater` and `context.finColors`
keep compiling as `@Deprecated` forwards until slice DS-9 removes them.

## 4. Palettes

Live preview with computed contrast: https://claude.ai/artifact/XhemBcoHzeguj8gZx5rh8A
(source `palettes-preview.html` here; the numbers come from [palette_check.py](palette_check.py)).

| Palette | Character | Light / dark checks |
|---|---|---|
| **Lichen** (default) | Today's identity, refined: tertiary text, card lift, snackbar action, expense hue | all pass (+ pure-black variant) |
| **Tide** | The original Stillwater spec: deep-water teal, shore sand, marigold | all pass |
| **Sandstone** | Warm sand and terracotta, slate-blue accent | all pass |
| **Graphite** | Neutral monochrome, colour only on money | all pass |

Each palette is checked on 3 backgrounds: about 30 text pairs at ≥ 4.5:1, plus control borders and focus at ≥ 3:1.
Money colours are shared by every palette: income is cool green, expense is warm brick. Income against expense
stays ≥ ΔE 11 under deuteranopia, protanopia and tritanopia. Sandstone is the exception: it uses olive and raspberry,
so expense does not look like its terracotta buttons. Transfer, savings, debt and investment cannot all be
told apart by colour alone under colour blindness (the closest pair is ΔE 1.1), so they always carry an icon and a label.
That rule is enforced in `FfAmount` and `FfIconTile`. **Pure black** is a switch for any dark palette.
**High contrast** is proposed as a later modifier, not in the first release.

## 5. Component inventory

Legend: *keep* = exists, align to tokens; *extend*; *new*; *merge* = replaces duplicates.

| Group | Component (API sketch) | Status | Replaces |
|---|---|---|---|
| Feedback | `FfToast.show(context, message, tone: FfTone.success/info/warning/error, action: FfToastAction('Undo', onUndo))` | extend `FfSnackbar` | 2 raw `ScaffoldMessenger` |
| | `FfBanner(tone, title, message, action, onDismiss)` | new | ad-hoc warning containers |
| | `FfDialog.confirm / .destructive(typeToConfirm: 'DELETE') / .info / .progress` | extend `FfConfirmDialog` | 6 `showDialog`/`AlertDialog` |
| | `FfEmptyState(icon, title, message, action)`, `FfErrorState(onRetry)`, `FfSkeleton.row/card/metric` | keep / new / keep | |
| Overlays | `showFfSheet<T>(context, title:, builder:, footer:, maxHeight:, scrollable:)` | new | 31 `showModalBottomSheet` |
| | `FfActionSheet(actions)`, `FfMenu` (popup) | new | 22 dropdown/popup menus |
| | `pickFfDate`, `pickFfDateRange`, `pickFfTime` | new | 17 picker calls |
| | `FfFullScreenRoute` | new | ad-hoc `MaterialPageRoute(fullscreenDialog)` |
| Structure | `FfScaffold(appBar:, body:, footer:, maxContentWidth)` | new | 39 `Scaffold` |
| | `FfAppBar.standard / .large / .search / .selection(count)` | new | 36 `AppBar` |
| | `FfBottomNav` (rename), `FfTabs`, `FfSegmented` (merge `FfSegmentedPill`), `FfSectionHeader`, `FfDivider.inset/full` | keep/merge | 72 `Divider` |
| | `FfGroup` (merge `FfGroupedContainer`), `FfRow` (merge `FfListRow`, `FfSwitchRow`; trailing: `.chevron/.value/.switch_/.badge/.custom`) | merge | 19 `ListTile` |
| Inputs | `FfTextField(.search, .secret)`, `FfAmountField`, `FfSelect<T>`, `FfChoiceChips<T>(multi:)`, `FfDateField`, `FfCheckboxRow`, `FfRadioRow`, `FfSlider(label)`, `FfStepper`, `FfPinPad` | mixed | 48 raw text fields |
| Actions | `FfButton(variant: primary/secondary/tertiary/destructive, size, icon, loading)`, `FfIconButton`, `FfFab(.extended)`, `FfChip.filter/.input/.assist`, `FfSwipeBackground(tone)` | extend | 28 raw buttons |
| Data | `FfCard(variant: flat/raised/tinted(tone)/outlined, onTap)`, `FfAmount(value, kind, size, sign rule)`, `FfIconTile(icon, tone, size)` (merge 3 icon-tile styles), `FfProgress.linear/.circular/.segmented(pace:)`, `FfBadge(tone)`, `FfStatTile`, `FfKeyValueRow`, `FfTimeline` | mixed | 206 `BoxDecoration`, 29 progress |
| Charts | `FfChartTheme` (axes, grid, legend, tooltip from `ff.color.chart(i)`), applied to `FfBarChart`, `FfDonutChart`, cash-flow chart | extend | |
| Patterns | `FfPageHeader(title, period:)`, `FfDetailHeader`, `FfFormPage(sticky footer)`, `FfOnboardingStep`, `FfSecureLayout` (lock/PIN) | new | |

Every component gets enum variants and a small set of semantic `tone`s. It takes no raw colour or size parameters,
and has dartdoc, semantics, a 48dp target, RTL-safe insets, and a widget test that runs in every palette and both modes.

## 6. Migration plan (slices)

Each slice: analyze clean, tests green, one commit, before/after screenshots (light + dark) of the
affected screens, rendered with `flutter test` golden capture (deterministic once fonts are bundled), plus device
screenshots when the Pixel is connected. Log every slice in [CHANGELOG.md](CHANGELOG.md).

| # | Slice | Visible change | Gate |
|---|---|---|---|
| DS-0 | Audit, proposal, audit script, tracking log | none | — |
| DS-1 | Token core: primitives, `FfPalette` (Lichen values unchanged), `FfColors`/`FfText`, `FfTheme.build`, `context.ff`, deprecated shims; test that new ThemeData equals old | none | tests |
| DS-2 | Contrast + CVD guardrail test for every palette/mode | none | tests |
| DS-3 | Bundle fonts, remove `google_fonts` | release gets Manrope | **backup gate + device cold start** |
| DS-4 | Feedback and overlays: `FfToast`, `FfDialog`, `showFfSheet`, pickers, `FfBanner` + migrate all call sites | consistent sheets/dialogs | tests |
| DS-5 | Structure and inputs: `FfScaffold`, `FfAppBar`, `FfRow`, `FfDivider`, `FfTextField`, `FfSelect` | consistent bars/rows | tests |
| DS-6 | Data display: `FfCard`, `FfAmount`, `FfIconTile`, `FfProgress`, `FfBadge`, chart theme | consistent tiles | tests |
| DS-7a–h | Migrate features, in this order: settings/security/onboarding → transactions → dashboard/insights → loans → ingestion → debts/subscriptions/goals/investments/accounts/alerts/backup → **budgets last** | per feature | tests |
| DS-8 | Refinement pass: Lichen fixes (tertiary text, snackbar action, expense hue), new palettes, theme picker with live preview, persistence in `themeMode` | yes | backup gate before device install |
| DS-9 | Remove shims; turn on `test/guardrails/design_system_test.dart` + `allowlist.yaml` | none | tests |
| DS-10 | Design System Gallery (debug-only route) + `docs/design-system/` reference; one-token demo on 8+ screens, then revert | none | — |

**Avoiding conflicts.** Another chat owns the budgets redesign (`lib/services/budgets/`, `lib/models/budget.dart`,
`lib/core/money/money_math.dart`, `test/unit/budgets/`, budgets UI). DS slices don't touch those files until that
work is committed. Then budgets UI migrates last (DS-7h) and is marked in the log. Before each slice, run `git status`
and check the "In flight" table in the log. Commit only paths the slice changed.

**Risks.**
- Visual drift during migration: mitigated by DS-1 equality tests and by golden captures.
- Golden flakiness on Windows: mitigated by bundled fonts and by keeping goldens out of the default test run.
- Font bundling changes startup: mitigated by the AGENTS.md gate in DS-3.
- Large diffs in `add_edit_transaction_screen` (2,800 lines): migrated in its own commit.
- No device available right now: screenshots come from golden capture until the Pixel is back.

## 7. Questions for the owner (with recommendations)

1. **Design-system name.** Recommend keeping **Stillwater** as the system name, because it is already in the spec and the
   class names. Palettes get their own names (Lichen, Tide, Sandstone, Graphite). Mode names become plain "Light" and
   "Dark"; "Daylight" and "Deep Water" are retired. Code moves to an `Ff` prefix (`FfTheme`, `FfColors`), matching the widgets.
2. **Palettes.** Recommend shipping Lichen (default), Tide and Graphite, plus the pure-black switch. Sandstone is optional.
   High contrast comes later.
3. **Lichen refinements.** These change today's look slightly:
   - expense moves from raspberry to brick, for colour-blind separation
   - lighter tertiary text
   - readable snackbar Undo
   - brighter cards on the page

   Recommend yes.
4. **Fonts.** Recommend **bundling** Manrope (variable, OFL licence) and only the Fraunces weight we use,
   then dropping `google_fonts`. This works offline, makes no network request, makes release match debug, and keeps goldens
   deterministic. It needs your OK to download the two font files from the Google Fonts GitHub repository.
   Alternative: keep `google_fonts` with runtime fetching off and bundled files anyway.
5. **Dev gallery.** Recommend a debug-only route, compiled out of release with `kDebugMode`. It is reachable by long-pressing
   the version row in Settings, and replaces `branding_preview_screen.dart`.
