# USB Drive Keep-Awake Utility

A lightweight PowerShell solution to prevent external hard drives from entering sleep mode (spinning down). This prevents the "File Explorer Freeze" that occurs when Windows waits for a sleeping drive to spin back up.

## How It Works

1.  **`usbhddawake.ps1`**: Finds your drive by its Label (e.g., "12TB") and appends a timestamp to a log file (`keepalive_log.txt`) on that drive. The write operation resets the drive's firmware sleep timer.
2.  **`install_hddkeepawake.ps1`**: Creates a Windows Scheduled Task that runs the script silently in the background at a set interval.

## Features

* **Silent Operation:** Runs in the background (S4U mode) with no flashing PowerShell windows.
* **Dynamic Pathing:** The scripts can live anywhere; the installer automatically detects the path.
* **Auto-Cleanup:** The installer automatically removes old versions of the task before creating a new one.
* **Robust Scheduling:** Uses a "Start Now + Repeat Indefinitely" trigger logic that survives reboots.

## Installation

1.  Download or clone this repository to a permanent location (e.g., `C:\Scripts\USBKeepAwake`).
2.  Open **PowerShell as Administrator**.
3.  Run the installation script with your Drive Label and desired Interval (in minutes).

```powershell
cd C:\Scripts\USBKeepAwake
.\install_hddkeepawake.ps1 -DriveLabel "YOUR_DRIVE_LABEL" -IntervalMinutes 5
```

*Replace `"YOUR_DRIVE_LABEL"` with the name of your drive (e.g., "BackupPlus", "12TB").*
*Replace `5` with the number of minutes (choose a number lower than your drive's sleep timeout).*

## Verification

1.  Open your external drive.
2.  Look for a file named `keepalive_log.txt`.
3.  Open it and verify that new timestamps are appearing according to your schedule.

## Uninstallation

To stop the utility, you can remove the scheduled task using one of two methods:

**Method 1: Using PowerShell (Recommended)**
Open PowerShell as Administrator and run:

```powershell
Unregister-ScheduledTask -TaskName "Keep YOUR_DRIVE_LABEL Awake"
```
*(Replace `YOUR_DRIVE_LABEL` with the actual label you used during installation)*

**Method 2: Using Task Scheduler UI**
1. Press `Win + R`, type `taskschd.msc`, and hit Enter.
2. In the **Task Scheduler Library**, find the task named **"Keep [YourLabel] Awake"**.
3. Right-click the task and select **Delete**.

## Maintenance

* **Log File Growth:** The script appends a short text line to `keepalive_log.txt` every time it runs.
* **Size Impact:** The file grows very slowly (approx. 25-30 MB per year if running every minute).
* **Cleanup:** You can safely delete `keepalive_log.txt` manually at any time. The script will simply create a new one on its next scheduled run.
