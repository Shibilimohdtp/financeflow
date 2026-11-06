# FinanceFlow contributor instructions

## Mandatory user-controlled backup gate

Before starting any operation that could affect a user's existing FinanceFlow
data or device installation, interrupt the task and ask the user to personally
create and verify an encrypted FinanceFlow backup/export. Do not assume that a
backup exists, create one silently on the user's behalf, or continue until the
user explicitly confirms that the backup was created and stored somewhere
recoverable outside the app/device. This gate applies especially before:

- installing, reinstalling, upgrading, downgrading, signing, or changing the
  application ID of an APK on a real device;
- any `adb install`, package replacement, migration, Isar schema/generated-file
  change, database repair, reset, clear-data, uninstall, or restore operation;
- dependency/build configuration changes or other large changes when a real
  device may be used for validation and the app contains user data.

For device work, explicitly tell the user to keep the backup file and its
passphrase, then wait for confirmation before building or installing. If the
user cannot confirm a recoverable backup, stop and ask for direction. Never
run `adb uninstall`, `adb shell pm clear`, or an install command that may
uninstall an existing package as part of this task.

When preserving device data, never use `flutter install`, because it can select
the wrong/stale APK and uninstall the existing package when signing keys do
not match. Build the exact requested APK and use `adb install -r` only. If any
tool reports “Uninstalling old version”, stop immediately, report it, and do
not proceed until the user confirms the backup and recovery plan again.

## Android standalone-startup gate

Any change to Dart bootstrap (`lib/main.dart`, providers, plugins), Android
native code/manifest, local notifications, Isar schemas/generated files, or
dependency/build configuration must preserve a standalone Android launch. A
successful hot reload or a debugger-attached `flutter run` is not sufficient.

Before handing off such a change:

1. Keep `main()` synchronous through `runApp`; do not await database, plugin,
   network, permission, or configuration work before the first Flutter frame.
2. Start nonessential work after a rendered route. Database or settings
   failures must show recoverable in-app UI, never an indefinite branded/native
   splash. Never wipe, rename, or recreate a user's financial database without
   explicit user confirmation and a recovery plan.
3. Run `flutter analyze` and the affected tests, including `test/widget_test.dart`
   and `test/integration/isar_startup_test.dart` when startup or persistence is
   touched.
4. Build both `flutter build apk --debug` and `flutter build apk --release`.
   On this Windows setup, retry Gradle's loopback/JDK error with
   `JAVA_TOOL_OPTIONS=-Djdk.net.unixdomain.tmpdir=.` for that build only.
5. With a device connected but **without** `flutter run` attached, run
   `./tool/verify_debug_startup.ps1 -Serial <device-serial>` to install the
   debug update over existing data and cold-launch it repeatedly. Then unplug
   USB, swipe the app away, and relaunch once. Check the app reaches onboarding,
   lock, or home—not just the first Flutter frame.

Use only fixed, privacy-safe startup milestones in logs. Do not emit account,
transaction, SMS, notification, or settings contents while diagnosing startup.

## UI and design-system work

Before changing anything visual (theme, colours, typography, spacing, shared widgets, screen layouts), read
`docs/design-system/bloom/README.md` and the files it lists (the Stillwater Bloom direction, tokens, components,
screen recipes, screen status and workflow; they are the single reference every screen must match), then
`docs/design-system/CHANGELOG.md`. It records which design-system slices are done, which files another chat
is working on right now, and the decisions already made. Add your work to its "In flight" table when you
start, and update it in the same commit when you finish. The full plan is in
`docs/design-system/00-audit-and-proposal.md`; track leakage with
`dart run tool/design_system_audit.dart --shared`.
