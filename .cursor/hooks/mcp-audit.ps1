# beforeMCPExecution — log calls; deny prod writes (bash parity).
$ErrorActionPreference = 'Stop'
$raw = [Console]::In.ReadToEnd()
$tool = ''; $server = ''
if ($raw -match '"tool"\s*:\s*"([^"]*)"') { $tool = $Matches[1] }
if ($raw -match '"server"\s*:\s*"([^"]*)"') { $server = $Matches[1] }
$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$logDir = Join-Path $repoRoot 'tasks'
if (-not (Test-Path -LiteralPath $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
$log = Join-Path $logDir 'mcp-audit.log'
$ts = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
Add-Content -LiteralPath $log -Value "[$ts] MCP CALL | server: $server | tool: $tool"

if ($server -match '(?i)prod|production|live') -and $tool -match '(?i)(create|update|delete|write|insert|drop|modify|push|deploy)') {
  Write-Output "{`"permission`":`"deny`",`"user_message`":`"Blocked: write on production MCP server.`",`"agent_message`":`"BLOCKED by mcp-audit.`"}"
  exit 0
}
Write-Output '{}'
exit 0
