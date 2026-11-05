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
| DS-0 Audit, proposal, audit script, this log | done (uncommitted proposal) | waiting for owner approval of section 7 questions |
| DS-1 Token core + `context.ff` + shims | not started | blocked on approval |
| DS-2 Contrast/CVD guardrail test | not started | |
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
| 2026-11-05 | Productization chat (this design-system work) | DS-0 proposal | `docs/design-system/`, `tool/design_system_audit.dart` |

## Done

| Date | Slice | Commit | What changed |
|---|---|---|---|
| 2026-11-05 | Pre-DS (productization chat) | 8c0fb3c, ce9d65b, 02acfb1, b308998 | Home declutter, transactions list rebuild, Insights rework, shared `FfPeriodBar`. Built on the old Stillwater tokens, so they still need DS-7 migration. |

## Decisions

| Date | Decision | By |
|---|---|---|
| 2026-11-05 | App name stays FinanceFlow, and the current Lichen look stays the default identity (refined, not replaced). | owner |
| 2026-11-05 | Money colours are shared across palettes; income and expense must stay apart under colour blindness (ΔE ≥ 10). Other money types always carry an icon and a label. | proposal, pending owner |
| 2026-11-05 | Theme choice is stored in the existing `AppSettingsEntity.themeMode` string, so no Isar schema change is needed. | proposal, pending owner |
| 2026-11-05 | Space, radius, size and motion tokens are `const` statics. Colour and type are read from `context.ff`. | proposal, pending owner |

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
