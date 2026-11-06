# Stillwater Bloom: the next visual direction (DS-B)

Status: **approved 2026-11-06** by the owner, with every recommendation below.
Progress lives in [CHANGELOG.md](CHANGELOG.md).

Full proposal with rendered palette, contrast numbers, type specimen, components and mock screens:
https://claude.ai/artifact/U3rVyisZoEVEw8amj8oamH (source: [bloom-preview.html](bloom-preview.html)).
Mood reference: `reference/` (a designer's concept for a loan app; used as inspiration only).

## Direction

FinanceFlow should feel like a calm, well-lit room where your money sits in a few soft, solid objects. The page is a
pale wash of lilac, blush and moss light. Money lives in large squircle cards; the few that matter most (an account, a
loan, a goal) become grainy gradient cards cut from Lichen's own colours. Numbers are big and light, units small and
quiet. Everything you tap is ink. One lime spark marks the thing you are looking at right now. Everyday lists stay
plain, dense and fast.

Principles: light numbers, heavy meaning · ink acts, lime points · effects only where they mean something ·
two densities (comfortable summaries, compact lists) · private by default, visibly.

## Owner decisions (2026-11-06)

1. **Direction A**: evolve Lichen into Bloom as the one default look. Tide and Graphite are built later in the same
   language (DS-8). `FfShape.style` and `FfEffects` keep a way back to rounded, flat surfaces.
2. **Typeface: Geist** 300/400/500 (OFL), bundled like Manrope (downloading from the Google Fonts GitHub repository is
   approved). Manrope stays as the fallback family; Fraunces is dropped (DS-B2).
3. **Money style**: `FfAmountText` split style (big number, small raised currency, small paise) for hero, large and
   stat amounts; inline style for rows. Split steps down a size before it ellipsizes.
4. **Effects**: grain, blur and glass only on hero surfaces and the dock; never inside list items.
5. **Floating dock** replaces the bottom bar (same five tabs); the bar stays as the fallback for reduced effects and
   very large text.
6. **Primary actions turn ink**; Lichen green moves to hero gradients, the focus ring and selected tints.
7. About 75% resemblance to the reference is the right balance.

## Not taken from the reference

Names, bank brands, copy, photography and backdrops, the avatar header, credit-bureau UI, italic labels, and white
text on light lime (it fails contrast).

## Slices

| Slice | Content |
|---|---|
| DS-B1 | Tokens: Bloom values in Lichen, colour roles (aurora, glass, spark, warning fill), hero gradients, `FfShape` squircles, radii, elevation, blur, grain, density, effects; theme builder; contrast rules. No screen edits. |
| DS-B2 | Type: bundle Geist, new scale, drop Fraunces, `FfAmountText` split/inline. Build-config change: standalone-startup gate. |
| DS-B3 | Components: `FfCard` (squircle, density, shadows), `FfHeroCard`, `FfAurora`, `FfCircleButton`, `FfInkButton`, `FfPillBar`, `FfGlass`, `FfDotMatrix`, `FfRangeBand`, `FfLineChart` (spark bubble), `FfMonthGrid`, `FfDock`, `FfStatTile` units, `FfBadge` corner, `FfCarousel`, grain generator. |
| DS-10 | Gallery shows every token and component. |
| DS-B4–B6 | Home, Money, Accounts and Loans screens. Budgets stays with its own chat. |
| DS-8 (rest) | Tide and Graphite in Bloom, theme picker, pure black, reduced-effects setting (stored in `themeMode`). |
