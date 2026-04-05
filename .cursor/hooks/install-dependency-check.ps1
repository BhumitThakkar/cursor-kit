#Requires -Version 5.1
<#
.SYNOPSIS
  Downloads and installs OWASP Dependency-Check CLI to .cursor\tools\dependency-check.
.DESCRIPTION
  Requires Java 8+ (dependency-check runs on JVM). Uses GitHub release zip.
  After install, pre-merge-checks.ps1 will find it automatically.
.EXAMPLE
  .\install-dependency-check.ps1
  .\install-dependency-check.ps1 -Version 12.1.9
#>
param(
  [string]$Version = "12.2.0"
)
$ErrorActionPreference = 'Stop'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$cursorDir = Split-Path -Parent $scriptDir
$installDir = Join-Path $cursorDir "tools\dependency-check"
$zipName = "dependency-check-$Version-release.zip"
$zipUrl = "https://github.com/dependency-check/DependencyCheck/releases/download/v$Version/$zipName"

# Java check (JAVA_HOME or PATH)
$javaExe = $null
if ($env:JAVA_HOME -and (Test-Path "$env:JAVA_HOME\bin\java.exe")) { $javaExe = "$env:JAVA_HOME\bin\java.exe" }
else { $javaExe = (Get-Command java -ErrorAction SilentlyContinue).Source }
if (-not $javaExe) {
  Write-Error "Java 8+ is required. Set JAVA_HOME or add java to PATH, then re-run this script."
  exit 1
}
$ea = $ErrorActionPreference; $ErrorActionPreference = 'SilentlyContinue'
try { & $javaExe -version 2>&1 | Out-Null } finally { $ErrorActionPreference = $ea }
Write-Output "Java found: $javaExe"

# Create install dir
if (-not (Test-Path $installDir)) {
  New-Item -Path $installDir -ItemType Directory -Force | Out-Null
}
$zipPath = Join-Path $env:TEMP $zipName

# Download
Write-Output "Downloading $zipUrl ..."
try {
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing
} catch {
  Write-Error "Download failed: $_. Exception: $_"
  exit 1
}

# Extract (overwrite)
Write-Output "Extracting to $installDir ..."
Expand-Archive -Path $zipPath -DestinationPath $installDir -Force
Remove-Item $zipPath -Force -ErrorAction SilentlyContinue

# Detect extracted folder (e.g. dependency-check-12.2.0 or dependency-check)
$extracted = Get-ChildItem $installDir -Directory | Where-Object { $_.Name -like "dependency-check*" } | Select-Object -First 1
if ($extracted) {
  # Move contents up so bin is at installDir\bin
  Get-ChildItem $extracted.FullName | Move-Item -Destination $installDir -Force
  Remove-Item $extracted.FullName -Force -Recurse -ErrorAction SilentlyContinue
}

$batPath = Join-Path $installDir "bin\dependency-check.bat"
if (-not (Test-Path $batPath)) {
  Write-Error "Install failed: $batPath not found after extract."
  exit 1
}

Write-Output "Installed to $installDir"
Write-Output "Run: $batPath --project ""MyApp"" --scan ""."""
Write-Output "pre-merge-checks.ps1 will use this path automatically (no PATH change needed)."
