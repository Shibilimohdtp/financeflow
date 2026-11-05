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
| DS-2 Contrast/CVD guardrail test | done (this commit: "test(theme): DS-2 …"; hash filled in at DS-3) | 2 known issues, both fixed by DS-8 |
| DS-3 Bundle fonts, drop `google_fonts` | not started | needs backup gate + device cold start |
| DS-4 Feedback & overlays | not started | |
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
| 2026-11-05 | DS-2 | "test(theme): DS-2 …" | `lib/theme/ff_contrast.dart`: WCAG contrast, colour-blindness simulation (Machado 2009) and `FfContrastRules.all`, the 90 colour pairs the app draws. `test/theme/palette_accessibility_test.dart` checks them for every palette in both modes, plus income-vs-expense ΔE ≥ 10. It is a ratchet: known issues are listed with a reason, new failures fail the build, and fixed issues must be deleted. Added the `toastAction` role (snackbar Undo); nothing uses it yet. |
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
| 2026-11-05 | Contrast rules live in `lib/theme/ff_contrast.dart` as data, not in the test, so the gallery can show the same numbers. When a component starts drawing a new colour pair, add a rule. | DS-2 |
| 2026-11-05 | `FfSpace` keeps the legacy step names (`lg` = 20) so migration never shifts a value. Legacy APIs get a doc comment, not `@Deprecated`, so `flutter analyze` stays a clean gate until DS-9. | DS-1 |

## Known accessibility issues

These are the open items. Palette items are also listed in `knownIssues` in `test/theme/palette_accessibility_test.dart`.

| Issue | Where | Fixed by |
|---|---|---|
| Income and expense too similar under deuteranopia (ΔE 5.8 light, 9.7 dark) | Lichen palette | DS-8 (expense moves to brick) |
| Snackbar Undo drawn in `colorScheme.primary` on the ink snackbar: 2.07:1 in light mode. The palette is fine; `FfSnackbar` uses the wrong role. | `lib/shared/widgets/ff_snackbar.dart` | DS-4 (`FfToast` uses `toastAction`) |
| Text sizes 9 and 10 used in feature code, below the type scale | 50 files | DS-5 to DS-7 migrations |

## Leakage over time

Command: `dart run tool/design_system_audit.dart --shared` (lib/ minus lib/theme/ and lib/shared/).

| Date | Commit | Colors.* | Color(0x | alpha tints | static colors | fontSize | TextStyle( | EdgeInsets# | SizedBox# | AppBar( | bottom sheets | dialogs | pickers | Divider( |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 2026-11-05 | b308998 | 5 | 22 | 170 | 61 | 154 | 44 | 22 | 89 | 36 | 30 | 4 | 16 | 71 |

## Screens redesigned

Record each screen when it is migrated to tokens and components. "Visual verified" means screenshots were
checked in light and dark; say where (golden, emulator, Pixel 7).

| Screen | Slice | Commit | Visual verified |
|---|---|---|---|
| none yet | | | |
