# Audit-only / placeholder hook. Reads stdin, exits 0, outputs {}.
$null = [Console]::In.ReadToEnd()
Write-Output '{}'
