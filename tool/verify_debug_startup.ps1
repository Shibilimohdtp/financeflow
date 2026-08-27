[CmdletBinding()]
param(
    [string]$Serial,
    [string]$AdbPath,
    [ValidateRange(1, 20)][int]$Launches = 5,
    [ValidateRange(5, 60)][int]$TimeoutSeconds = 30,
    [switch]$SkipBuild,
    [switch]$LegacyJdkSocketWorkaround
)

# Updates the installed debug APK without uninstalling or clearing app data.
# Run while the phone is unlocked and idle; this repeatedly stops the app.
$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$package = 'com.financeflow.app.financeflow'
$oldJavaOptions = $env:JAVA_TOOL_OPTIONS

function Invoke-Adb {
    param([string[]]$AdbArguments)
    $output = & $AdbPath @AdbArguments 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "adb failed: $($AdbArguments -join ' ')`n$($output -join [Environment]::NewLine)"
    }
    return ($output -join [Environment]::NewLine)
}

Push-Location $projectRoot
try {
    if (-not $AdbPath) {
        $sdk = $env:ANDROID_HOME
        if (-not $sdk) { $sdk = $env:ANDROID_SDK_ROOT }
        if (-not $sdk) { $sdk = Join-Path $env:LOCALAPPDATA 'Android/sdk' }
        $AdbPath = Join-Path $sdk 'platform-tools/adb.exe'
    }
    if (-not (Test-Path -LiteralPath $AdbPath)) { throw 'Provide -AdbPath for your Android SDK.' }
    $connected = Invoke-Adb -AdbArguments @('devices')
    $serials = @($connected -split '\r?\n' | ForEach-Object {
        if ($_ -match '^(\S+)\s+device$') { $Matches[1] }
    })
    if (-not $Serial) {
        if ($serials.Count -ne 1) { throw 'Connect exactly one authorized device, or provide -Serial.' }
        $Serial = $serials[0]
    }
    if ($Serial -notin $serials) { throw 'The selected device is not connected and authorized.' }

    if (-not $SkipBuild) {
        # Only for old Windows JDKs failing ProcessBuilder with UnixDomainSockets
        # / "Unable to establish loopback connection". No global settings change.
        if ($LegacyJdkSocketWorkaround) {
            $env:JAVA_TOOL_OPTIONS = "$oldJavaOptions -Djdk.net.unixdomain.tmpdir=.".Trim()
        }
        & flutter build apk --debug
        if ($LASTEXITCODE -ne 0) { throw 'Debug build failed; the installed app was not changed.' }
    }
    $apk = Join-Path $projectRoot 'build/app/outputs/flutter-apk/app-debug.apk'
    if (-not (Test-Path -LiteralPath $apk)) { throw 'Debug APK is missing. Run without -SkipBuild.' }
    Write-Host 'Installing debug update while retaining app data...'
    $null = Invoke-Adb -AdbArguments @('-s', $Serial, 'install', '-r', $apk)

    $previousProcess = ''
    for ($launch = 1; $launch -le $Launches; $launch++) {
        $null = Invoke-Adb -AdbArguments @('-s', $Serial, 'shell', 'am', 'force-stop', $package)
        $null = Invoke-Adb -AdbArguments @('-s', $Serial, 'shell', 'am', 'start', '-W',
            '-a', 'android.intent.action.MAIN', '-c', 'android.intent.category.LAUNCHER',
            '-n', "$package/.MainActivity")
        $watch = [Diagnostics.Stopwatch]::StartNew()
        $ready = $false
        while ($watch.Elapsed.TotalSeconds -lt $TimeoutSeconds) {
            $appProcess = (Invoke-Adb -AdbArguments @('-s', $Serial, 'shell', 'pidof', $package)).Trim()
            if ($appProcess -notmatch '^\d+$' -or $appProcess -eq $previousProcess) {
                throw 'Cold launch did not create a new app process.'
            }
            $logs = Invoke-Adb -AdbArguments @('-s', $Serial, 'logcat', '-d', "--pid=$appProcess",
                '-v', 'brief', 'FinanceFlowStartup:I', 'flutter:I', 'AndroidRuntime:E', '*:S')
            if ($logs -match 'FATAL EXCEPTION|Unhandled Exception') {
                throw "Launch $launch reported a runtime exception. Inspect local logcat; no financial payloads were saved by this script."
            }
            if ($logs -match '\[FinanceFlowStartup\] Application route ready') {
                $ready = $true
                break
            }
            Start-Sleep -Milliseconds 500
        }
        if (-not $ready) {
            # Print only fixed milestones, never raw app logs/SMS/financial data.
            $logs -split '\r?\n' | Where-Object { $_ -match '\[FinanceFlowStartup\]' } | Write-Host
            throw "Launch $launch never rendered an application route within $TimeoutSeconds seconds."
        }
        $previousProcess = $appProcess
        Write-Host "PASS launch $launch/$Launches : new process $appProcess rendered the application route."
    }
    Write-Host 'PASS: debug update and repeated launcher starts, with no Flutter debugger attached.'
} finally {
    $env:JAVA_TOOL_OPTIONS = $oldJavaOptions
    Pop-Location
}
