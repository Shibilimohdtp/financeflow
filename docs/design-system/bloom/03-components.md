# 03 · Components

All in `lib/shared/widgets/`. Use these; don't rebuild them inside a feature. If a screen needs something that
isn't here, **add it here** (shared widget + widget test in `test/widget/components/` + gallery/screenshot + this
file) rather than writing a one-off. Components take tones and variants, never raw colours or sizes.

## Surfaces

| Widget | Use | Key API | Don't |
|---|---|---|---|
| `FfAurora` (`ff_surfaces.dart`) | Background of top-level hero tabs (Home; Plan; Insights) | `FfAurora(child: Scaffold(backgroundColor: Colors.transparent, …))` | Use on everyday lists, forms, settings |
| `FfHeroCard` (`ff_surfaces.dart`) | The one or two most important objects on a screen | `FfHeroCard(tone:, leading: FfProgressRing(…), title:, subtitle:, onOpen:, openTooltip:, height:, child:)` | Put inside list items; use money tone colours inside; more than two per screen |
| `FfHeroColorScope` | Already applied by `FfHeroCard`; use `Builder` inside the child to read hero colours | | |
| `FfGlass` (`ff_surfaces.dart`) | Frosted pill/bar over a hero or the aurora | `FfGlass(child:, radius: FfRadius.full, onHero: true, padding:)` | Use in lists |
| `FfCard` (`ff_card.dart`) | Every other card | `FfCard(child:, density: FfDensity.comfortable/compact, variant: standard/tinted/elevated/warning, tone:, onTap:)` | Add borders; nest cards |
| `FfCard.decorationOf(context, density:)` / `FfCard.shapeOf(density)` | When you need your own `Material`/`InkWell`/`DecoratedSliver` | Use `Ink(decoration: …)` so ripples show | |
| `FfGroupedContainer` | Rows grouped in one compact card; draws dividers and clips ink | `FfGroupedContainer(children: [FfRow…], dividerInset: FfRowLeading.tile)` | |
| `FfSheet` + `showFfSheet` | Every bottom sheet | `showFfSheet(context, builder: …)`, `FfSheetHeader`, `FfSheetFooter` | Raw `showModalBottomSheet` (a test fails) |
| `FfDialog` | `confirm`, `confirmTyped`, `info`, `withProgress` | | Raw `showDialog` |

## Actions and navigation

| Widget | Use | Key API |
|---|---|---|
| `FfButton` | All text buttons (pill) | `FfButton(label:, onPressed:, variant: primary/filled/secondary/outlined/text/destructive/spark, size:)` |
| `FfCircleButton` (`ff_round_buttons.dart`) | Round header/utility action (back, more, hide amounts, filter, alerts) | `FfCircleButton(icon:, tooltip:, onPressed:, corner: FfCorner.dot/warning, soft:)` 48 dp target |
| `FfInkButton` | Solid ink action circle; `.open` is the ↗ "open detail" | `FfInkButton.open(onPressed:, tooltip:, onHero:, small:)` |
| `FfChip` | One choice pill (ink when selected, outlined otherwise) | `FfChip(label:, isSelected:, onSelected:, leading: Icon)` |
| `FfPillBar<T>` | Scrolling row of filter pills | `FfPillBar(values:, selected:, label:, onSelected:)` |
| `FfSegmentedPill<T>` | 2–4 mutually exclusive modes in a sunken track | `FfSegmentedPill(options: [FfSegmentOption(value:, label:)], selectedValue:, onSelected:)` |
| `FfDock` (`ff_navigation.dart`) | The app's tab bar (already in the shell; don't add another) | `FfDockItem(icon:, label:, badgeCount:, showDot:)` |
| `FfCarousel` | Peeking row of cards (hero carousel) | `FfCarousel(height:, children:, viewportFraction:)` |
| `FfPeriodBar` | Shared period selector (prev/next, picker, all time) | `FfPeriodBar(period:, onChanged:, allowAllTime:, units: {week, month, year}, chooserTitle:)`; `units` limits the chooser (Plan offers week/month/year only; `day` = Today, `custom` = Custom range) |
| `FfAppBar` | Every app bar (`.search`, `.selection`) | `FfAppBar(title:, subtitle:, actions:)` |
| `FfMenuButton` / `FfSelect` | Overflow menus / field dropdowns | |

## Rows and text

