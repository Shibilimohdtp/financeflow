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
| `FfAccountPreviewCard` (`ff_account_preview_card.dart`) | Miniature live card preview matching Home squircle hero | `FfAccountPreviewCard(accountType:, name:, institutionName:, maskedIdentifier:, balance:)` | Put in long scrollable lists |
| `FfSubscriptionPreviewCard` (`ff_subscription_preview_card.dart`) | Live subscription card preview matching list card squircle | `FfSubscriptionPreviewCard(merchant:, amount:, frequency:, category:, nextRenewalDate:)` | Put in long scrollable lists |
| `FfNotificationPreviewBubble` (`ff_notification_preview_bubble.dart`) | Miniature rendered Android notification preview demonstrating sensitive mask vs unmask | `FfNotificationPreviewBubble(hideSensitive:, merchant:, amount:, account:)` | |
| `FfStatusCard` (`ff_status_card.dart`) | Domain status card with icon tile, status badge, subtitle and action | `FfStatusCard(icon:, title:, statusLabel:, statusTone:, subtitle:, onAction:)` | |
| `FfSheet` + `showFfSheet` | Every bottom sheet | `showFfSheet(context, builder: …)`, `FfSheetHeader`, `FfSheetFooter` | Raw `showModalBottomSheet` (a test fails) |
| `FfDialog` | `confirm`, `confirmTyped`, `info`, `withProgress` | | Raw `showDialog` |

## Actions and navigation

| Widget | Use | Key API |
|---|---|---|
| `FfButton` | All text buttons (pill) | `FfButton(label:, onPressed:, variant: primary/filled/secondary/outlined/text/destructive/spark, size:)` |
| `FfCircleButton` (`ff_round_buttons.dart`) | Round header/utility action (back, more, hide amounts, filter, alerts) | `FfCircleButton(icon:, tooltip:, onPressed:, corner: FfCorner.dot/warning, soft:)` 48 dp target |
| `FfInkButton` | Solid ink action circle; `.open` is the ↗ "open detail" | `FfInkButton.open(onPressed:, tooltip:, onHero:, small:)` |
| `FfChip` | One choice pill (ink when selected, outlined otherwise) | `FfChip(label:, isSelected:, onSelected:, leading: Icon)` |
| `FfAccountTypeTiles` (`ff_account_type_tiles.dart`) | Compact 6-tile grid selector for `AccountType` with 48 dp targets | `FfAccountTypeTiles(selectedType:, onChanged:)` |
| `FfAssetTypeTiles` (`ff_asset_type_tiles.dart`) | Asset class choice: an `FfChoiceTiles` grid (3 per row, all nine classes visible, labels wrap) | `FfAssetTypeTiles(selectedType:, onChanged:)`, `FfAssetTypeTiles.iconFor(type)` |
| `FfSubscriptionTypeTiles` (`ff_subscription_type_tiles.dart`) | Horizontal selector for generic subscription categories with >=48 dp targets | `FfSubscriptionTypeTiles(selectedType:, onChanged:)` |
| `FfQuickToggleStrip` / `FfQuickToggleTile` (`ff_quick_toggle.dart`) | 4-tile quick settings strip with 48+ dp targets, dual-signal icon+words | `FfQuickToggleStrip(tiles: [FfQuickToggleTile(icon:, title:, statusText:, statusIcon:, isActive:, onTap:)])` |
| `FfThemePreviewCard` (`ff_theme_preview_card.dart`) | Miniature rendered Home preview card for Light / Dark / System themes | `FfThemePreviewCard(preference:, isSelected:, onTap:)` |
| `FfHoldToConfirmButton` (`ff_hold_to_confirm_button.dart`) | Safety-gated hold-to-confirm button for destructive actions (2.5s hold) | `FfHoldToConfirmButton(label:, onConfirmed:, isDestructive:)` |
| `FfPillBar<T>` | Scrolling row of filter pills | `FfPillBar(values:, selected:, label:, onSelected:)` |
| `FfSegmentedPill<T>` | 2–4 mutually exclusive modes in a sunken track | `FfSegmentedPill(options: [FfSegmentOption(value:, label:)], selectedValue:, onSelected:)` |
| `FfDock` (`ff_navigation.dart`) | The app's tab bar (already in the shell; don't add another) | `FfDockItem(icon:, label:, badgeCount:, showDot:)` |
| `FfCarousel` | Peeking row of cards (hero carousel) | `FfCarousel(height:, children:, viewportFraction:)` |
| `FfPeriodBar` | Shared period selector (prev/next, picker, all time) | `FfPeriodBar(period:, onChanged:, allowAllTime:, units: {week, month, year}, chooserTitle:)`; `units` limits the chooser (Plan offers week/month/year only; `day` = Today, `custom` = Custom range) |
| `FfAppBar` | Top bar of pushed/sub-screens with back/close button | `FfAppBar(title:, subtitle:, actions:)` |
| `FfPageHeader` (`ff_page_header.dart`) | Canonical non-sticky top header for all 5 primary tab screens (title in `headline`, subtitle in `label`, zero shield icons, actions, dynamic search & selection) | `FfPageHeader(title:, subtitle:, actions:, isSearchOpen:, ...)` |
| `FfMenuButton` / `FfSelect` | Overflow menus / single-choice fields | `FfSelect` looks like `FfTextField` and opens a Bloom sheet of options with a check on the selected one (same API as the old dropdown; `null` options still work). `FfMenuButton` lists actions, destructive ones marked |

