# Design system & redesign log

The shared record for every chat working on FinanceFlow's look: tokens, components, palettes, screen
redesigns. **Read this before starting UI work and update it in the same commit as your change.** It exists so
two chats never redo or undo each other's work.

The plan and its reasoning are in [00-audit-and-proposal.md](00-audit-and-proposal.md).

## How to use this file

1. Before you start: read **In flight**. If your files overlap a row there, stop and coordinate through the
   owner instead of editing.
2. When you start a slice: add a row to **In flight** with the chat/date and the files or folders you will touch.
3. When you finish: move it to **Done** with the commit hash, update **Slice status**, re-run
   `dart run tool/design_system_audit.dart --shared` and add a row to **Leakage over time**. Record any new
   decision in **Decisions**.
4. Only commit paths your slice changed. Other chats may have uncommitted work in the same folder.

## Slice status

| Slice | Status | Notes |
|---|---|---|
| DS-0 Audit, proposal, audit script, this log | done (7c6e015) | owner approved the recommendations 2026-11-05 |
| DS-1 Token core + `context.ff` + shims | done (74c9bec) | no visual change, proven by `test/theme/theme_parity_test.dart` |
| DS-2 Contrast/CVD guardrail test | done (87bda61) | 2 known issues, both fixed by DS-8 |
| DS-3 Bundle fonts, drop `google_fonts` | done (3c44dcd), device check pending | analyze, tests and both APK builds green; cold start on the Pixel waits for the backup gate |
| DS-4a Toast, dialogs, date pickers, banner | done (1d687f2) | budgets files still use the legacy `FfSnackbar`/`FfConfirmDialog` shims and 2 raw pickers until that chat lands |
| DS-4b Shared sheet frame + `showFfSheet`, migrate every sheet | done (5d7660d) | the 3 budgets sheets migrate in DS-7h |
| DS-5a App bars + dividers | done (570f490) | Settings' floating `SliverAppBar` moves with Settings in DS-7; 9 dividers with row-specific indents move with rows in DS-5b |
| DS-5b List rows (`FfRow` merging `FfListRow`/`FfSwitchRow`, raw `ListTile`s, row dividers) | done (cc2fae2) | key-value rows (`_DetailRow`, `_InfoRow`, `_MetricRow`, `_ContributionRow`) and the two lending-history `ListTile`s move to DS-6 with their dividers |
| DS-5c Inputs (`FfTextField`, `FfSelect`, menus) | done (6ee02b2) | 6 amount inputs with custom styles move to `FfAmountField` in DS-6; 2 compact inline `DropdownButton`s (CSV column mapping, transaction purpose) move with their screens in DS-7 |
| DS-6 Data display & charts | done (0392127) | ad-hoc status pills and stat layouts inside screens adopt `FfBadge`/`FfStatTile` in DS-7 |
| DS-7a–g Feature migrations (token sweep) | done (commit "feat(ui): DS-7 …") | every feature folder except budgets now reads `context.ff` and `Ff*` tokens; per-screen restructuring (FfScaffold, FfBadge/FfStatTile adoption) happens in the screen redesigns |
| DS-7h Budgets migration | not started | blocked on the budgets redesign chat (In flight) |
| DS-8 Refinement, new palettes, theme picker | not started | |
| DS-9 Remove shims, enable guardrails | not started | |
| DS-10 Gallery, docs, one-token demo | not started | |

## In flight (do not touch without coordinating)

| Since | Chat / owner | Scope | Files |
|---|---|---|---|
| 2026-11-05 | Budgets redesign chat | Budgets engine + UI | `lib/services/budgets/`, `lib/models/budget.dart`, `lib/core/money/money_math.dart`, `test/unit/budgets/`, `lib/features/budgets/`, `docs/features/budgets.md` (uncommitted when this log was written) |

## Done

