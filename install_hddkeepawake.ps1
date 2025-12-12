param(
    [Parameter(Mandatory=$true, HelpMessage="Enter the drive label (e.g., EX12T)")]
    [string]$DriveLabel,

    [Parameter(Mandatory=$true, HelpMessage="Enter the repetition interval in minutes (e.g., 5 or 10)")]
    [int]$IntervalMinutes
)

# Configuration
$TargetScriptName = "usbhddawake.ps1"
$TaskName = "Keep $DriveLabel Awake"
$PsExePath = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"

# 1. Determine the dynamic path
if ([string]::IsNullOrEmpty($PSScriptRoot)) {
    Write-Error "This script must be saved as a file and executed to detect the directory properly."
    return
}

$ScriptPath = Join-Path -Path $PSScriptRoot -ChildPath $TargetScriptName
$Description = "Keeps the external drive '$DriveLabel' awake. Script location: $ScriptPath"

# 2. Check if the target script exists
if (-not (Test-Path -Path $ScriptPath)) {
    Write-Error "Target script '$TargetScriptName' not found in: $PSScriptRoot"
    Write-Warning "Please ensure both this setup script and '$TargetScriptName' are in the same folder."
    return
}

# 3. Clean up existing task
$existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if ($existingTask) {
    Write-Host "Found existing task. Removing it..." -ForegroundColor Yellow
    try {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction Stop
    } catch {
        Write-Error "Failed to remove existing task. Close Task Scheduler and run as Admin."
        return
    }
}

# 4. Define the Action
$Action = New-ScheduledTaskAction `
    -Execute $PsExePath `
    -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$ScriptPath`" -DriveLabel `"$DriveLabel`"" `
    -WorkingDirectory $PSScriptRoot

# 5. Define the Principal
$Principal = New-ScheduledTaskPrincipal `
    -UserId $env:USERNAME `
    -LogonType S4U `
    -RunLevel Highest

# 6. Define the Trigger (THE FIX)
# We use the 'Once' parameter set which legally allows RepetitionInterval in the same command.
# We set it to run 'Once' starting NOW, but repeating every X minutes for 20 years (7300 days).
$Trigger = New-ScheduledTaskTrigger `
    -Once `
    -At (Get-Date) `
    -RepetitionInterval (New-TimeSpan -Minutes $IntervalMinutes) `
    -RepetitionDuration (New-TimeSpan -Days 7300)

# 7. Define Settings
$Settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -RunOnlyIfNetworkAvailable:$false

# 8. Register the Task
try {
    Register-ScheduledTask `
        -TaskName $TaskName `
        -Action $Action `
        -Trigger $Trigger `
        -Principal $Principal `
        -Settings $Settings `
        -Description $Description `
        -Force -ErrorAction Stop | Out-Null
        
    Write-Host "Success! Task '$TaskName' installed." -ForegroundColor Green
    Write-Host "Schedule: Starts NOW, repeats every $IntervalMinutes minutes." -ForegroundColor Gray
    Write-Host "------------------------------------------------------"
    
    # 9. Immediate Manual Invocation
    Write-Host "Performing immediate manual check..." -ForegroundColor Cyan
    & $PsExePath -ExecutionPolicy Bypass -File "$ScriptPath" -DriveLabel "$DriveLabel"
}
catch {
    Write-Error "Failed to create task."
    Write-Error $_.Exception.Message
}
