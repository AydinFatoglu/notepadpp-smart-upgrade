# =========================================================
# Notepad++ Upgrade Only (If Installed & Not Latest)
# =========================================================

Write-Host "=== Notepad++ upgrade kontrolu basladi ==="

$TargetVersion = "8.9.1"
$UninstallKey  = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Notepad++"

# ---------------------------------------------------------
# Kurulu mu kontrolu (klasor + uninstall.exe)
# ---------------------------------------------------------
$InstallDirs = @(
    "$env:ProgramFiles\Notepad++",
    "$env:ProgramFiles(x86)\Notepad++"
)

$IsInstalled = $false

foreach ($dir in $InstallDirs) {
    if (Test-Path (Join-Path $dir "uninstall.exe")) {
        Write-Host "Notepad++ kurulu bulundu: $dir"
        $IsInstalled = $true
        break
    }
}

if (-not $IsInstalled) {
    Write-Host "Notepad++ kurulu degil. Islem yapilmiyor."
    exit 0
}

# ---------------------------------------------------------
# Versiyon kontrolu (KESIN YONTEM)
# ---------------------------------------------------------
$InstalledVersion = $null

if (Test-Path $UninstallKey) {
    $InstalledVersion = (Get-ItemProperty $UninstallKey).DisplayVersion
}

if ($InstalledVersion) {
    Write-Host "Kurulu Notepad++ versiyonu: $InstalledVersion"

    if ($InstalledVersion -eq $TargetVersion) {
        Write-Host "Notepad++ zaten $TargetVersion surumunde. Kurulumdan vazgeciliyor."
        exit 0
    }
} else {
    Write-Host "Versiyon bilgisi okunamadi. Upgrade devam edecek."
}

# ---------------------------------------------------------
# Installer'i bul (script / EXE yaninda)
# ---------------------------------------------------------
$ExePath    = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
$WorkingDir = Split-Path $ExePath -Parent

$Installer = Get-ChildItem $WorkingDir -Filter "npp*.Installer*.exe" |
             Select-Object -First 1

if (-not $Installer) {
    Write-Host "HATA: Installer bulunamadi!"
    exit 1
}

Write-Host "Upgrade icin installer bulundu: $($Installer.Name)"

# ---------------------------------------------------------
# Installer'i local TEMP'e kopyala (UNC security warning fix)
# ---------------------------------------------------------
$TempInstaller = Join-Path $env:TEMP $Installer.Name
Copy-Item $Installer.FullName $TempInstaller -Force

if (Get-Command Unblock-File -ErrorAction SilentlyContinue) {
    Unblock-File $TempInstaller -ErrorAction SilentlyContinue
}

# ---------------------------------------------------------
# UZERINE KUR (UPGRADE)
# ---------------------------------------------------------
Write-Host "Notepad++ uzerine kurulum baslatiliyor..."
Start-Process -FilePath $TempInstaller `
              -ArgumentList "/S /D=C:\Program Files\Notepad++" `
              -Wait

Remove-Item $TempInstaller -Force -ErrorAction SilentlyContinue

Write-Host "=== Notepad++ upgrade islemi tamamlandi ==="
