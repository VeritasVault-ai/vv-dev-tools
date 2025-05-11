# Setup-WorkspaceLinks.ps1 - Creates links to workspace files in project directories

Write-Host "Setting up workspace links..." -ForegroundColor Blue

# Find the vv-dev-tools directory, even if script is run from a subfolder
$CURRENT_DIR = Get-Location
$VV_DEV_TOOLS_DIR = $CURRENT_DIR

# Navigate up until we find the root vv-dev-tools directory
# (assuming it contains a specific marker file or directory structure)
while (-not (Test-Path (Join-Path -Path $VV_DEV_TOOLS_DIR -ChildPath "workspaces")) -and 
       -not (Test-Path (Join-Path -Path $VV_DEV_TOOLS_DIR -ChildPath "scripts")) -and
       (Split-Path -Parent $VV_DEV_TOOLS_DIR) -ne $null) {
    $VV_DEV_TOOLS_DIR = Split-Path -Parent $VV_DEV_TOOLS_DIR
}

# Verify we found the correct directory
if (-not ((Test-Path (Join-Path -Path $VV_DEV_TOOLS_DIR -ChildPath "scripts")) -or 
          (Test-Path (Join-Path -Path $VV_DEV_TOOLS_DIR -ChildPath "Setup-WorkspaceLinks.ps1")))) {
    Write-Host "Error: Could not locate the vv-dev-tools root directory." -ForegroundColor Red
    Write-Host "Please run this script from within the vv-dev-tools directory or its subfolders." -ForegroundColor Red
    exit 1
}

Write-Host "Found vv-dev-tools directory: $VV_DEV_TOOLS_DIR" -ForegroundColor Green

# Get the parent directory that contains all project directories
$DEV_DIR = Split-Path -Parent $VV_DEV_TOOLS_DIR

# Create the workspaces directory if it doesn't exist
$WORKSPACES_DIR = Join-Path -Path $VV_DEV_TOOLS_DIR -ChildPath "workspaces"
if (-not (Test-Path $WORKSPACES_DIR)) {
    New-Item -ItemType Directory -Path $WORKSPACES_DIR | Out-Null
    Write-Host "Created workspaces directory: $WORKSPACES_DIR" -ForegroundColor Green
}

# Define project directories and their workspace files
$projects = @(
    @{
        "dir"       = "vv-chain-services"
        "workspace" = "vv-chain-services.code-workspace"
    },
    @{
        "dir"       = "vv-docs"
        "workspace" = "vv-docs.code-workspace"
    },
    @{
        "dir"       = "vv-game-suite"
        "workspace" = "vv-game-suite.code-workspace"
    },
    @{
        "dir"       = "vv-iac"
        "workspace" = "vv-iac.code-workspace"
    },
    @{
        "dir"       = "vv-landing"
        "workspace" = "vv-landing.code-workspace"
    }
)

# Add vv-dev-tools as a separate entry
$projects += @{
    "dir"       = Split-Path -Leaf $VV_DEV_TOOLS_DIR  # Get just the directory name
    "workspace" = "vv-dev-tools.code-workspace"
    "is_dev_tools" = $true
}

# Create a main multi-root workspace
$main_workspace_path = Join-Path -Path $WORKSPACES_DIR -ChildPath "vv-projects.code-workspace"
$main_workspace_folders = @()

# Process each project directory
foreach ($project in $projects) {
    # Handle the vv-dev-tools directory specially
    if ($project.ContainsKey("is_dev_tools") -and $project.is_dev_tools) {
        $project_dir = $VV_DEV_TOOLS_DIR
    } else {
        $project_dir = Join-Path -Path $DEV_DIR -ChildPath $project.dir
    }
    
    $project_workspace = Join-Path -Path $project_dir -ChildPath $project.workspace
    $link_path = Join-Path -Path $WORKSPACES_DIR -ChildPath $project.workspace

    # Check if the project directory exists
    if (Test-Path $project_dir) {
        Write-Host "Processing project directory: $project_dir" -ForegroundColor Cyan
        
        # Add to main workspace folders with relative path
        if ($project.ContainsKey("is_dev_tools") -and $project.is_dev_tools) {
            # For dev tools, use its actual path relative to the workspace directory
            $relative_path = (Resolve-Path -Path $project_dir -Relative)
        } else {
            # For other projects, use standard relative path
            $relative_path = "..\$($project.dir)"
        }
        
        $main_workspace_folders += @{ "path" = $relative_path }

        # Check if workspace file already exists in the project directory
        if (Test-Path $project_workspace) {
            Write-Host "Found existing workspace file: $project_workspace" -ForegroundColor Green
            
            # Copy to the workspaces directory
            Copy-Item -Path $project_workspace -Destination $link_path -Force
            Write-Host "Copied to: $link_path" -ForegroundColor Green
        }
        else {
            # Create a new workspace file
            $workspace_content = @'
{
"folders": [
  {
    "path": "."
  }
],
"settings": {
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode"
}
}
'@
            Set-Content -Path $project_workspace -Value $workspace_content -NoNewline
            Write-Host "Created new workspace file: $project_workspace" -ForegroundColor Green

            # Copy to the workspaces directory
            Copy-Item -Path $project_workspace -Destination $link_path -Force
            Write-Host "Copied to: $link_path" -ForegroundColor Green
        }
    }
    else {
        Write-Host "Project directory not found: $project_dir" -ForegroundColor Yellow
    }
}

# Create the main multi-root workspace file
if ($main_workspace_folders.Count -gt 0) {
    # Create the main workspace content with proper escaping for backslashes
    $main_workspace_content = @'
{
"folders": [
'@
    
    for ($i = 0; $i -lt $main_workspace_folders.Count; $i++) {
        $folder = $main_workspace_folders[$i]
        $path = $folder.path.Replace("\", "\\")
        
        $main_workspace_content += @"
  {
    "path": "$path"
  }
"@
        
        if ($i -lt $main_workspace_folders.Count - 1) {
            $main_workspace_content += ","
        }
        
        $main_workspace_content += "`n"
    }
    
    $main_workspace_content += @'
],
"settings": {
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode"
}
}
'@
    
    Set-Content -Path $main_workspace_path -Value $main_workspace_content -NoNewline
    Write-Host "Created main multi-root workspace: $main_workspace_path" -ForegroundColor Green
}
else {
    Write-Host "No project directories found. Main workspace not created." -ForegroundColor Yellow
}

Write-Host "`nWorkspace setup complete!" -ForegroundColor Green
Write-Host "You can now run the installation script:" -ForegroundColor Yellow
Write-Host ".\scripts\setup\Install-VVCommand.ps1" -ForegroundColor Yellow
