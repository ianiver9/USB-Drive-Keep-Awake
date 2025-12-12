param(
    [Parameter(Mandatory=$true)]
    [string]$DriveLabel
)

# Configuration
$logFileName  = "keepalive_log.txt"

# Find the drive with the specific label
$drive = Get-Volume | Where-Object { $_.FileSystemLabel -eq $DriveLabel }

if ($drive -and $drive.DriveLetter) {
    $driveLetter = $drive.DriveLetter
    $logPath  = "$driveLetter`:\$logFileName"
    
    try {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = "[$timestamp] Keep-alive: $DriveLabel is awake."
        
        # The action of appending text forces a Write I/O, which resets the sleep timer.
        Add-Content -Path $logPath -Value $logEntry
        
        # Print to console (only visible during manual testing)
        Write-Host $logEntry
    }
    catch {
        Write-Error "Error: Could not write to drive ${driveLetter}:"
    }
} else {
    Write-Warning "Drive labeled '$DriveLabel' not found."
}
