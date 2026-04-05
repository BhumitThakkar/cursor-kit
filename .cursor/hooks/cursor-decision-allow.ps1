# Cursor hook for preToolUse / subagentStart: allow.
$null = [System.Console]::In.ReadToEnd()
Write-Output '{"decision":"allow"}'