| Date | Slice | Commit | What changed |
|---|---|---|---|
| 2026-11-05 | DS-0 | 7c6e015 | Audit, proposal, palette preview, `tool/design_system_audit.dart`, this log, AGENTS.md pointer. |
| 2026-11-05 | DS-7 | "feat(ui): DS-7 …" | Mechanical token sweep of 76 files in `lib/features` (all but budgets) and `lib/shared/widgets`, done by a scripted codemod and then hand-fixed. `StillwaterTokens.*` → `FfSpace`/`FfRadius`/`FfIconSize`/`FfMotion` and component tokens (1,437 sites); `Theme.of(context).textTheme` and raw `fontSize`/`TextStyle(...)` → `context.ff.text` roles (432); `colorScheme` and theme colour getters → `context.ff.color` roles (601); `finColors`/`statusColors`/`accentColors`/`secColors` → roles; alpha literals → `FfTint`/`FfOpacity` (105); numeric `SizedBox`/`EdgeInsets`/radius/`Duration` → steps (118). `FfTint.whisper` (0.04) and `FfOpacity.half`/`muted`/`high` were added so no value shifted. Shims (`StillwaterTokens`, `FfListRow`, `FfSnackbar`, `FfConfirmDialog`) stay for budgets until DS-9. Font sizes snap to the nearest role, so a few texts move by 1 dp (e.g. the overdue-EMI body is now `bodySm`); screenshots in `screenshots/ds-7/`. |
| 2026-11-05 | DS-6 | 0392127 | `FfAmountText` now takes a `tone` instead of a raw `colorOverride` (13 sites converted), clamps text scale to 1.3× and hides blurred figures from screen readers. `FfAmountField` was rebuilt as the real money input (outlined, plus `.bare` for hero panels, two-decimal input, tone-coloured symbol); the 5 hand-built amount inputs now use it, including Add transaction's. New `FfProgressBar` (sizes, palette track, pace marker, percent semantics) replaced 13 linear bars; `FfLoading` replaced 11 bare spinners. New `FfBadge`, `FfKeyValueRow` (row geometry, so dividers align) and `FfStatTile`; 4 private detail-row widgets (28 uses) now render `FfKeyValueRow`. `FfCard` is tokenized with a `tone` for the tinted variant. Chart axis labels, bar highlight and donut labels use tokens; donut labels pick palette ink/paper instead of pure black/white. Screenshots in `screenshots/ds-6/` (visually unchanged, as intended). |
| 2026-11-05 | DS-5c | 6ee02b2 | `FfTextField` (label/hint/helper/error/icon/prefix/suffix slots, theme-owned decoration; `.search` with a built-in clear button), `FfSelect<T>` (field-styled dropdown, raised menu surface, field radius) and `FfMenuButton<T>` with `FfMenuItem` (icons, destructive entries). Migrated 41 text fields and 11 dropdowns by script, dropping 17 kinds of per-site decoration overrides (border radius, padding, label/hint styles, fill). Also migrated the category picker search box, the loan form field helper and the account overflow menu. Screenshots in `screenshots/ds-5c/`. `tool/screenshots/compare.py` now produces before/after sheets for any slice. |
| 2026-11-05 | DS-5b | cc2fae2 | `FfRow`: plain icon, tone tile (`FfIconTile`) or custom leading; `detail`, chevron, `selected` check or custom trailing; `.toggle`, `.checkbox`, `.radio`; `destructive`; 48 dp minimum; one merged semantics node per row (label, state, tap). Added `FfTone` (one colour mapping for components) and `FfIconTile`. `FfGroupedContainer` now owns the dividers (`dividerInset: FfRowLeading.icon/tile`) and takes no raw colours. Migrated 27 Settings rows and 10 groups, Security's rows and groups, 7 `FfListRow`, 11 `FfSwitchRow` and 21 `ListTile`/`SwitchListTile`/`CheckboxListTile`/`RadioListTile`. Deleted `FfSwitchRow` and 8 private row/group/divider widgets. `FfListRow` stays as a legacy shim for budgets. Screenshots in `screenshots/ds-5b/`. |
| 2026-11-05 | DS-5a | 570f490 | `FfAppBar` (string title with one-line ellipsis, optional `subtitle`, `titleWidget` escape hatch, `.search` and `.selection` variants) and `FfDivider` (`()`, `.inset()`, `.spaced()`; hairline in `borderSubtle`). Migrated 33 app bars and 57 dividers in 45 files. The Money tab's search and selection bars now use the variants; the loan detail's custom two-line title became `title` + `subtitle`; Add transaction drops its one-off title style. Tab titles now sit on the 20 dp page margin (Material default was 16); the loan detail title had been flush against the screen edge. Screenshots in `screenshots/ds-5a/`. |
| 2026-11-05 | DS-4b | 5d7660d | New `FfSheet` frame (sheet colour, 28 dp top radius, max 90% height, keyboard lift, bottom safe area) and `showFfSheet` (scroll-controlled, below the status bar, transparent route). 26 callers and 22 sheet frames migrated, among them loan, account, investment, goal, contribution, subscription, lending, advance, repayment, PIN, alert settings, CSV import, category/account/payment pickers, filter, period, bulk-recategorize, settings and the transaction action menu. Things fixed along the way: the advance sheet had a 16 dp radius and no drag handle or labelled close; the payment picker could not scroll; two sheets added the keyboard inset twice; the subscription payment row opened a full screen inside a transparent sheet (it now opens as a page, like everywhere else). The loan form no longer uses `DraggableScrollableSheet`. `test/widget/components/sheet_components_test.dart` covers frame, height cap and scroll, keyboard, safe area and return value, and fails if a raw `showModalBottomSheet` appears outside budgets. Screenshots are in `screenshots/ds-4b/`. |
| 2026-11-05 | DS-4a | 1d687f2 | New shared components: `FfToast` (tones with icons and screen-reader prefix, Undo in `toastAction`, 6 s when there is an action), `FfDialog` (`confirm`, `confirmTyped`, `info`, `withProgress`), `FfBanner` (info/success/warning/error) and `pickFfDate`/`pickFfDateRange`/`pickFfTime` (clamp out-of-range initial dates instead of crashing). Migrated 89 toasts (20 error and 16 validation-warning tones assigned from their messages), 22 confirms, 14 pickers and both raw backup dialogs, in 31 feature files. Picker and dialog shape now come from the theme. New role `statusSuccessContainer`, plus banner contrast rules. `FfSnackbar` and `FfConfirmDialog` are now forwarding shims for the budgets files. Screenshots are in `screenshots/ds-4a/`. |
| 2026-11-05 | DS-3 | 3c44dcd | Fonts bundled in `assets/fonts/`: Manrope 400–800 and Fraunces 600/700, cut from the Google Fonts variable fonts with `tool/fonts/make_static_fonts.py`. OFL licences and provenance are in `assets/fonts/README.md`. `google_fonts` is removed, so nothing fetches fonts at runtime and release now renders Manrope (its manifest has no INTERNET permission, so it never could before). `FfFonts` names the families. Release APK went from 65.1 to 64.4 MB. `test/helpers/app_fonts.dart` loads the real fonts for future screenshots; `test/theme/bundled_fonts_test.dart` checks the manifest, the weights and that text measures differently with them. |
| 2026-11-05 | DS-2 | 87bda61 | `lib/theme/ff_contrast.dart`: WCAG contrast, colour-blindness simulation (Machado 2009) and `FfContrastRules.all`, the 90 colour pairs the app draws. `test/theme/palette_accessibility_test.dart` checks them for every palette in both modes, plus income-vs-expense ΔE ≥ 10. It is a ratchet: known issues are listed with a reason, new failures fail the build, and fixed issues must be deleted. Added the `toastAction` role (snackbar Undo); nothing uses it yet. |
| 2026-11-05 | DS-1 | 74c9bec | Token core: `lib/theme/tokens/` (foundation + component tokens), `palettes/` (Lichen primitives → semantic roles), `FfColors`/`FfText` extensions, `FfTheme.build` (one builder for every palette and mode, replacing two 250-line copies), `context.ff` and the `lib/theme/ff.dart` barrel. Old `Stillwater*` APIs are now forwarding shims. The parity test snapshots the old theme in `test/theme/legacy/` and proves light and dark are identical. |
| 2026-11-05 | Pre-DS (productization chat) | 8c0fb3c, ce9d65b, 02acfb1, b308998 | Home declutter, transactions list rebuild, Insights rework, shared `FfPeriodBar`. Built on the old Stillwater tokens, so they still need DS-7 migration. |

