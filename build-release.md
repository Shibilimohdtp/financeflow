$env:JAVA_TOOL_OPTIONS='-Djdk.net.unixdomain.tmpdir=.'
flutter build apk --release
& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" install -r .\build\app\outputs\flutter-apk\app-release.apk
Remove-Item Env:JAVA_TOOL_OPTIONS