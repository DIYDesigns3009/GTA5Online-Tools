# GTA 5 Online - Tools

A powerful AutoHotkey v2 script designed to provide various utilities and tools for Grand Theft Auto 5 Online on PC. This script helps manage sessions, prevent AFK kicks, automate clicks, and more, all accessible via simple hotkeys and a smart UI.

## 🚀 Key Features

  * **Solo Public Session:** Two different methods (Process Suspend or Port Block) to easily get a solo public lobby.
  * **Anti-AFK:** A simple macro to simulate character movement and prevent being kicked for inactivity.
  * **Auto-Clicker:** A timed, rapid mouse-click macro for 10 seconds.
  * **No Save Mode:** Temporarily blocks the game's save server, allowing you to play without saving progress.
  * **Network Block Mode:** A "kill switch" to block all internet access for the entire game executable.
  * **Smart UI:** A custom tooltip interface that shows which features are active.
  * **Multi-Level UI Visibility:** The UI can be set to Full, Minimized, or completely Minimal (hidden title) to stay out of your way.
  * **Safety Checks:** Prevents conflicting features (like the Solo Session actions) from running at the same time.

-----

## 🛑 Requirements

Before running this script, you **must** meet these requirements:

1.  **[AutoHotkey v2](https://www.autohotkey.com/v2/)**: This script is written for AHK v2 and will not work with v1.
2.  **Run as Administrator**: The script **must** be run with administrator privileges to manage firewall rules and suspend processes. It includes a self-elevation check to request this on launch.
3.  **`PsSuspend.exe` (Critical Dependency)**:
      * The "Solo Session (Suspend)" feature (`Ctrl+F8`) **requires** this tool.
      * It is part of the official **[PsTools Suite](https://learn.microsoft.com/en-us/sysinternals/downloads/pstools)** from Microsoft.
      * You must download PsTools, extract it, and place the `PsSuspend.exe` file in the **same directory** as this AHK script.

-----

## 🛠️ How to Use

1.  Ensure you meet all the requirements above.
2.  Run the script as an administrator.
3.  Launch GTA 5.
4.  Use the hotkeys below to toggle features. The on-screen UI (ToolTip) will show the status of each tool.

### Hotkey Reference

| Hotkey | Feature | Description |
| :--- | :--- | :--- |
| `Ctrl` + `F4` | Toggle UI Mode | Cycles through UI display modes: **Full** -\> **Minimal** -\> **Minimized** -\> **Full**. |
| `Ctrl` + `F5` | Toggle Anti-AFK | Starts/Stops a simple WASD movement macro to prevent AFK kick. |
| `Ctrl` + `F6` | Toggle Auto-Click | Starts/Stops a 10-second rapid mouse click macro. |
| `Ctrl` + `F7` | Solo Session (Ports) | **(Exclusive)** Temporarily blocks specific UDP ports for 10 seconds to force you into a solo public session. |
| `Ctrl` + `F8` | Solo Session (Suspend) | **(Exclusive)** Temporarily suspends the `GTA5.exe` process for 10 seconds to force you into a solo public session. **Requires `PsSuspend.exe`**. |
| `Ctrl` + `F9` | Enable No Save Mode | Blocks the game's save server IP (`192.81.241.171`) via the firewall. |
| `Ctrl` + `F10` | Disable No Save Mode | Removes the firewall rule, allowing the game to save again. |
| `Ctrl` + `F11` | Enable EXE Block Mode | Blocks all internet access for `GTA5.exe` via the firewall. |
| `Ctrl` + `F12` | Disable EXE Block Mode | Removes the firewall rule, restoring internet access. |

-----

## ⚠️ Important Notes

  * **Exclusive Features:** When a "Solo Public Session" method (`Ctrl+F7` or `Ctrl+F8`) is active, all other hotkeys are disabled for its 10-second duration to prevent conflicts.
  * **Firewall Rules:** This script adds and removes rules from the Windows Defender Firewall. All rules are prefixed with `GTAO-` (e.g., `GTAO-NoSave`). The script attempts to clean up all rules when it exits, but you can manually check your firewall settings if needed.
  * **Game Version:** This script targets the PC version and looks for `GTA5.exe` or `GTA5_Enhanced.exe`.

## Credits

  * The advanced `ToolTipOptions` class for the custom UI was originally created by **just me** on the **[AutoHotkey](https://www.autohotkey.com/boards/viewtopic.php?t=113308)** forums.

## 📜 Disclaimer

This tool is for personal and educational use only. Using scripts or tools to modify online game behavior may be against the game's Terms of Service. **Use this script at your own risk.** The creator is not responsible for any penalties or bans on your account.
