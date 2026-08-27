# Debug startup verification

Compilation, Flutter's first frame, and reaching the actual application screen
are different checks. Hot reload does not exercise Android cold startup or
recompile Kotlin. Run these after changing startup, native plugins, or schemas:

```powershell
flutter analyze
flutter test
./tool/verify_debug_startup.ps1 -Serial <adb-device-serial>
```

Keep the phone unlocked and idle. The script builds a debug APK, installs it as
an update (`adb install -r`), and force-stops/launches it five times via Android's
launcher intent without attaching Flutter's debugger. It requires a **new
process and a rendered application route** each time. It never uninstalls,
clears app data, changes debug/security settings, or saves raw app logs.

`-SkipBuild` tests an already-built APK; it does not verify current source.
Use `-Launches 10` for a longer run. Stop any IDE Flutter run session first.
Physical USB-disconnected behavior still needs an unplug/relaunch check on the
phone; a connected-device test cannot prove that condition.

For older Windows JDKs where Gradle fails with `Unable to establish loopback
connection` and `UnixDomainSockets ... Invalid argument`, use
`-LegacyJdkSocketWorkaround`. This applies `-Djdk.net.unixdomain.tmpdir=.` only to
the build process and restores the environment afterward. It does not mask
compiler errors. Updating the host JDK is separate from application startup.

## Diagnosing the stage that stalled

Debug builds emit fixed, privacy-safe `FinanceFlowStartup` milestones in Android
logcat even without a Dart VM connection:

- Native activity and engine creation (Android tag `FinanceFlowStartup`).
- `Dart main entered` / `runApp submitted`.
- `Waiting for local database` / `Local database ready` (or unavailable).
- `Application route ready` after settings choose onboarding, lock, or home.

No first Flutter frame means investigate native/engine startup. A database
timeout shows a retry screen. Retrying joins an outstanding open rather than
opening Isar twice. Failed opens **never delete the existing database**; schema
or storage problems must be repaired explicitly, with the user's data preserved.
An application-route marker is stronger than a splash-frame marker, but does
not certify every screen or background feature.
