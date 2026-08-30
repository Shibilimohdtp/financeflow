# FinanceFlow contributor instructions

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
