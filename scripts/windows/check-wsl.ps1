$ErrorActionPreference = 'Stop'
wsl --version
wsl --list --verbose
if ($LASTEXITCODE -ne 0) { throw 'WSL is inaccessible. Run these commands from your regular Windows terminal.' }
Write-Host 'Use Ubuntu-24.04 in WSL version 2. If missing: wsl --install -d Ubuntu-24.04'
