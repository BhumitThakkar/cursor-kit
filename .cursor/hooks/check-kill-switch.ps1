# Cursor hook: exit 1 if deploy kill switch is on (so wrapper returns deny). Does not toggle.
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$killFile = Join-Path $scriptDir '.kill-switch'
if (Test-Path $killFile) { exit 1 }
exit 0
