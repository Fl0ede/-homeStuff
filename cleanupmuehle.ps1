# ==============================
# CleanupTemp.ps1 - Sichere Version
# ==============================

$TempPath   = "$env:LOCALAPPDATA\Temp"
$DownPath   = "$env:USERPROFILE\Downloads"
$PicPath    = "$env:USERPROFILE\Pictures\Screenshots"
$LogFile    = "$env:USERPROFILE\Downloads\CleanupLog.txt"
$DaysOld    = 7 # Nur Dateien aelter als X Tage loeschen
$CleanDownloads = $true # Auf $true setzen, wenn Downloads auch bereinigt werden sollen
$CleanScreenshots = $true # Auf $true setzen, wenn Screenshots auch bereinigt werden sollen

#Anlage als Scheduled Task empfohlen, z.B. woechentlich oder monatlich.

#Derzeit auf Systemstart gesetzt, kann aber nach Bedarf angepasst werden :)

$ScriptPath = "C:\Pfad\zu\CleanupTemp.ps1"   # <-- hier deinen echten Pfad eintragen
$Action  = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`""
$Trigger = New-ScheduledTaskTrigger -AtStartup
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
$Principal = New-ScheduledTaskPrincipal -UserId "$env:USERNAME" -LogonType Interactive -RunLevel Highest
Register-ScheduledTask -TaskName "CleanupTemp at Startup" -Action $Action -Trigger $Trigger -Settings $Settings -Principal $Principal -Description "Bereinigt Temp, Downloads und Screenshots beim Systemstart"


function Cleanup-Folder {
    param(
        [string]$Path,
        [string]$Name,
        [int]$Days = 7
    )

    if (-not (Test-Path $Path)) {
        Write-Host "$Name-Pfad existiert nicht: $Path" -ForegroundColor Red
        return
    }

    Write-Host "`nBereinige $Name : $Path" -ForegroundColor Cyan
    Write-Host "Nur Dateien aelter als $Days Tage" -ForegroundColor DarkGray

    $Cutoff = (Get-Date).AddDays(-$Days)

    # Vorher-Groeße
    $Before = (Get-ChildItem $Path -Recurse -Force -ErrorAction SilentlyContinue |
               Measure-Object Length -Sum -ErrorAction SilentlyContinue).Sum
    $BeforeMB = if ($Before) { [math]::Round($Before / 1MB, 2) } else { 0 }

    # Alte Dateien finden
    $Files = Get-ChildItem $Path -File -Recurse -Force -ErrorAction SilentlyContinue |
             Where-Object { $_.LastWriteTime -lt $Cutoff }

    $DeletedFiles = 0
    $FailedFiles  = 0
    $DeletedSize  = 0

    foreach ($File in $Files) {
        try {
            $DeletedSize += $File.Length
            Remove-Item $File.FullName -Force -ErrorAction Stop
            $DeletedFiles++
        }
        catch {
            $FailedFiles++
        }
    }

    # Leere Ordner aufraeumen (von innen nach auen)
    $Folders = Get-ChildItem $Path -Directory -Recurse -Force -ErrorAction SilentlyContinue |
               Sort-Object { $_.FullName.Length } -Descending

    $DeletedFolders = 0
    foreach ($Folder in $Folders) {
        try {
            # Nur loeschen wenn leer
            if ((Get-ChildItem $Folder.FullName -Force -ErrorAction SilentlyContinue).Count -eq 0) {
                Remove-Item $Folder.FullName -Force -ErrorAction Stop
                $DeletedFolders++
            }
        }
        catch { }
    }

    $FreedMB = [math]::Round($DeletedSize / 1MB, 2)

    Write-Host "  Vorher          : $BeforeMB MB" -ForegroundColor Yellow
    Write-Host "  Geloeschte Dateien: $DeletedFiles"
    Write-Host "  Fehlgeschlagen  : $FailedFiles (gesperrt)"
    Write-Host "  Geloeschte Ordner: $DeletedFolders"
    Write-Host "  Freigegeben     : $FreedMB MB" -ForegroundColor Green

    # Log
    @"
$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Name
Vorher          : $BeforeMB MB
Geloeschte Dateien: $DeletedFiles
Fehlgeschlagen  : $FailedFiles
Geloeschte Ordner: $DeletedFolders
Freigegeben     : $FreedMB MB
----------------------------------------
"@ | Out-File $LogFile -Append
}

# ==============================
# Hauptteil
# ==============================

Write-Host "Starte Bereinigung..." -ForegroundColor White
"$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - ===== Start =====" | Out-File $LogFile -Append

# Temp immer bereinigen
Cleanup-Folder -Path $TempPath -Name "Temp" -Days $DaysOld

#Screenshots bereinigen
Cleanup-Folder -Path $PicPath -Name "Screenshots" -Days $DaysOld

# Downloads nur wenn aktiviert
if ($CleanDownloads) {
    Cleanup-Folder -Path $DownPath -Name "Downloads" -Days $DaysOld
} else {
    Write-Host "Downloads-Bereinigung ist deaktiviert." -ForegroundColor DarkYellow
}

# Screenshots nur wenn aktiviert
if ($CleanScreenshots) {
    Cleanup-Folder -Path $PicPath -Name "Screenshots" -Days $DaysOld
} else {
    Write-Host "Screenshots-Bereinigung ist deaktiviert." -ForegroundColor DarkYellow
}

Write-Host "`nFertig. Log-Datei: $LogFile" -ForegroundColor Cyan