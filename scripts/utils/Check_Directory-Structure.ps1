# Check directory structure
Write-Host "Checking directory structure..." -ForegroundColor Cyan

# Check C:\Dev\PhoenixVC
$devDir = "C:\Dev\PhoenixVC"
if (Test-Path $devDir) {
    Write-Host "$devDir exists" -ForegroundColor Green
    $devDirContents = Get-ChildItem -Path $devDir -Directory | Select-Object -ExpandProperty Name
    Write-Host "Contents of {$devDir}:" -ForegroundColor Cyan
    foreach ($item in $devDirContents) {
        Write-Host "  - $item" -ForegroundColor White
    }
} else {
    Write-Host "$devDir does not exist" -ForegroundColor Red
}

# Check C:\Dev\PhoenixVC\vv
$vvDir = "C:\Dev\PhoenixVC\vv"
if (Test-Path $vvDir) {
    Write-Host "$vvDir exists" -ForegroundColor Green
    $vvDirContents = Get-ChildItem -Path $vvDir -Directory | Select-Object -ExpandProperty Name
    Write-Host "Contents of {$vvDir}:" -ForegroundColor Cyan
    foreach ($item in $vvDirContents) {
        Write-Host "  - $item" -ForegroundColor White
    }
} else {
    Write-Host "$vvDir does not exist" -ForegroundColor Red
}

# Check C:\Dev\PhoenixVC\vv\vv-dev-tools
$vvDevToolsDir = "C:\Dev\PhoenixVC\vv\vv-dev-tools"
if (Test-Path $vvDevToolsDir) {
    Write-Host "$vvDevToolsDir exists" -ForegroundColor Green
    $vvDevToolsDirContents = Get-ChildItem -Path $vvDevToolsDir -Directory | Select-Object -ExpandProperty Name
    Write-Host "Contents of {$vvDevToolsDir}:" -ForegroundColor Cyan
    foreach ($item in $vvDevToolsDirContents) {
        Write-Host "  - $item" -ForegroundColor White
    }
} else {
    Write-Host "$vvDevToolsDir does not exist" -ForegroundColor Red
}