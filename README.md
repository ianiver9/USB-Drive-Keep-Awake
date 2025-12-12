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
