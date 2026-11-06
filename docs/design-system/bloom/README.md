# Stillwater Bloom: the design reference for every screen

This folder is the **single source of truth** for how FinanceFlow looks and how its screens are built. Every chat
that touches UI reads it first, follows it, and updates it in the same commit as its work. If a screen you design
does not match what is written here, the screen is wrong or this folder is out of date; fix one of them, never
leave them disagreeing.

Bloom is the visual language of the **Stillwater** design system (code prefix `Ff`). It was approved by the owner
on 2026-11-06 (decision record: [../01-bloom-proposal.md](../01-bloom-proposal.md); visual proposal:
[../bloom-preview.html](../bloom-preview.html)).

## Read in this order

| File | What it answers | When |
|---|---|---|
| [01-direction.md](01-direction.md) | What Bloom feels like, the principles, the do's and don'ts, what is never copied from the reference | Always, first |
| [02-foundations.md](02-foundations.md) | Colours, hero gradients, type, numerals, shape, spacing, density, elevation, effects, contrast rules, and how to read each in code | Before writing any widget |
| [03-components.md](03-components.md) | Every shared `Ff*` widget: what it is for, its API, when not to use it | Before building any screen part |
| [04-screen-recipes.md](04-screen-recipes.md) | Page anatomy for each kind of screen (hero tab, list, detail, form/sheet, settings), with the screens that already follow it | Before laying out a screen |
| [05-screen-status.md](05-screen-status.md) | Which screens, sheets and widgets are redesigned, which are not, who owns what | Before starting, and update when done |
| [06-workflow.md](06-workflow.md) | The step-by-step process for one screen, the repo gates, screenshots, tests, commit rules, definition of done | While working |

Prompts for new chats live in [prompts/](prompts/): `screen-redesign-template.md` (any screen) and
`07-budgets-redesign.md` (DS-B7), `08-insights-redesign.md` (DS-B8) and `09-more-redesign.md` (DS-B9) and `10-add-transaction-redesign.md` (DS-B10), `11-add-account-redesign.md` (DS-B11), `12-home-widgets-redesign.md` (DS-B12), `13-home-header-redesign.md` (DS-B13), `14-goals-review-investments-redesign.md` (DS-B14), `15-subscriptions-redesign.md` (DS-B15), `16-settings-redesign.md` (DS-B16) `17-lock-export-import-redesign.md` (DS-B17), `18-lending-borrowing-redesign.md` (DS-B18) and `19-brand-splash-onboarding.md` (DS-B19).

Also binding: `AGENTS.md` (backup gate, standalone-startup gate), [../CHANGELOG.md](../CHANGELOG.md) (slice log,
In flight table, decisions), and the memory rules in 06-workflow.md (format only touched files, commit only your
own paths).

## Golden screens

When in doubt, copy the structure of a screen that is already done. Their screenshots are the visual spec:

| Pattern | Screen | Code | Screenshot |
|---|---|---|---|
| Hero tab on the aurora | Home | `lib/features/dashboard/dashboard_screen.dart` | `../screenshots/ds-b4/home.png` |
| Everyday list | Money | `lib/features/transactions/transactions_screen.dart` | `../screenshots/ds-b5/money.png` |
| Overview + item cards | Loans, Accounts | `lib/features/loans/loans_screen.dart`, `lib/features/accounts/accounts_screen.dart` | `../screenshots/ds-b6/b6_loans.png`, `b6_accounts.png` |
| Detail | Loan detail | `lib/features/loans/loan_detail_screen.dart` | `../screenshots/ds-b6/b6_loan_detail.png` |
| Every component | Component sheet | `tool/screenshots/bloom_screenshots_test.dart` | `../screenshots/ds-b3/bloom_components.png` |

## Keeping this folder true

- Add a component to `03-components.md` in the same commit that adds it to `lib/shared/widgets/`.
- Add a pattern to `04-screen-recipes.md` the first time a screen needs one that isn't listed.
- Move a screen to "done" in `05-screen-status.md` in the commit that finishes it, with the commit hash and the
  screenshot path.
- A new rule or token decision goes in `../CHANGELOG.md` → Decisions **and** in the matching file here.