## Rows and text

| Widget | Use | Key API |
|---|---|---|
| `FfRow` | Every list row (`.toggle`, `.checkbox`, `.radio`) | `FfRow(title:, subtitle:, icon:, iconTone:, leading:, detail:, trailing:, showChevron:, selected:, onTap:, destructive:)` |
| `FfIconTile` | Tinted circle icon with optional corner badge | `FfIconTile(icon:, tone:, corner: FfCorner.warning)` |
| `FfCategoryTile` | Category icon in its own colour (circle) | `FfCategoryTile(iconIdentifier:, colorTokenIdentifier:)` |
| `FfMonogramTile` (`ff_monogram_tile.dart`) | Generative 2-letter monogram in a squircle with deterministic tone tint | `FfMonogramTile(name:, size:, tone:, radius:)` |
| `FfRenewalChip` (`ff_renewal_chip.dart`) | Dual-signal renewal urgency status pill with icon + text (never colour alone) | `FfRenewalChip(daysUntilRenewal:, status:, compact:)` |
| `FfDueChip` (`ff_due_chip.dart`) | Honest due status badge pairing words with icon (never colour alone) for overdue, due-soon, and settled | `FfDueChip(dueDate:, settledAt:, isSettled:, compact:)` |
| `FfLedgerEntryRow` (`ff_ledger_entry_row.dart`) | Chronological ledger entry row with icon tile, signed amount, running balance, and allocation badge | `FfLedgerEntryRow(title:, date:, amount:, runningBalance:, isInflow:, accountName:, allocationBadge:)` |
| `FfCornerBadge` | Warning triangle / error / spark dot on any icon | `FfCornerBadge(corner:, child:, semanticLabel:)` |
| `FfKeyValueRow` | Label → value detail rows | |
| `FfSectionHeader` | Section title + optional quiet count + trailing action. On summary screens (Home) every section uses `padding: FfSectionHeader.sectionPadding` and an `FfSectionLink` | `FfSectionHeader(title:, count:, trailing: FfSectionLink(…), padding:)` |
| `FfSectionLink` (`ff_section_header.dart`) | The quiet "See all ↗" at the end of a section header: secondary text, outward arrow, 48 dp, end-aligned on the page margin | `FfSectionLink(label: 'See all', semanticLabel: 'See all loans', onPressed:)` |
| `FfActionTile` / `FfActionStrip` (`ff_action_tile.dart`) | Things to act on as a horizontal strip (Home "Needs attention"): tinted icon + corner, a count-and-verb line, a quiet detail; equal heights, ≥48 dp, bleeds to the screen edge from the page margin | `FfActionStrip(tiles: [FfActionTile(icon:, tone:, corner:, title: '2 to review', subtitle:, onTap:)])` |
| `FfConsequenceLine` (`ff_consequence_line.dart`) | One-sentence dynamic consequence line with icon and tone | `FfConsequenceLine(text:, icon:, tone:)` |
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
| `FfAmountHero` (`ff_amount_hero.dart`) | Amount hero card with type-reactive squircle tint, Geist 300 money numerals, consequence line, inline error | `FfAmountHero(controller:, tone:, label:, consequence:, consequenceIcon:, errorText:, onClear:)` |
| `FfSuggestionChips` (`ff_suggestion_chips.dart`) | Horizontal row of choice chips for quick presets/payees | `FfSuggestionChips<T>(items: [FfSuggestionChipItem(value:, label:, icon:)], selectedValue:, onSelected:)` |
| `FfStatTile` | Label + figure (+ unit, caption) | `FfStatTile(label:, value: FfAmountText(…), unit: '/120', caption:)` |
| `FfProtectionRingCard` (`ff_protection_ring.dart`) | On-device security posture card with progress ring and status badge | `FfProtectionRingCard(activeProtections: 4, totalProtections: 5, onTap:)` |
| `FfHeroFigures` (`ff_stat_tile.dart`) | The 2–3 small figures at the foot of a hero ("Paid · Complete · Total payable", "Per day · Forecast · Days left") | `FfHeroFigures([FfHeroFigure(label, value, semanticsValue:)])`; first starts, last ends, middle centred; tabular `labelLg`; values shrink at large text; each read as "Paid, ₹6,51,200" |
| `FfProgressRing` (`ff_data_viz.dart`) | Ring around an icon = progress (loan paid, goal saved, share) | `FfProgressRing(value:, icon:, semanticsLabel:)` |
| `FfDotMatrix` | Count progress (EMIs, days, steps); next step in spark | `FfDotMatrix(total:, done:, semanticsLabel:)` + the number in text |
| `FfProgressBar` | Linear progress with optional pace marker (budgets!) | `FfProgressBar(value:, pace:, tone:, size:, onHero:, semanticLabel:, semanticValue:)`. `tone` sets meaning (`FfTone.expense` when over; `color` still wins). `onHero: true` inside `FfHeroCard`: hero text colour on a `FfTint.medium` track, tone ignored. `semanticValue` replaces "62%" with "62% used, ₹2,400 left, ahead of pace by ₹300". Pair over/at-risk with a badge or words |
| `FfRangeBand` | Value against good/watch/high bands (utilisation, pace) | `FfRangeBand(bands: [FfBand(start:, end:, tone:, label:)], value:, valueLabel:)` |
| `FfAllocationBand` (`ff_allocation_band.dart`) | Proportional segmented bar with accessible legend | `FfAllocationBand(slices: [FfAllocationSlice(label:, value:, percentage:)])` |
| `FfBalanceBand` (`ff_balance_band.dart`) | Two-sided proportional balance bar for comparing competing amounts with accessible legend | `FfBalanceBand(leftLabel:, leftAmount:, rightLabel:, rightAmount:, onHero:)` |
| `FfRenewalStrip` (`ff_renewal_strip.dart`) | 30-day timeline strip with renewal markers, outflow badges, and day tap drilldown | `FfRenewalStrip(subscriptions:, onDayTap:, onSubscriptionTap:, isPrivacyBlur:)` |
| `FfLineChart` | Trend with the spark value bubble; tap/drag to select | `FfLineChart(points: [FfChartPoint(label, value)], valueLabel:, initialIndex:, reference:, domainLength:, referenceLabel:, hint:)`. `reference` draws a dashed ideal-pace/target line (longer dashes than the grid, no dots); with `domainLength` the actual series stops at today while the reference spans the period; `referenceLabel(i)` is read after the value ("Day 6: ₹6,800, pace ₹1,200") |
| `FfMonthGrid` | Month tiles: paid ✓, missed ✕, due, upcoming; budget history: `under` (spark ✓, "within plan") and `over` (amber "!", "over plan") with the amount `note` under the marker | `FfMonthGrid(months: [FfMonthCell(label:, status:, note:)])`; announced as "July, over plan, ₹6.8k" |
| `FfBarChart` (`charts/ff_bar_chart.dart`) | Rounded comparison bars with spark value bubble, tabular Geist numerals, accessible steppers | `FfBarChart(items: [BarChartItem(label, value, secondaryValue:)], selectedIndex:, onSelected:, showYAxis:)` |
| `FfDonutChart` (`charts/ff_donut_chart.dart`) | Proportional category ring with high-contrast segment numbers, light center amount, accessible semantics | `FfDonutChart(slices: [DonutSlice(label, value, colorToken:)], selectedSliceIndex:, onSliceSelected:, showSegmentNumbers:)` |

