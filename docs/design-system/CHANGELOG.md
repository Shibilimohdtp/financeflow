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
| DS-4b Shared sheet frame + `showFfSheet`, migrate every sheet | done (commit "feat(ui): DS-4b …"; hash filled in at the next slice) | the 3 budgets sheets migrate in DS-7h |
| DS-5 Structure & inputs | not started | |
| DS-6 Data display & charts | not started | |
| DS-7a–h Feature migrations | not started | budgets last (DS-7h) |
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
| 2026-11-05 | DS-4b | "feat(ui): DS-4b …" | New `FfSheet` frame (sheet colour, 28 dp top radius, max 90% height, keyboard lift, bottom safe area) and `showFfSheet` (scroll-controlled, below the status bar, transparent route). 26 callers and 22 sheet frames migrated, among them loan, account, investment, goal, contribution, subscription, lending, advance, repayment, PIN, alert settings, CSV import, category/account/payment pickers, filter, period, bulk-recategorize, settings and the transaction action menu. Things fixed along the way: the advance sheet had a 16 dp radius and no drag handle or labelled close; the payment picker could not scroll; two sheets added the keyboard inset twice; the subscription payment row opened a full screen inside a transparent sheet (it now opens as a page, like everywhere else). The loan form no longer uses `DraggableScrollableSheet`. `test/widget/components/sheet_components_test.dart` covers frame, height cap and scroll, keyboard, safe area and return value, and fails if a raw `showModalBottomSheet` appears outside budgets. Screenshots are in `screenshots/ds-4b/`. |
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
| Text sizes 9 and 10 used in feature code, below the type scale | 50 files | DS-5 to DS-7 migrations |

## Leakage over time

Command: `dart run tool/design_system_audit.dart --shared` (lib/ minus lib/theme/ and lib/shared/).

| Date | Commit | Colors.* | Color(0x | alpha tints | static colors | fontSize | TextStyle( | EdgeInsets# | SizedBox# | AppBar( | bottom sheets | dialogs | pickers | Divider( |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 2026-11-05 | b308998 | 5 | 22 | 170 | 61 | 154 | 44 | 22 | 89 | 36 | 30 | 4 | 16 | 71 |
| 2026-11-05 | DS-4a | 5 | 22 | 170 | 61 | 153 | 43 | 25* | 86 | 36 | 30 | 0 | 2 | 71 |
| 2026-11-05 | DS-4b | 5 | 22 | 170 | 57 | 153 | 43 | 25 | 86 | 36 | 3 | 0 | 2 | 71 |

\* Not new literals: formatting joined multi-line `EdgeInsets` calls onto one line, where the line-based check now counts them. The remaining 2 pickers and 3 sheets are in budgets (other chat).

## Screens redesigned

Record each screen when it is migrated to tokens and components. "Visual verified" means screenshots were
checked in light and dark; say where (golden, emulator, Pixel 7).

| Screen | Slice | Commit | Visual verified |
|---|---|---|---|
| Toast with Undo, delete confirm, date picker (shared overlays used across the app) | DS-4a | 1d687f2 | golden capture, light and dark, before and after: `screenshots/ds-4a/` |
| All bottom sheets outside budgets (loan, goal, category, account and payment pickers shown) | DS-4b | this commit | golden capture, light and dark, before and after: `screenshots/ds-4b/` |