| Widget | Use | Key API |
|---|---|---|
| `FfRow` | Every list row (`.toggle`, `.checkbox`, `.radio`) | `FfRow(title:, subtitle:, icon:, iconTone:, leading:, detail:, trailing:, showChevron:, selected:, onTap:, destructive:)` |
| `FfIconTile` | Tinted circle icon with optional corner badge | `FfIconTile(icon:, tone:, corner: FfCorner.warning)` |
| `FfCategoryTile` | Category icon in its own colour (circle) | `FfCategoryTile(iconIdentifier:, colorTokenIdentifier:)` |
| `FfCornerBadge` | Warning triangle / error / spark dot on any icon | `FfCornerBadge(corner:, child:, semanticLabel:)` |
| `FfKeyValueRow` | Label → value detail rows | |
| `FfSectionHeader` | Section title + optional trailing action | `FfSectionHeader(title:, trailing: TextButton(…), padding:)` |
| `FfBadge` | Small status pill with icon | `FfBadge(label:, tone:, icon:)` |
| `FfBanner` | Inline info/success/warning/error message | |
| `FfToast` | Snackbars (lime Undo) | `FfToast.show(context, message:, tone: FfToastTone.x, actionLabel:, onAction:)` |
| `FfEmptyState`, `FfLoading`, `FfSkeletonLoader` + blocks | Empty, loading, skeletons | |
| `FfPrivacyBadge` | "On-device" cue | `FfPrivacyBadge(label: 'On-device', iconOnly:)` |

## Money and data

| Widget | Use | Key API |
|---|---|---|
| `FfAmountText` | **Every amount** | `FfAmountText(amount:, size: hero/lg/md/sm, style: split/inline, tone:, type:, showSign:, isBlurred:)` |
| `FfAmountField` | Every money input (`.bare` on heroes) | |
| `FfStatTile` | Label + figure (+ unit, caption) | `FfStatTile(label:, value: FfAmountText(…), unit: '/120', caption:)` |
| `FfHeroFigures` (`ff_stat_tile.dart`) | The 2–3 small figures at the foot of a hero ("Paid · Complete · Total payable", "Per day · Forecast · Days left") | `FfHeroFigures([FfHeroFigure(label, value, semanticsValue:)])`; first starts, last ends, middle centred; tabular `labelLg`; values shrink at large text; each read as "Paid, ₹6,51,200" |
| `FfProgressRing` (`ff_data_viz.dart`) | Ring around an icon = progress (loan paid, goal saved, share) | `FfProgressRing(value:, icon:, semanticsLabel:)` |
| `FfDotMatrix` | Count progress (EMIs, days, steps); next step in spark | `FfDotMatrix(total:, done:, semanticsLabel:)` + the number in text |
| `FfProgressBar` | Linear progress with optional pace marker (budgets!) | `FfProgressBar(value:, pace:, tone:, size:, onHero:, semanticLabel:, semanticValue:)`. `tone` sets meaning (`FfTone.expense` when over; `color` still wins). `onHero: true` inside `FfHeroCard`: hero text colour on a `FfTint.medium` track, tone ignored. `semanticValue` replaces "62%" with "62% used, ₹2,400 left, ahead of pace by ₹300". Pair over/at-risk with a badge or words |
| `FfRangeBand` | Value against good/watch/high bands (utilisation, pace) | `FfRangeBand(bands: [FfBand(start:, end:, tone:, label:)], value:, valueLabel:)` |
| `FfLineChart` | Trend with the spark value bubble; tap/drag to select | `FfLineChart(points: [FfChartPoint(label, value)], valueLabel:, initialIndex:, reference:, domainLength:, referenceLabel:, hint:)`. `reference` draws a dashed ideal-pace/target line (longer dashes than the grid, no dots); with `domainLength` the actual series stops at today while the reference spans the period; `referenceLabel(i)` is read after the value ("Day 6: ₹6,800, pace ₹1,200") |
| `FfMonthGrid` | Month tiles: paid ✓, missed ✕, due, upcoming; budget history: `under` (spark ✓, "within plan") and `over` (amber "!", "over plan") with the amount `note` under the marker | `FfMonthGrid(months: [FfMonthCell(label:, status:, note:)])`; announced as "July, over plan, ₹6.8k" |
| `FfBarChart`, `FfDonutChart` (`charts/`) | Bars and donut (Insights) | Not yet restyled for Bloom (see status) |

## Adding or changing a component

1. Shared file in `lib/shared/widgets/`, tokens in `lib/theme/tokens/ff_component_tokens.dart`.
2. Widget test in `test/widget/components/` covering each palette and mode, 2× text, reduced effects, semantics.
3. Add it to `tool/screenshots/bloom_screenshots_test.dart` and re-capture.
4. New colour pair → `FfContrastRules`.
5. Document it in this table in the same commit.
