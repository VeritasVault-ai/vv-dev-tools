# Install-VvCommand.ps1 - Installation script for the vv command utility

Write-Host "Installing VV Command Utility..." -ForegroundColor Blue

# Get the script directory
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path

# Get the parent directory of the script directory (should be vv-dev-tools)
$VV_DEV_TOOLS_DIR = Split-Path -Parent (Split-Path -Parent $SCRIPT_DIR)

# Get the parent directory of vv-dev-tools (main development directory)
$DEV_DIR = Split-Path -Parent $VV_DEV_TOOLS_DIR

# Configuration directory
$VV_CONFIG_DIR = "$env:USERPROFILE\.vv"
$VV_SCRIPTS_DIR = "$VV_CONFIG_DIR\scripts"
$VV_WORKSPACES_DIR = "$VV_CONFIG_DIR\workspaces"

# Create config directories
if (-not (Test-Path $VV_CONFIG_DIR)) {
    New-Item -ItemType Directory -Path $VV_CONFIG_DIR | Out-Null
}
if (-not (Test-Path $VV_SCRIPTS_DIR)) {
    New-Item -ItemType Directory -Path $VV_SCRIPTS_DIR | Out-Null
}
if (-not (Test-Path $VV_WORKSPACES_DIR)) {
    New-Item -ItemType Directory -Path $VV_WORKSPACES_DIR | Out-Null
}

# Save the development directory
$DEV_DIR | Out-File -FilePath "$VV_CONFIG_DIR\dev_dir"
Write-Host "Development directory set to: $DEV_DIR" -ForegroundColor Green

# Copy the vv script to the PowerShell modules directory
$VV_SCRIPT_PATH = "$VV_DEV_TOOLS_DIR\scripts\utils\vv.ps1"

if (Test-Path $VV_SCRIPT_PATH) {
    # Create a PowerShell profile if it doesn't exist
    if (-not (Test-Path $PROFILE)) {
        New-Item -ItemType File -Path $PROFILE -Force | Out-Null
        Write-Host "Created PowerShell profile at: $PROFILE" -ForegroundColor Green
    }
    
    # Create a vv function in the PowerShell profile
    $function_content = @"
# VV Command Utility function
function vv {
  & '$VV_SCRIPT_PATH' `$args
}
"@

    # Check if the function is already in the profile
    $profile_content = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
    if (-not $profile_content -or -not $profile_content.Contains("# VV Command Utility function")) {
        Add-Content -Path $PROFILE -Value "`n$function_content"
        Write-Host "Added vv function to PowerShell profile" -ForegroundColor Green
    }
    
    # Copy the vv script to the config directory
    Copy-Item -Path $VV_SCRIPT_PATH -Destination "$VV_CONFIG_DIR\vv.ps1" -Force
    Write-Host "VV script copied to: $VV_CONFIG_DIR\vv.ps1" -ForegroundColor Green
    
    # Create symbolic links to workspaces
    Write-Host "Creating workspace references..." -ForegroundColor Blue
    Get-ChildItem -Path "$VV_DEV_TOOLS_DIR\workspaces" -Filter "*.code-workspace" | ForEach-Object {
        $ws_path = $_.FullName
        $ws_name = $_.Name
        Copy-Item -Path $ws_path -Destination "$VV_WORKSPACES_DIR\$ws_name" -Force
        Write-Host "Linked workspace: $ws_name" -ForegroundColor Green
    }
    
    Write-Host "`nInstallation complete!" -ForegroundColor Green
    Write-Host "You'll need to restart PowerShell or run the following command to use the vv command:"
    Write-Host ". `$PROFILE" -ForegroundColor Yellow
    Write-Host "Then you can use the vv command to open workspaces and run scripts."
    Write-Host "Try 'vv help' to see available commands." -ForegroundColor Yellow
}
else {
    Write-Host "Error: VV script not found at $VV_SCRIPT_PATH" -ForegroundColor Red
    Write-Host "Please make sure you're running this script from the correct location."
}