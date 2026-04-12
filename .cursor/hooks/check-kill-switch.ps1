# Exit 1 if repo-root .kill-switch exists (paired with run-before-hook.ps1).
# Exit codes: 0 = ok, 1 = blocked.
$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$flag = Join-Path $repoRoot '.kill-switch'
if (Test-Path -LiteralPath $flag) {
  exit 1
}
exit 0
