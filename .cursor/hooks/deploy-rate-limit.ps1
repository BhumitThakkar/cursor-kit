# Max 10 deploy-class actions per calendar day; respects kill switch.
# Exit 0 allow, 1 deny.
$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if (Test-Path -LiteralPath (Join-Path $repoRoot '.kill-switch')) { exit 1 }

$log = Join-Path $PSScriptRoot '.pantheon-deploy-log.txt'
$today = (Get-Date).ToString('yyyy-MM-dd')
$count = 0
if (Test-Path -LiteralPath $log) {
  foreach ($line in Get-Content -LiteralPath $log) {
    if ($line.StartsWith($today)) { $count++ }
  }
}
if ($count -ge 10) { exit 1 }
Add-Content -LiteralPath $log -Value ("{0}Z deploy-hook" -f $today)
exit 0
