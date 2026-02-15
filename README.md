# Notepad++ Smart Upgrade Script

Production-safe Notepad++ upgrade automation script for enterprise environments.

This script upgrades Notepad++ **only if:**

- Notepad++ is already installed
- Installed version is NOT equal to target version
- Installer executable exists next to the script

It is designed for use with:

- VMware Dynamic Environment Manager (DEM)
- Login elevated tasks
- VDI environments
- Enterprise deployment scenarios

---

## Features

✔ Detects existing installation (Program Files & x86)  
✔ Validates installed version via registry  
✔ Skips install if already latest version  
✔ Finds installer automatically in script directory  
✔ Copies installer to local TEMP (fixes UNC security warnings)  
✔ Performs silent in-place upgrade  
✔ Cleans up temp files  

---

## Target Version

Default target version:

```
8.9.1
```

To change target version:

```powershell
$TargetVersion = "8.9.1"
```

---

## How It Works

1. Checks if Notepad++ is installed (folder + uninstall.exe)
2. Reads installed version from registry:
   ```
   HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Notepad++
   ```
3. Compares installed version with `$TargetVersion`
4. If different:
   - Finds `npp*.Installer*.exe` in script directory
   - Copies installer to `%TEMP%`
   - Unblocks file
   - Executes silent upgrade:
     ```
     /S /D=C:\Program Files\Notepad++
     ```
5. Removes temporary installer

---

## Usage

Place the installer EXE in the same directory as the script:

Example:

```
npp.8.9.1.Installer.x64.exe
```

Run:

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\NotepadPP-SmartUpgrade.ps1
```

---

## Enterprise Deployment Scenario

Recommended for:

- VMware DEM Elevated Login Task
- VDI environments
- Centralized file share deployment
- Secure upgrade enforcement

The script is **idempotent**:
Running multiple times will not reinstall if already at target version.

---

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success / No action needed |
| 1 | Installer not found |

---

## Security Notes

- Installer is copied locally before execution (avoids UNC SmartScreen warnings)
- No forced uninstall
- No user profile removal
- No configuration reset

---

## Example Log Output

```
=== Notepad++ upgrade kontrolu basladi ===
Notepad++ kurulu bulundu: C:\Program Files\Notepad++
Kurulu Notepad++ versiyonu: 8.8.1
Upgrade icin installer bulundu: npp.8.9.1.Installer.x64.exe
Notepad++ uzerine kurulum baslatiliyor...
=== Notepad++ upgrade islemi tamamlandi ===
```

---

## License

MIT License