## Decisions

| Date | Decision | By |
|---|---|---|
| 2026-11-05 | App name stays FinanceFlow, and the current Lichen look stays the default identity (refined, not replaced). | owner |
| 2026-11-05 | Money colours are shared across palettes; income and expense must stay apart under colour blindness (ΔE ≥ 10). Other money types always carry an icon and a label. | owner (approved proposal) |
| 2026-11-05 | Theme choice is stored in the existing `AppSettingsEntity.themeMode` string, so no Isar schema change is needed. | owner (approved proposal) |
| 2026-11-05 | Space, radius, size and motion tokens are `const` statics. Colour and type are read from `context.ff`. | owner (approved proposal) |

| 2026-11-05 | The design system is called **Stillwater**. Palettes are Lichen (default), Tide and Graphite, plus a pure-black dark switch. Sandstone stays in the preview only, unless the owner asks for it. Modes are plain Light and Dark. Code uses the `Ff` prefix. | owner |
| 2026-11-05 | Lichen refinements approved for DS-8: expense from raspberry to brick, lighter tertiary text, readable snackbar Undo, brighter cards. | owner |
| 2026-11-05 | Bundle Manrope and the Fraunces weight in use, and drop `google_fonts` (DS-3). Downloading the font files from the Google Fonts GitHub repo is approved. | owner |
| 2026-11-05 | The design-system gallery is debug-only (`kDebugMode`), reached by long-pressing the version row in Settings, and replaces `branding_preview_screen.dart`. | owner |
| 2026-11-05 | Row leading: tinted tile (`iconTone`) for things with an identity (accounts, payees, categories); plain neutral icon for settings and actions. Pickers that close on tap mark the current choice with a trailing check (`selected`); choices inside a form use `FfRow.radio`. | DS-5b |
| 2026-11-05 | Row subtitles use `bodySm` (13 dp), up from 11 dp in Settings. More subtitles wrap to two lines, so settings lists are taller; legibility was the priority. Revisit only together with a dense-mode preference. | DS-5b |
| 2026-11-05 | DS-7 is a mechanical token sweep, not a redesign: every value maps 1:1 to a token or the nearest type role, so screens look the same. Layout restructuring is left to the per-screen redesigns that follow. Budgets is excluded while its chat is in flight. | DS-7 |
| 2026-11-05 | `FfScaffold` (page template) is not built separately. It arrives during the DS-7 screen migrations, where each body is restructured anyway, so it is designed against real screens rather than in the abstract. | DS-5a |
| 2026-11-05 | App bar titles: without a back/close button they start at the page margin (`FfSpace.pageMargin`); with one, they keep Material's spacing after it. Titles are one line; the theme sets the style. | DS-5a |
| 2026-11-05 | Sheets use the page colour (`surfaceSheet` = page in Lichen), which 17 of 22 sheets already used. Their inputs and cards keep the same contrast as on full screens. The theme's `bottomSheetTheme` follows, and the parity test records this one intended difference. | DS-4b |
| 2026-11-05 | Every sheet may grow to 90% of the screen (`FfSheetTokens.maxHeightFraction`). The old one-offs (75% CSV preview, 70% bulk category picker, 88% alert settings) now follow it. | DS-4b |
| 2026-11-05 | Toast tones: messages that start with "Failed", "Could not" or "Error" use `error`; validation prompts ("Please enter…", "Select the account…") use `warning`; everything else stays neutral. Success stays neutral to keep the app calm. | DS-4a |
| 2026-11-05 | DS-4 is split: sheets (DS-4b) get one shared `FfSheet` frame. About 22 sheet widgets each paint their own background, radius, safe area and keyboard inset, so they migrate together in one slice. | DS-4a |
| 2026-11-05 | Before/after screenshots come from `tool/screenshots/*_test.dart`, run with `--update-goldens` at the old commit (in a temporary git worktree) and at the new one, using the real bundled fonts and icons. They are combined into side-by-side sheets in `docs/design-system/screenshots/<slice>/`. | DS-4a |
| 2026-11-05 | Fraunces is pinned to optical size 24, plain letterforms (`WONK` 0) and `SOFT` 0. It is used only by the display roles (onboarding title, loan hero). | DS-3 |
| 2026-11-05 | Contrast rules live in `lib/theme/ff_contrast.dart` as data, not in the test, so the gallery can show the same numbers. When a component starts drawing a new colour pair, add a rule. | DS-2 |
| 2026-11-05 | `FfSpace` keeps the legacy step names (`lg` = 20) so migration never shifts a value. Legacy APIs get a doc comment, not `@Deprecated`, so `flutter analyze` stays a clean gate until DS-9. | DS-1 |

