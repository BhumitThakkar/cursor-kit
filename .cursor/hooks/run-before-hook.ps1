# Runs a sibling .ps1 by name; prints Cursor permission JSON. Args: scriptName [extra args...]
$stdin = [Console]::In.ReadToEnd()
$ErrorActionPreference = 'Stop'
if ($args.Count -lt 1) {
  Write-Output '{"permission":"deny","user_message":"Hook misconfigured","agent_message":"run-before-hook: missing script name"}'
  exit 0
}
$innerName = $args[0]
$inner = Join-Path $PSScriptRoot $innerName
if (-not (Test-Path -LiteralPath $inner)) {
  Write-Output ('{"permission":"deny","user_message":"Missing policy script","agent_message":"Not found: {0}"}' -f $innerName)
  exit 0
}
$tail = @()
if ($args.Count -gt 1) { $tail = $args[1..($args.Count - 1)] }
$null = $stdin
& $inner @tail
if ($LASTEXITCODE -ne 0) {
  Write-Output ('{"permission":"deny","user_message":"Policy blocked this command.","agent_message":"Blocked by {0} exit {1}"}' -f $innerName, $LASTEXITCODE)
} else {
  Write-Output '{"permission":"allow"}'
}
exit 0
