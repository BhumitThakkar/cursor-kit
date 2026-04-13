# subagentStart — log which subagent was spawned, then allow.
$input_data = [Console]::In.ReadToEnd()
$logDir = Join-Path $PSScriptRoot '..' '..' 'tasks'
$logFile = Join-Path $logDir 'subagent-trace.log'
$timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

try {
    $parsed = $input_data | ConvertFrom-Json -ErrorAction SilentlyContinue
    $agentType = if ($parsed.subagentType) { $parsed.subagentType } else { 'unknown' }
    $line = "$timestamp | subagent_start | $agentType"
    if (!(Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
    Add-Content -Path $logFile -Value $line -ErrorAction SilentlyContinue
} catch {
    # Logging failure must not block the agent
}

Write-Output '{"decision":"allow"}'
