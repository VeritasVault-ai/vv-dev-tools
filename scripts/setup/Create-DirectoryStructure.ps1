# Create-DirectoryStructure.ps1 - Sets up the directory structure for vv-dev-tools

Write-Host "Setting up vv-dev-tools directory structure..." -ForegroundColor Blue

# Get the current directory (should be vv-dev-tools)
$VV_DEV_TOOLS_DIR = Get-Location

# Create the main directories
$directories = @(
    "workspaces",
    "scripts\setup",
    "scripts\build",
    "scripts\utils",
    "configs\eslint",
    "configs\prettier",
    "configs\git",
    "templates",
    "docs"
)

foreach ($dir in $directories) {
    $path = Join-Path -Path $VV_DEV_TOOLS_DIR -ChildPath $dir
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path | Out-Null
        Write-Host "Created directory: $path" -ForegroundColor Green
    }
    else {
        Write-Host "Directory already exists: $path" -ForegroundColor Yellow
    }
}

# Move the installation script to the correct location if it exists in the wrong place
$current_install_script = Join-Path -Path $VV_DEV_TOOLS_DIR -ChildPath "scripts\utils\Install-VVCommand.ps1"
$correct_install_script = Join-Path -Path $VV_DEV_TOOLS_DIR -ChildPath "scripts\setup\Install-VVCommand.ps1"

if (Test-Path $current_install_script) {
    if (-not (Test-Path $correct_install_script)) {
        Move-Item -Path $current_install_script -Destination $correct_install_script
        Write-Host "Moved Install-VVCommand.ps1 to the correct location" -ForegroundColor Green
    }
    else {
        Write-Host "Install script already exists in both locations. Please check manually." -ForegroundColor Yellow
    }
}

# Create example workspace files
$workspaces_dir = Join-Path -Path $VV_DEV_TOOLS_DIR -ChildPath "workspaces"
$example_workspaces = @(
    "vv-projects.code-workspace",
    "w-chain-services.code-workspace",
    "w-docs.code-workspace",
    "w-game-suite.code-workspace",
    "w-iac.code-workspace",
    "w-landing.code-workspace"
)

foreach ($workspace in $example_workspaces) {
    $workspace_path = Join-Path -Path $workspaces_dir -ChildPath $workspace
    if (-not (Test-Path $workspace_path)) {
        # Create a basic workspace file
        $workspace_content = @{
            "folders"  = @(
                @{
                    "path" = "..\$($workspace -replace '.code-workspace', '')"
                }
            )
            "settings" = @{}
        } | ConvertTo-Json -Depth 4
        
        Set-Content -Path $workspace_path -Value $workspace_content
        Write-Host "Created example workspace file: $workspace_path" -ForegroundColor Green
    }
}

Write-Host "`nDirectory structure setup complete!" -ForegroundColor Green
Write-Host "You can now run the installation script from the correct location:" -ForegroundColor Yellow
Write-Host ".\scripts\setup\Install-VVCommand.ps1" -ForegroundColor Yellow