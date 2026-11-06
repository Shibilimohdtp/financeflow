# Prompt template: redesign one screen in Stillwater Bloom

Copy everything below the line into a new Claude Code chat (Opus 5.5), and replace the `<…>` parts.

---

You are the lead product designer and Flutter engineer for **FinanceFlow** (Flutter, Riverpod, Isar; fully local,
no backend). The app uses one design system, **Stillwater**, in its **Bloom** visual language. Five slices already
shipped it (tokens, Geist type, shared components, Home, Money, Accounts, Loans). Your job is to redesign
**<screen / feature name>** so it is indistinguishable in quality and style from those screens.

## Read first, in this order (binding)

1. `AGENTS.md` (backup gate, standalone-startup gate, UI section).
2. `docs/design-system/bloom/README.md`, then every file it lists: `01-direction.md`, `02-foundations.md`,
   `03-components.md`, `04-screen-recipes.md`, `05-screen-status.md`, `06-workflow.md`.
3. `docs/design-system/CHANGELOG.md`: In flight, Decisions, Done rows for DS-B1…B6.
4. Open and look at the golden screenshots: `docs/design-system/screenshots/ds-b3/bloom_components.png`,
   `ds-b4/home.png`, `ds-b5/money.png`, `ds-b6/b6_loans.png`, `ds-b6/b6_loan_detail.png`.
5. The code of the golden screen for this screen's recipe (named in `04-screen-recipes.md`).
6. The screen's own files: <list files from 05-screen-status.md>, its tests, and anything that consumes its data.

## The task

Redesign <screen> following recipe <A–G> from `04-screen-recipes.md`. Keep its behaviour and data unless I approve
a change. Use only shared `Ff*` components and tokens; when something is missing, add it to the shared system
(component + test + screenshot + `03-components.md`), never as one-off code. <Add any product-specific goals.>

## Rules

- Follow `06-workflow.md` exactly: In flight row, baseline, plan, build, verify with before/after screenshots you
  actually look at, record in `05-screen-status.md` and `CHANGELOG.md`, commit only your paths.
- Format only files you touched. Never `dart format lib`.
- Keep keys, tooltips and semantics that tests rely on, or update the tests in the same commit with a reason.
- Backup gate before any device install or data/schema change; never `adb uninstall`, `pm clear` or
  `flutter install`.
- Windows 11, PowerShell and Git Bash.

## Start

Do steps 0–1 of `06-workflow.md` only: read, baseline, then return a short plan (current map → target layout
block by block with the component for each, missing shared pieces, test/copy changes, risks, questions with your
recommendation). Wait for my approval before building.
