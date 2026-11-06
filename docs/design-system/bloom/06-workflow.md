# 06 · Workflow for redesigning one screen

Follow this for every screen so every chat produces the same quality and the same look.

## 0. Before touching anything

1. Read `AGENTS.md`, then this folder in order (README → 01 → 06), then `../CHANGELOG.md` (In flight, Decisions).
2. `git status` and `git log --oneline -5`. The working tree is shared with other chats: never revert, format or
   commit files you didn't change.
3. Check `05-screen-status.md` and the **In flight** table. If another chat owns the files, stop and ask the owner.
   Otherwise add your In flight row (date, chat, scope, exact files) to `../CHANGELOG.md`.
4. Baseline: `flutter analyze`, the screen's widget tests, `dart run tool/design_system_audit.dart --shared`.
5. Look at the golden screenshots for the screen's pattern (`04-screen-recipes.md`) and at
   `../screenshots/ds-b3/bloom_components.png`.

## 1. Plan (short, then ask)

- Map the current screen: sections, data each shows, actions, states, tests that pin texts/keys.
- Write the target layout using the recipe (top-to-bottom list of blocks with the component for each).
- List anything the shared system lacks. Missing pieces become **shared components or tokens**, never local code.
- If the change alters behaviour, data, copy that tests depend on, or adds a feature, present the plan to the owner
  and wait. Pure visual migration to the recipe can proceed.

## 2. Build

- Feature code uses only `context.ff`, `Ff*` tokens and shared widgets. No raw colours, sizes, radii, durations,
  `TextStyle(`, `BorderRadius.circular(<n>)`, `Colors.*` (except transparent), `withValues(alpha: <n>)`.
- Keep existing keys, semantics labels and tooltips that tests or accessibility rely on; when you must change one,
  update the test in the same commit and say why.
- Amounts: `FfAmountText` only (split for hero/lg, inline for rows). Inputs: `FfAmountField`.
- Split files over ~500 lines into private widgets or files as you go.
- **Format only the files you touched**: `dart format <file> <file>`. Never `dart format lib` or a whole folder
  (it rewrites generated Isar files and other chats' work).

## 3. Verify

- `flutter analyze` → no issues.
- Tests: the screen's tests, `test/widget/components/`, `test/theme/`, and `test/widget_test.dart`; then the full
  suite `flutter test -j 2 --timeout 90s` before committing.
- Screenshots: add or extend a capture test in `tool/screenshots/` that uses only APIs present at the previous
  commit, then run `python tool/screenshots/compare.py <slice> tool/screenshots/<file>_test.dart <name>…` to write
  before/after sheets (light and dark) to `../screenshots/<slice>/`. **Look at them** (open the PNGs) and fix what
  you see: overflow, clipped text, wrong colours on heroes, empty areas, missing states. Check 2× text in a widget
  test.
- `dart run tool/design_system_audit.dart --shared`: numbers must not go up.
- Say plainly what you could not verify (device, performance, grain in goldens).

## 4. Record and commit

In the same commit:
- `05-screen-status.md`: status → Bloom (commit hash after committing, or "this commit"), notes.
- `../CHANGELOG.md`: remove your In flight row; Slice status; a Done row (what changed, screenshots path); new
  Decisions; a Leakage row; a "Screens redesigned" row.
- `03-components.md` / `04-screen-recipes.md` if you added a component or a pattern.

Commit only your paths: `git add -A -- <paths>` then `git commit -- <paths>` with a message like
`feat(ui): DS-B7 Budgets in Stillwater Bloom`, ending with the attribution line the session gives you.

## Repo gates (from AGENTS.md; non-negotiable)

- **Backup gate**: before anything that could affect user data or a device install (adb install, Isar
  schema/generated files, migrations, reset/restore), stop and ask the owner to make and verify an encrypted
  FinanceFlow backup and keep the file and passphrase. Wait for explicit confirmation. Never create one for them.
  Never `adb uninstall`, `adb shell pm clear` or `flutter install`; use `adb install -r` only.
- **Standalone-startup gate**: changes to `main.dart`, providers bootstrap, plugins, notifications, Isar schemas,
  `pubspec.yaml`/assets/build config need `flutter analyze`, the affected tests including `test/widget_test.dart`
  and `test/integration/isar_startup_test.dart`, `flutter build apk --debug` and `--release` (Windows: retry with
  `JAVA_TOOL_OPTIONS=-Djdk.net.unixdomain.tmpdir=.`), and `./tool/verify_debug_startup.ps1 -Serial <device>` once a
  device is available.
- Never log financial data. Theme/style preferences live in `AppSettingsEntity.themeMode` (no schema change).
- Environment: Windows 11; PowerShell and Git Bash are both available.

## Definition of done (per screen)

- [ ] Matches its recipe and the look-and-feel checklist in `01-direction.md`.
- [ ] Light, dark, 2× text, amounts hidden, reduced effects, empty/loading/error states all handled.
- [ ] No new leakage; contrast tests green; analyze clean; full test suite green.
- [ ] Before/after screenshots committed and actually looked at.
- [ ] `05-screen-status.md` and `../CHANGELOG.md` updated in the same commit; only own paths committed.
