# Creates or removes repo-root .kill-switch. Usage: ./emergency-kill.ps1 [-Remove]
param([switch]$Remove)
$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$flag = Join-Path $repoRoot '.kill-switch'
if ($Remove) {
  Remove-Item -LiteralPath $flag -ErrorAction SilentlyContinue
} else {
  New-Item -ItemType File -Path $flag -Force | Out-Null
}
exit 0