## Sheets (DS-B20)

Recipe: `04-screen-recipes.md` → E1. Changes to existing widgets are marked "changed".

| Widget | Use | Key API |
|---|---|---|
| `FfSheetHeader` (changed) | Title `titleLg` without the bold override, subtitle in `textSecondary` (was the mushroom `secondary`), handle from `FfSheetTokens.dragHandle`, close as a 48 dp target; hairline only when told the body is scrolled | `FfSheetHeader(title:, subtitle:, onClose:)`; `trailing` kept for compatibility but not used by new sheets |
| `FfSheet` (changed) | Watches the body's vertical scroll and shares it through `FfSheetScroll`, so the header and footer hairlines follow it even for sheets with their own scroll view | API unchanged |
| `FfSheetBody` (new, `ff_sheet.dart`) | The scrolling body of every sheet: standard padding (`FfSheetBody.standardPadding`), drag dismisses the keyboard, children stretched | `FfSheetBody(children: [...])`; long pickers keep a `Flexible(ListView(padding: FfSheetBody.standardPadding))` |
| `FfSheetGroup` (new, `ff_sheet.dart`) | One labelled group in a sheet body: `FfFieldLabel`, children spaced by `itemGap`, `groupGap` after | `FfSheetGroup(label: 'Type', children: [...], last:)` |
| `FfSheetFooter` (changed) | One full-width primary; optional text-button secondary above it; hairline only while content scrolls under it | `FfSheetFooter(primaryLabel:, onPrimaryPressed:, isPrimaryLoading:, secondaryLabel:, onSecondaryPressed:)`; the outlined side-by-side Cancel layout is removed |
| `FfFieldLabel` (new) | The one "what is this" label above a field, chip row, tile grid or segmented pill | `FfFieldLabel('Category', trailing:)` |
| `FfTextField` (changed) | Label now sits above the box (rendered with `FfFieldLabel`), never floating/notched; field semantics keep the label | API unchanged |
| `FfAmountField` (changed) | ₹ always visible (a prefix icon, not `prefixText`); hint `0`; label above; optional `helper`. With `groupDigits: true` digits group as you type (`FfAmountInputFormatter`, Indian or thousands by `CurrencyFormatter.current`) | `FfAmountField.parse(text)`, `FfAmountField.formatInput(amount)` for edit forms. `groupDigits` defaults to `false` while sheets owned by other chats still read with `double.tryParse`; turn it on per sheet as each one reads through `parse` |
| `FfAmountHero` (changed) | Faint tone wash on the card colour, neutral border (no longer looks disabled) | adds `groupDigits` |
| `FfSelect` (changed) | Label above the box (tapping it opens the picker too); options sheet uses the standard body padding; selected option is a calm `surfaceSelected` fill with an ink check (no bold) | API unchanged |
| `FfEntityPreviewCard` (new) | Live preview at the top of an entity sheet (archetype B) | `FfEntityPreviewCard(leading: FfEntityPreviewCard.disc(context, FfHeroTone.tide, icon), title:, subtitle:, status:, figureCaption:, figure: FfAmountText(lg), footer:, semanticLabel:)`; `FfAccountPreviewCard`, `FfSubscriptionPreviewCard` and the investment/goal/lending previews become thin wrappers over it |
| `FfChoiceTiles<T>` (new) | 3-up grid of icon-led options, ink fill + check when selected, labels wrap to 2 lines | `FfChoiceTiles(options: [FfChoiceTile(value:, icon:, label:)], selected:, onChanged:, columns: 3, layout: stacked/inline)`; `FfAccountTypeTiles`, `FfAssetTypeTiles`, `FfSubscriptionTypeTiles` and the lending direction tiles become wrappers over it |
| `FfDisclosureRow` (new) | The single collapsible "More details" group at the end of a form | `FfDisclosureRow(title: 'More details', children: [...])` |
| `FfMonogramTile` (pending, DS-B15 owns the file) | Initials should ignore tokens with no letter or digit ("Friend / Person" gives "F/" today); empty name should show a person icon | Reported to the Subscriptions chat; Lending can also pass an empty name |

## Adding or changing a component

1. Shared file in `lib/shared/widgets/`, tokens in `lib/theme/tokens/ff_component_tokens.dart`.
2. Widget test in `test/widget/components/` covering each palette and mode, 2× text, reduced effects, semantics.
3. Add it to `tool/screenshots/bloom_screenshots_test.dart` and re-capture.
4. New colour pair → `FfContrastRules`.
5. Document it in this table in the same commit.
