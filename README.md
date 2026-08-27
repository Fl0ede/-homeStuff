# CleanupTemp.ps1

Sicheres PowerShell-Skript zur automatischen Bereinigung von temporären Dateien, Downloads und Screenshots unter Windows.

## Was macht das Skript?

Das Skript löscht **nur Dateien, die älter als X Tage** sind (Standard: 7 Tage). Es räumt danach leere Ordner auf und schreibt ein detailliertes Log.

Bereiche, die bereinigt werden:

| Ordner              | Standard | Konfigurierbar |
|---------------------|----------|----------------|
| `%LOCALAPPDATA%\Temp` | Immer   | Nein           |
| Downloads           | Ja       | Ja (`$CleanDownloads`) |
| Screenshots         | Ja       | Ja (`$CleanScreenshots`) |

## Features

- Löscht nur Dateien älter als konfigurierbare Anzahl an Tagen
- Überspringt gesperrte Dateien (kein Absturz)
- Entfernt leere Unterordner
- Zeigt vor/nach freigegebenen Speicherplatz an
- Schreibt ein Log auf den Desktop (`CleanupLog.txt`)
- Einfach per Parameter konfigurierbar

## Voraussetzungen

- Windows 10 / 11
- PowerShell 5.1 oder neuer (ist standardmäßig vorhanden)

## Installation & Verwendung

1. Lade `CleanupTemp.ps1` herunter
2. Rechtsklick → **Mit PowerShell ausführen**  
   *oder* im PowerShell-Terminal:

```powershell
.\CleanupTemp.ps1


Konfiguration

Am Anfang der Datei kannst du folgende Variablen anpassen:
PowerShell$DaysOld          = 7      # Dateien älter als X Tage löschen
$CleanDownloads   = $true  # Downloads bereinigen?
$CleanScreenshots = $true  # Screenshots bereinigen?


Ausgabe-Beispiel
textStarte Bereinigung...

Bereinige Temp : C:\Users\...\AppData\Local\Temp
Nur Dateien aelter als 7 Tage
  Vorher          : 1842.37 MB
  Geloeschte Dateien: 312
  Fehlgeschlagen  : 4 (gesperrt)
  Geloeschte Ordner: 18
  Freigegeben     : 1267.45 MB

Fertig. Log-Datei: C:\Users\...\Desktop\CleanupLog.txt
