# Stillwater design system

FinanceFlow's design system. This folder is the reference for every chat or contributor doing UI work.

- [CHANGELOG.md](CHANGELOG.md): **start here.** Slice status, what is in flight and who owns it, decisions, and leakage numbers over time.
- [00-audit-and-proposal.md](00-audit-and-proposal.md): the audit, token architecture, palettes, component inventory and migration plan.
- [palettes-preview.html](palettes-preview.html): open in a browser to see the proposed palettes with their contrast results. Regenerate it with
  `python palette_check.py out.json` and then `python palette_render.py out.json palettes-preview.html`, both run from this folder.
  These scripts are proposal tooling. DS-2 replaces the check with a Dart test against the real theme.

Measure progress with `dart run tool/design_system_audit.dart --shared`.

Pages still to come (slice DS-10): principles, token reference, component catalog with do/don't, adding a palette,
adding a component, and the migration checklist.