## Known accessibility issues

These are the open items. Palette items are also listed in `knownIssues` in `test/theme/palette_accessibility_test.dart`.

| Issue | Where | Fixed by |
|---|---|---|
| Income and expense too similar under deuteranopia (ΔE 5.8 light, 9.7 dark) | Lichen palette | DS-8 (expense moves to brick) |
| Text sizes 9 and 10 used in feature code, below the type scale | 6 files: budgets (4), the dashboard budget card and the alerts inbox badge | DS-7h and the screen redesigns |

## Leakage over time

Command: `dart run tool/design_system_audit.dart --shared` (lib/ minus lib/theme/ and lib/shared/).

| Date | Commit | Colors.* | Color(0x | alpha tints | static colors | fontSize | TextStyle( | EdgeInsets# | SizedBox# | AppBar( | bottom sheets | dialogs | pickers | Divider( |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 2026-11-05 | b308998 | 5 | 22 | 170 | 61 | 154 | 44 | 22 | 89 | 36 | 30 | 4 | 16 | 71 |
| 2026-11-05 | DS-4a | 5 | 22 | 170 | 61 | 153 | 43 | 25* | 86 | 36 | 30 | 0 | 2 | 71 |
| 2026-11-05 | DS-4b | 5 | 22 | 170 | 57 | 153 | 43 | 25 | 86 | 36 | 3 | 0 | 2 | 71 |
| 2026-11-05 | DS-5a | 5 | 22 | 169 | 57 | 152 | 43 | 25 | 86 | 4 | 3 | 0 | 2 | 14 |
| 2026-11-05 | DS-5b | 5 | 22 | 165 | 57 | 145 | 42 | 25 | 80 | 4 | 3 | 0 | 2 | 9 |
| 2026-11-05 | DS-5c | 5 | 22 | 162 | 55 | 142 | 41 | 25 | 80 | 4 | 3 | 0 | 2 | 9 |
| 2026-11-05 | DS-6 | 5 | 22 | 158 | 55 | 140 | 41 | 24 | 80 | 4 | 3 | 0 | 2 | 8 |
| 2026-11-05 | DS-7 | 5 | 22 | 158† | 55 | 31 | 7 | 4 | 21 | 4 | 3 | 0 | 2 | 8 |

\* Not new literals: formatting joined multi-line `EdgeInsets` calls onto one line, where the line-based check now counts them. The remaining 2 pickers and 3 sheets are in budgets (other chat).
† The alpha check counts every `withValues(alpha:)`, including the token form `withValues(alpha: FfTint.faint)`; after DS-7 only budgets, models and `main.dart` still pass raw numbers. Static colours left: `lib/models/category_colors.dart` and `money_record.dart` (data-owned colours, DS-9) and budgets.

## Screens redesigned

Record each screen when it is migrated to tokens and components. "Visual verified" means screenshots were
checked in light and dark; say where (golden, emulator, Pixel 7).

| Screen | Slice | Commit | Visual verified |
|---|---|---|---|
| Toast with Undo, delete confirm, date picker (shared overlays used across the app) | DS-4a | 1d687f2 | golden capture, light and dark, before and after: `screenshots/ds-4a/` |
| All bottom sheets outside budgets (loan, goal, category, account and payment pickers shown) | DS-4b | 5d7660d | golden capture, light and dark, before and after: `screenshots/ds-4b/` |
| Loans list and loan detail (app bar alignment, two-line title) | DS-5a | 570f490 | golden capture, light and dark, before and after: `screenshots/ds-5a/` |
| Settings hub, App Settings, Security (rows, groups, dividers, toggles) | DS-5b | cc2fae2 | golden capture, light and dark, before and after: `screenshots/ds-5b/` |
| Loan, goal and category forms (fields, selects, search) | DS-5c | 6ee02b2 | golden capture, light and dark, before and after: `screenshots/ds-5c/` |
| Loans list and loan detail (amounts, progress, key-value rows) | DS-6 | this commit | golden capture, light and dark, before and after: `screenshots/ds-6/` (unchanged by design) |
| Every feature screen outside budgets (token sweep; Loans and Settings shown) | DS-7 | this commit | golden capture, light and dark, before and after: `screenshots/ds-7/` (text-role snapping only) |
