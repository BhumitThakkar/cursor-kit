# Exit 0; beforeShellExecution / beforeMCPExecution allow passthrough.
# Stdin: hook JSON (ignored). Stdout: empty JSON object.
$null = [Console]::In.ReadToEnd()
Write-Output '{}'
