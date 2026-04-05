# Cursor hook: read stdin, do nothing, exit 0. For audit-only events (sessionEnd, afterFileEdit, etc.).
$null = [System.Console]::In.ReadToEnd()
exit 0
