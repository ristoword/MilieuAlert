# Build signed Play AAB and copy to Desktop\MilieuAlert-Play
$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $Root

$versionLine = (Select-String -Path (Join-Path $Root 'pubspec.yaml') -Pattern '^version:\s*(.+)$').Matches[0].Groups[1].Value.Trim()
$versionName = ($versionLine -split '\+')[0]
$versionCode = ($versionLine -split '\+')[1]

flutter pub get
flutter build appbundle --release

$src = Join-Path $Root 'build\app\outputs\bundle\release\app-release.aab'
if (-not (Test-Path $src)) { throw "AAB not found: $src" }

$destDir = Join-Path ([Environment]::GetFolderPath('Desktop')) 'MilieuAlert-Play'
New-Item -ItemType Directory -Force -Path $destDir | Out-Null
Copy-Item $src (Join-Path $destDir 'app-release.aab') -Force
Copy-Item $src (Join-Path $destDir "app-release-$versionName-$versionCode.aab") -Force

Write-Host "Done: $destDir\app-release.aab ($versionName+$versionCode)"
