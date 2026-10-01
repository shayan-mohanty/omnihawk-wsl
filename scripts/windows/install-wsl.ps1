$ErrorActionPreference = 'Stop'
wsl --install -d Ubuntu-24.04
if ($LASTEXITCODE -ne 0) { throw 'WSL installation failed. Run this script in an Administrator PowerShell window.' }
Write-Host 'Restart Windows if requested, then open Ubuntu-24.04 and create your Linux username/password.'
