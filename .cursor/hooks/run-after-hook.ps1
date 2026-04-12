# Runs a sibling .ps1 after shell execution (e.g. rollback notifier).
$null = [Console]::In.ReadToEnd()
$ErrorActionPreference = 'Continue'
if ($args.Count -lt 1) { exit 0 }
$inner = Join-Path $PSScriptRoot $args[0]
if (Test-Path -LiteralPath $inner) { & $inner }
exit 0
