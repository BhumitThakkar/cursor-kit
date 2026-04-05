# Minimal Cursor hook: read JSON from stdin, output permission allow.
# Use for beforeShellExecution / beforeMCPExecution etc. when you want to allow by default.
$input | Out-Null
Write-Output '{"permission":"allow"}'
