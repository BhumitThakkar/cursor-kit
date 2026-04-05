#Requires -Version 5.1
<#
.SYNOPSIS
  Emergency kill switch: create .kill-switch file to block automated deploys.
.DESCRIPTION
  Creating the file blocks deploy-rate-limit.ps1 and any hook that checks for it.
  Run with -Remove to re-enable deploys.
.EXAMPLE
  .\emergency-kill.ps1        # block deploys
  .\emergency-kill.ps1 -Remove  # allow deploys
#>
param([switch]$Remove)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$killFile = Join-Path $scriptDir '.kill-switch'
if ($Remove) {
  if (Test-Path $killFile) { Remove-Item $killFile -Force; Write-Output "Kill switch removed. Deploys allowed." }
  else { Write-Output "Kill switch was not set." }
} else {
  $null = New-Item -Path $killFile -ItemType File -Force
  Write-Output "Kill switch ON. Automated deploys are blocked. Run with -Remove to allow."
}
