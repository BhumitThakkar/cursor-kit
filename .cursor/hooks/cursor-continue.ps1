# Cursor hook for beforeSubmitPrompt: allow submission.
$null = [System.Console]::In.ReadToEnd()
Write-Output '{"continue":true}'
