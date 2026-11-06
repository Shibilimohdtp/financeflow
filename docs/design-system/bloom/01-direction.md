# 01 · Direction

## In one paragraph

FinanceFlow should feel like a calm, well-lit room where your money sits in a few soft, solid objects. The page is
a pale wash of lilac, blush and moss light (dark: plum, umber, moss on ink). Money lives in large squircle cards;
the one or two things that matter most on a screen (an account, a loan, a goal, a plan) become grainy gradient
**hero cards** cut from Lichen's colours. Numbers are big and **light**; units (₹, paise, "/120", "%") are small and
quiet. Everything you tap is **ink**. One **lime spark** marks the thing you are looking at right now. Everyday
lists stay plain, dense and fast.

## Principles

1. **Light numbers, heavy meaning.** Hierarchy comes from size and space, never from bold weight. Large amounts are
   Geist 300 with a small currency symbol and small paise (`FfAmountText` split style).
2. **Ink acts, lime points.** Every action and selection is ink (`actionPrimary`): filled buttons, selected pills,
   the selected dock tab, the ↗ open button. Lime (`spark`) is only a **fill** with ink on it: chart value bubble,
   paid check, next-step dot, counter badge. Lime is never text on a light surface and never the only signal.
3. **Effects only where they mean something.** Gradient, grain and glass belong to hero surfaces and the dock.
   Lists, forms and settings are solid. Never put blur or a hero card inside a scrolling list item.
4. **Two densities.** Comfortable for summaries and heroes (card radius 36, padding 20), compact for lists (radius
   24, padding 16). Airy never means sparse: transaction-style lists stay dense.
5. **Private by default, visibly.** An "On-device" cue on top-level screens; amounts hide everywhere the same way
   (`isBlurred`); screen readers never read hidden figures.
6. **Calm money colours.** In lists, spending is ink with a minus sign; income is green with a plus sign. Brick
   (`moneyExpense`) is for over-budget, overdue and error states. Status is never colour alone: always a sign, an
   icon, a badge label or words.
7. **One hero per screen.** At most one or two hero cards (a carousel counts as one). If everything is a hero,
   nothing is.

## Look-and-feel checklist (a screen is "Bloom" when…)

- [ ] It sits on `surfacePage`; top-level hero tabs sit on `FfAurora`, everyday lists on plain canvas.
- [ ] The most important figure is a light split amount (hero or lg size) with a quiet label above it.
- [ ] Cards are `FfCard` / `FfGroupedContainer` / `FfCard.decorationOf` squircles: no hairline borders, soft shadow
      in light, faint rim in dark.
- [ ] Icons sit in tinted **circles** (`FfIconTile`, `FfCategoryTile`) or thin progress rings (`FfProgressRing`).
- [ ] Choices are ink pills (`FfChip`, `FfPillBar`, `FfSegmentedPill`); buttons are pills (`FfButton`).
- [ ] Round header actions use `FfCircleButton`; "open detail" uses `FfInkButton.open` (↗).
- [ ] Progress uses rings, dot matrices, range bands or the pace bar, each with the number in text beside it.
- [ ] Page margin is `FfSpace.pageMargin` (16); no raw numbers, colours, radii or `TextStyle(`s.
- [ ] Works in light and dark, at 2× text, with reduced effects, with amounts hidden, in RTL.

## Inspired by / made ours (do not drift back to the reference)

The mood reference is in `../reference/` (a designer's concept for a loan app). We keep its spirit (aurora canvas,
big squircles, grainy gradient heroes, light numerals, ink pills plus one electric accent, dot-matrix and bubble
data viz, glass, a floating dock) at about 75% resemblance, with our own signature:

| We changed | Why |
|---|---|
| Palette from Lichen (moss, mineral rose, mushroom, tide, sand) instead of their green/peach | Our identity |
| The thin ring around a hero icon is a **progress arc** with meaning | Signature detail that carries data |
| Pale heroes (rose, sand) use **ink text**; every hero passes 4.5:1 at its lightest text point | Their white-on-lime fails contrast |
| Dot matrix always has the number next to it; missed months say "missed" | Never colour/dots alone |
| Dock keeps our 5 tabs; selected tab expands to an ink pill **with its label**; bar fallback at large text | Labels stay visible |
| Geist with tabular figures, Indian grouping, a dense inline amount style for rows | Money must line up |

**Never copy:** their names, bank brands, copy ("24/38", "Your Credits"), photography/backdrops, avatar header,
credit-bureau UI, italic labels, or white text on light lime.

## Copy voice

Plain, kind, specific. "Left to pay", "Safe to spend today", "September missed · paid late on 9 Oct". No jargon, no
shaming, no exclamation marks. Sentence case for titles and buttons. Section labels are sentence case (the old
ALL-CAPS labels are being retired screen by screen).
