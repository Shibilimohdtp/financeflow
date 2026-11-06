# 02 · Foundations (tokens)

Everything here lives in `lib/theme/` and is imported with `import '../../theme/ff.dart';`.
Colour and type are read from the theme (`context.ff`); space, radius, size and motion are `const`.
**Never** write a raw `Color(0x…)`, `Colors.*` (except `transparent`), `fontSize:`, `TextStyle(`, numeric radius,
numeric `EdgeInsets`/`SizedBox`, or `Duration(milliseconds:)` in feature code. If a value is missing, add a token.

## Colour roles (`context.ff.color.<role>`)

Palette: **Lichen** (the only palette in code; Tide and Graphite come later in DS-8). Values:
`lib/theme/palettes/bloom_primitives.dart`, mapping: `lib/theme/palettes/lichen.dart`.

| Group | Roles | Use |
|---|---|---|
| Canvas | `surfacePage` (#F3F2EC / #10120E), `auroraCool`, `auroraWarm`, `auroraLeaf` | Page; the aurora stops are painted by `FfAurora` only |
| Surfaces | `surfaceCard` (#FEFEFA / #191C16), `surfaceRaised`, `surfaceSheet` (= page), `surfaceContainer{Lowest,Low,,High,Highest}`, `surfaceDim` | Cards, dialogs, sunken tracks |
| Glass | `surfaceGlass`, `borderGlass` | `FfGlass` only |
| Text | `textPrimary`, `textSecondary`, `textTertiary`, `textDisabled` | Body, labels, captions (tertiary passes 4.5:1 on canvas, cards and aurora) |
| Borders | `borderSubtle` (decorative hairline), `borderControl` (3:1, outlines of pills/inputs/circle buttons), `borderStrong`, `focusRing` (lichen) | |
| Ink actions | `actionPrimary` (ink #1B1D17 / paper #ECEEE3 in dark), `onActionPrimary`, `actionPrimaryStrong`, `actionPrimaryContainer` (soft lime), `onActionPrimaryContainer`, `surfaceSelected` | Buttons, selected pills, links |
| Spark | `spark` (#CBE94C / #C6E44A), `onSpark` (ink), `sparkContainer` | Fill only, always with `onSpark` on it |
| Secondary/accent | `secondary*` (mushroom), `accent*` (mineral rose) | Rare; badges in the old nav |
| Money | `money{Income,Expense,Transfer,Savings,Debt,Investment}` + `…Container` | Shared by every palette; expense is brick |
| Status | `status{Success,Warning,Info,Error}` + containers, `onStatusError`, `statusWarningFill`/`onStatusWarningFill` (amber triangle + ink "!") | |
| Special | `surfaceInk`/`onSurfaceInk` (lock screen; ink button on heroes), `surfaceToast`/`onSurfaceToast`/`toastAction` (lime Undo), `surfaceInverse`…, `surfaceSecure`, `surfaceAccent`, `privacyBoundary`, `scrim`, `shadow` | |

Soft fills: `c.tint(color, FfTint.subtle)` (`whisper .04, faint .08, subtle .12, medium .2, strong .35`).
Component colour by meaning: `FfTone` (`lib/theme/ff_tone.dart`): `neutral, primary, accent, income, expense,
transfer, savings, debt, investment, success, warning, info, error`, with `.foreground(c)` and `.container(c)`.
Widgets take a tone, never a raw colour.

## Hero gradients (`context.ff.hero(FfHeroTone.x)`)

`lib/theme/ff_hero.dart`. Each `FfHeroColors` has `deep` (darkest), `zone` (lightest point text may cross),
`glow` (decorative corner, **no text**), `onHero`, `onHeroSecondary`.

| Tone | Light | Dark | Assign to |
|---|---|---|---|
| `moss` | deep olive → moss, lime glow, light text | deeper | Accounts, net worth, total balance |
| `rose` | pale rose → peach, **ink text** | deep rose, light text | Loans, EMIs, debts, budgets/plan |
| `dusk` | plum → mauve, light text | deeper | Investments, credit cards |
| `tide` | deep teal, sea-glass glow, light text | deeper | Savings goals |
| `sand` | pale sand, **ink text** | deep umber, light text | Cash, wallets, subscriptions |

Pick by what the money **is**, never by bank or brand. Inside `FfHeroCard`, `context.ff.text.*` and
`textPrimary/Secondary` already return the hero's colours (`FfHeroColorScope`), so shared widgets just work; use
`Builder` to get the scoped context. Don't put green/brick money colours on a hero; use neutral amounts with signs.

## Type (`context.ff.text.<role>`)

One face: **Geist** 300/400/500/600 (bundled; Manrope is only the glyph fallback). Hierarchy by size:

| Role | Size / line / weight | Use |
|---|---|---|
| `displayLg` / `display` / `displaySm` | 40 / 32 / 28, weight 300 | Onboarding titles, hero moments |
| `headlineLg` / `headline` / `headlineSm` | 26 / 22 / 19, 400 | Page titles (app bar uses `headline`) |
| `titleLg` / `title` / `titleSm` | 17 / 15 / 14, 500 | Card titles, row titles |
| `bodyLg` / `body` / `bodySm` | 16 / 14 / 13, 400 | Text; `bodySm` is secondary colour |
| `labelLg` / `label` / `labelSm` | 14·500 / 12·400 / 11·500 | Buttons, captions, metadata (`label`, `labelSm` secondary colour) |
| `moneyHero` / `moneyLg` / `moneyMd` / `moneySm` | 44·300 / 32·300 / 20·400 / 15·400, tabular | Amounts |

Rules: weight 300 only at 28 dp and above (tested). Never set `fontWeight` to bold in feature code; pick a role.
Amounts always go through `FfAmountText` (see components), which clamps text scale to 1.3×.

**Numerals:** `FfAmountStyle.split` = small sign and ₹, big number, small paise (min 12 dp), shrinks to fit;
default for `hero` and `lg`. `FfAmountStyle.inline` = one size, sign first; default for `md` and `sm` (rows).

## Shape

`FfShape.of(radius, {side})` → squircle (`FfSquircleBorder`, smoothing 0.6) or stadium for `FfRadius.full`.
`FfShape.decoration(...)` for custom containers. Flutter 3.29 has no native superellipse; `FfShape` is the only
place that would change after an upgrade. Don't use `BorderRadius.circular` for cards; use the shape.

`FfRadius`: `xs 6 · sm 12 · md 16 (inputs, toasts, banners) · lg 24 (list cards) · xl 36 (summary cards, dialogs,
sheets) · x2l 44 (hero cards) · full (pills, buttons, chips, circles)`.

## Space and density

`FfSpace` (4 dp unit): `x3s 2, x2s 4, xs 8, sm 12, md 16, lg 20, xl 24, x2l 32, x3l 40, x4l 56`;
`FfSpace.pageMargin = 16`. `FfDensity.comfortable` (row 72, padding 20, gap 16, radius 36) and
`FfDensity.compact` (row 60, padding 16, gap 12, radius 24). Touch targets ≥ `FfTouch.minTarget` (48).

## Elevation, blur, grain, effects

- `FfElevation.card(shadow, brightness)` (soft two-layer; faint rim in dark), `FfElevation.float(...)` (dock, raised).
- `FfBlur.glass 18`, `FfBlur.dock 24`: only in `FfGlass`/`FfDock`.
- `FfGrain`: 96 px tile from a fixed seed, drawn by `FfHeroCard` after the first frame.
- `FfEffects.of(context)` → `full` or `reduced` (system reduce-motion or high contrast, or `FfEffectsScope`).
  Reduced = no blur, no grain, solid glass. Components handle it; screens don't need to.

## Motion

`FfMotion.fast 160 / base 240 / slow 360` with `FfMotion.emphasized`. Animate state changes (pill selection,
dock expansion, progress fill) once; no looping animation. Respect `MediaQuery.disableAnimations`.

## Contrast rules (enforced by tests)

`lib/theme/ff_contrast.dart` (`FfContrastRules.all`, `FfHeroContrastRules`) and
`test/theme/palette_accessibility_test.dart`: 121 pairs per mode + hero checks, text ≥ 4.5:1, controls ≥ 3:1,
income vs expense ΔE ≥ 10 under colour-blindness simulation. **When a component starts drawing a new colour pair,
add a rule.** Known issues list must stay empty.
