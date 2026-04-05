#Requires -Version 5.1
<#
.SYNOPSIS
  Enforces max deploys per day (default 10). Exit 1 if over limit.
.DESCRIPTION
  Reads/writes deploy count from deploy-count.json. Resets count when day changes.
  Set DEPLOY_RATE_LIMIT_MAX to override default 10.
  Respects AGENT_DEPLOY_KILL_SWITCH=1 or .kill-switch file.
.EXAMPLE
  .\deploy-rate-limit.ps1
#>
$ErrorActionPreference = 'Stop'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$countFile = if ($env:DEPLOY_COUNT_FILE) { $env:DEPLOY_COUNT_FILE } else { Join-Path $scriptDir 'deploy-count.json' }
$maxDeploys = if ($env:DEPLOY_RATE_LIMIT_MAX) { [int]$env:DEPLOY_RATE_LIMIT_MAX } else { 10 }
$today = Get-Date -Format 'yyyy-MM-dd'

# Kill switch
if ($env:AGENT_DEPLOY_KILL_SWITCH -eq '1') {
  Write-Error "Deploy blocked: AGENT_DEPLOY_KILL_SWITCH=1"
}
$killFile = Join-Path $scriptDir '.kill-switch'
if (Test-Path $killFile) {
  Write-Error "Deploy blocked: kill switch file exists at $killFile. Remove it to allow deploys."
}

# Load or init count
$data = @{ date = $today; count = 0 }
if (Test-Path $countFile) {
  $data = Get-Content $countFile -Raw | ConvertFrom-Json
  if ($data.date -ne $today) { $data.date = $today; $data.count = 0 }
}

$data.count = [int]$data.count + 1
if ($data.count -gt $maxDeploys) {
  Write-Warning "Deploy rate limit exceeded: $($data.count) deploys today (max $maxDeploys). Blocking deploy. Alert human."
  $data.count -= 1
  $data | ConvertTo-Json | Set-Content $countFile -NoNewline
  exit 1
}

$data | ConvertTo-Json | Set-Content $countFile -NoNewline
Write-Output "Deploy count: $($data.count)/$maxDeploys today. Proceeding."
exit 0
