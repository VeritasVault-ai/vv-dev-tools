# Vercel Environment Variables Puller
# This script installs Vercel CLI (if needed), logs in, and pulls environment variables

param(
    [Parameter(Mandatory = $false)]
    [string]$ProjectPath = ".",
    
    [Parameter(Mandatory = $false)]
    [string]$EnvFileName = ".env",
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipInstall,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipLogin
)

# Set error action preference
$ErrorActionPreference = "Stop"

function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

# Check if Vercel CLI is installed
function Test-VercelInstalled {
    try {
        # Try direct command first
        $vercelVersion = vercel --version
        return $true
    }
    catch {
        try {
            # Try with npx as fallback
            $vercelVersion = npx vercel --version
            return $true
        }
        catch {
            return $false
        }
    }
}

# Main script logic
try {
    Write-ColorOutput Green "=== Vercel Environment Variables Puller ==="
    
    # Step 1: Install Vercel CLI if not already installed
    if (-not $SkipInstall) {
        if (-not (Test-VercelInstalled)) {
            Write-ColorOutput Cyan "Installing Vercel CLI..."
            npm i -g vercel
            
            if (-not (Test-VercelInstalled)) {
                throw "Failed to install Vercel CLI. Please install it manually with 'npm i -g vercel'."
            }
            Write-ColorOutput Green "✓ Vercel CLI installed successfully."
        }
        else {
            Write-ColorOutput Green "✓ Vercel CLI is already installed."
        }
    }
    
    # Step 2: Login to Vercel (if needed)
    Write-ColorOutput Cyan "Logging in to Vercel..."
    try {
        vercel login
    } catch {
        npx vercel login
    }
    Write-ColorOutput Green "✓ Login complete."

    # Step 3: Navigate to project directory
    if ($ProjectPath -ne ".") {
        Write-ColorOutput Cyan "Navigating to project directory: $ProjectPath"
        if (-not (Test-Path -Path $ProjectPath)) {
            throw "Project directory '$ProjectPath' does not exist."
        }
        Push-Location $ProjectPath
    }
    
    # Step 4: Pull environment variables
    Write-ColorOutput Cyan "Pulling environment variables to $EnvFileName..."
    try {
        vercel env pull $EnvFileName
    } catch {
        npx vercel env pull $EnvFileName
    }
    
    if (Test-Path -Path $EnvFileName) {
        $envVarCount = (Get-Content $EnvFileName | Where-Object { $_ -match '^\w+=.+' }).Count
        Write-ColorOutput Green "✓ Successfully pulled $envVarCount environment variables to $EnvFileName"
    }
    else {
        Write-ColorOutput Yellow "! The file $EnvFileName was not created. This might mean there are no environment variables or there was an issue with the pull."
    }
    
    # Return to original directory if we changed it
    if ($ProjectPath -ne ".") {
        Pop-Location
    }
    
    Write-ColorOutput Green "=== Process completed successfully ==="
}
catch {
    Write-ColorOutput Red "Error: $_"
    if ($ProjectPath -ne "." -and (Get-Location).Path -ne (Get-Item $ProjectPath).FullName) {
        Pop-Location
    }
    exit 1
}