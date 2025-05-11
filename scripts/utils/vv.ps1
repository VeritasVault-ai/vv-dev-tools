# vv.ps1 - VV Command Utility
param(
    [Parameter(Position = 0)]
    [string]$Command = "",
    
    [Parameter(Position = 1, ValueFromRemainingArguments = $true)]
    [string[]]$Arguments = @()
)

# Get the development directory from config
$VV_CONFIG_DIR = "${env:USERPROFILE}\.vv"
if (-not (Test-Path $VV_CONFIG_DIR)) {
    New-Item -ItemType Directory -Path $VV_CONFIG_DIR -Force | Out-Null
}

$DEV_DIR_FILE = Join-Path -Path $VV_CONFIG_DIR -ChildPath "dev_dir"
if (-not (Test-Path $DEV_DIR_FILE)) {
    $DEV_DIR = "C:\Dev\PhoenixVC"
    Set-Content -Path $DEV_DIR_FILE -Value $DEV_DIR
} else {
    $DEV_DIR = Get-Content $DEV_DIR_FILE
}

if (-not (Test-Path $DEV_DIR)) {
    Write-Host "Development directory not found: $DEV_DIR" -ForegroundColor Red
    exit 1
}

# Define the VV directory path - this is the parent directory for all VV projects
# IMPORTANT: The correct path is C:\Dev\PhoenixVC\vv, NOT C:\Dev\PhoenixVC\vv\vv
$VV_DIR = $DEV_DIR
$VV_DEV_TOOLS_DIR = Join-Path -Path $VV_DIR -ChildPath "vv-dev-tools"
$WORKSPACES_DIR = Join-Path -Path $VV_DEV_TOOLS_DIR -ChildPath "workspaces"

# Print the paths for debugging
Write-Host "Using the following paths:" -ForegroundColor Cyan
Write-Host "DEV_DIR: $DEV_DIR" -ForegroundColor Cyan
Write-Host "VV_DIR: $VV_DIR" -ForegroundColor Cyan
Write-Host "VV_DEV_TOOLS_DIR: $VV_DEV_TOOLS_DIR" -ForegroundColor Cyan
Write-Host "WORKSPACES_DIR: $WORKSPACES_DIR" -ForegroundColor Cyan

if (-not (Test-Path $WORKSPACES_DIR)) {
    New-Item -ItemType Directory -Path $WORKSPACES_DIR -Force | Out-Null
}

function Show-Help {
    Write-Host "VV Command Utility" -ForegroundColor Blue
    Write-Host "Usage: vv <command> [arguments]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Commands:" -ForegroundColor Green
    Write-Host "  workspace, ws   - Open a workspace"
    Write-Host "  list, ls        - List available workspaces"
    Write-Host "  status, st      - Check git status of all repositories"
    Write-Host "  pull            - Pull all repositories"
    Write-Host "  fix             - Fix workspace files"
    Write-Host "  help            - Show this help"
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Yellow
    Write-Host "  vv ws           - List and select a workspace to open"
    Write-Host "  vv ws main      - Open the main workspace"
    Write-Host "  vv status       - Check git status of all repositories"
    Write-Host "  vv fix          - Fix workspace files"
}

function Open-Workspace {
    param (
        [string]$WorkspaceName
    )
    
    if (-not $WorkspaceName) {
        # List workspaces and let user select one
        $workspaces = Get-ChildItem -Path $WORKSPACES_DIR -Filter "*.code-workspace" | Select-Object -ExpandProperty Name
        
        if ($workspaces.Count -eq 0) {
            Write-Host "No workspaces found in $WORKSPACES_DIR" -ForegroundColor Red
            return
        }
        
        Write-Host "Available workspaces:" -ForegroundColor Green
        for ($i = 0; $i -lt $workspaces.Count; $i++) {
            Write-Host "  $($i+1). $($workspaces[$i])" -ForegroundColor Yellow
        }
        
        $selection = Read-Host "Enter workspace number to open"
        if ($selection -match '^\d+$' -and [int]$selection -ge 1 -and [int]$selection -le $workspaces.Count) {
            $WorkspaceName = $workspaces[[int]$selection - 1]
        } else {
            Write-Host "Invalid selection" -ForegroundColor Red
            return
        }
    } else {
        # If name doesn't end with .code-workspace, add it
        if (-not $WorkspaceName.EndsWith(".code-workspace")) {
            $WorkspaceName = "$WorkspaceName.code-workspace"
        }
        
        # If it's a shorthand name, try to find the matching workspace
        if (-not (Test-Path (Join-Path -Path $WORKSPACES_DIR -ChildPath $WorkspaceName))) {
            $possibleMatches = Get-ChildItem -Path $WORKSPACES_DIR -Filter "*$WorkspaceName*" -File
            if ($possibleMatches.Count -eq 1) {
                $WorkspaceName = $possibleMatches[0].Name
            } elseif ($possibleMatches.Count -gt 1) {
                Write-Host "Multiple workspaces match '$WorkspaceName':" -ForegroundColor Yellow
                for ($i = 0; $i -lt $possibleMatches.Count; $i++) {
                    Write-Host "  $($i+1). $($possibleMatches[$i].Name)" -ForegroundColor Yellow
                }
                $selection = Read-Host "Enter workspace number to open"
                if ($selection -match '^\d+$' -and [int]$selection -ge 1 -and [int]$selection -le $possibleMatches.Count) {
                    $WorkspaceName = $possibleMatches[[int]$selection - 1].Name
                } else {
                    Write-Host "Invalid selection" -ForegroundColor Red
                    return
                }
            } else {
                Write-Host "Workspace '$WorkspaceName' not found" -ForegroundColor Red
                return
            }
        }
    }
    
    $workspacePath = Join-Path -Path $WORKSPACES_DIR -ChildPath $WorkspaceName
    if (Test-Path $workspacePath) {
        Write-Host "Opening workspace: $WorkspaceName" -ForegroundColor Green
        Start-Process "code" -ArgumentList "`"$workspacePath`""
    } else {
        Write-Host "Workspace not found: $workspacePath" -ForegroundColor Red
    }
}

function List-Workspaces {
    $workspaces = Get-ChildItem -Path $WORKSPACES_DIR -Filter "*.code-workspace" | Select-Object -ExpandProperty Name
    
    if ($workspaces.Count -eq 0) {
        Write-Host "No workspaces found in $WORKSPACES_DIR" -ForegroundColor Red
        return
    }
    
    Write-Host "Available workspaces:" -ForegroundColor Green
    foreach ($workspace in $workspaces) {
        Write-Host "  - $workspace" -ForegroundColor Yellow
    }
}

function Check-Status {
    # Get all repositories under VV directory
    Write-Host "Looking for repositories in: $VV_DIR" -ForegroundColor Cyan
    
    # List all directories in VV_DIR for debugging
    Write-Host "Directories in ${VV_DIR}:" -ForegroundColor Cyan
    Get-ChildItem -Path $VV_DIR -Directory | ForEach-Object {
        Write-Host "  - $($_.Name)" -ForegroundColor White
    }
    
    # Exclude vv-dev-tools and the nested 'vv' directory
    $vvRepos = Get-ChildItem -Path $VV_DIR -Directory | 
               Where-Object { $_.Name -ne "vv-dev-tools" -and $_.Name -ne "vv" -and $_.Name -ne "_v0" } | 
               Select-Object -ExpandProperty FullName
    
    Write-Host "Found repositories: $($vvRepos.Count)" -ForegroundColor Cyan
    foreach ($repo in $vvRepos) {
        Write-Host "  - $repo" -ForegroundColor Cyan
    }
    
    if ($vvRepos.Count -eq 0) {
        Write-Host "No repositories found in $VV_DIR" -ForegroundColor Yellow
        
        # Let's check if we need to create the directories
        $shouldCreateDirs = Read-Host "Would you like to create the standard VV project directories? (y/n)"
        if ($shouldCreateDirs -eq "y") {
            Create-StandardDirectories
        }
        
        return
    }
    
    foreach ($repo in $vvRepos) {
        $repoName = Split-Path -Path $repo -Leaf
        Write-Host "Checking status of ${repoName}:" -ForegroundColor Blue
        
        if (Test-Path (Join-Path -Path $repo -ChildPath ".git")) {
            Push-Location $repo
            git status -s
            Pop-Location
        } else {
            Write-Host "Not a git repository" -ForegroundColor Yellow
        }
        
        Write-Host ""
    }
}

function Pull-Repositories {
    # Get all repositories under VV directory
    # Exclude vv-dev-tools and the nested 'vv' directory
    $vvRepos = Get-ChildItem -Path $VV_DIR -Directory | 
               Where-Object { $_.Name -ne "vv-dev-tools" -and $_.Name -ne "vv" -and $_.Name -ne "_v0" } | 
               Select-Object -ExpandProperty FullName
    
    if ($vvRepos.Count -eq 0) {
        Write-Host "No repositories found in $VV_DIR" -ForegroundColor Yellow
        return
    }
    
    foreach ($repo in $vvRepos) {
        $repoName = Split-Path -Path $repo -Leaf
        Write-Host "Pulling latest changes for ${repoName}:" -ForegroundColor Blue
        
        if (Test-Path (Join-Path -Path $repo -ChildPath ".git")) {
            Push-Location $repo
            git pull
            Pop-Location
        } else {
            Write-Host "Not a git repository" -ForegroundColor Yellow
        }
        
        Write-Host ""
    }
}

function Create-StandardDirectories {
    $standardDirs = @(
        "vv-chain-services",
        "vv-docs",
        "vv-game-suite",
        "vv-iac",
        "vv-landing"
    )
    
    foreach ($dir in $standardDirs) {
        $dirPath = Join-Path -Path $VV_DIR -ChildPath $dir
        if (-not (Test-Path $dirPath)) {
            New-Item -ItemType Directory -Path $dirPath -Force | Out-Null
            Write-Host "Created directory: $dirPath" -ForegroundColor Green
            
            # Initialize git repository
            Push-Location $dirPath
            git init
            Pop-Location
        }
    }
}

function Fix-WorkspaceFiles {
    # First let's check if we have any repositories
    Write-Host "Looking for repositories in: $VV_DIR" -ForegroundColor Cyan
    
    # List all directories in VV_DIR for debugging
    Write-Host "Directories in ${VV_DIR}:" -ForegroundColor Cyan
    Get-ChildItem -Path $VV_DIR -Directory | ForEach-Object {
        Write-Host "  - $($_.Name)" -ForegroundColor White
    }
    
    # Exclude vv-dev-tools and the nested 'vv' directory
    $vvRepos = Get-ChildItem -Path $VV_DIR -Directory | 
               Where-Object { $_.Name -ne "vv-dev-tools" -and $_.Name -ne "vv" -and $_.Name -ne "_v0" } | 
               Select-Object -ExpandProperty Name
    
    Write-Host "Found repositories:" -ForegroundColor Cyan
    foreach ($repo in $vvRepos) {
        Write-Host "  - $repo" -ForegroundColor Cyan
    }
    
    if ($vvRepos.Count -eq 0) {
        Write-Host "No repositories found in $VV_DIR" -ForegroundColor Yellow
        
        # Let's check if we need to create the directories
        $shouldCreateDirs = Read-Host "Would you like to create the standard VV project directories? (y/n)"
        if ($shouldCreateDirs -eq "y") {
            Create-StandardDirectories
            # Update the list after creating directories
            $vvRepos = Get-ChildItem -Path $VV_DIR -Directory | 
                      Where-Object { $_.Name -ne "vv-dev-tools" -and $_.Name -ne "vv" -and $_.Name -ne "_v0" } | 
                      Select-Object -ExpandProperty Name
        } else {
            return
        }
    }
    
    # Create main workspace file
    $mainWorkspacePath = Join-Path -Path $WORKSPACES_DIR -ChildPath "vv-projects.code-workspace"
    $mainWorkspaceContent = @{
        folders = @()
        settings = @{
            "editor.formatOnSave" = $true
            "editor.defaultFormatter" = "esbenp.prettier-vscode"
            "files.exclude" = @{
                "**/.git" = $false
            }
            "git.openRepositoryInParentFolders" = "always"
        }
    }
    
    foreach ($repoName in $vvRepos) {
        $repoPath = Join-Path -Path $VV_DIR -ChildPath $repoName
        
        if (Test-Path $repoPath) {
            # Add to main workspace
            $mainWorkspaceContent.folders += @{
                path = "../../$repoName"
                name = $repoName.Replace("vv-", "").ToUpper()
            }
            
            # Create individual workspace file
            $projectWorkspacePath = Join-Path -Path $repoPath -ChildPath "${repoName}.code-workspace"
            $projectWorkspaceContent = @{
                folders = @(
                    @{
                        path = "."
                    }
                )
                settings = @{
                    "editor.formatOnSave" = $true
                    "editor.defaultFormatter" = "esbenp.prettier-vscode"
                    "files.exclude" = @{
                        "**/.git" = $false
                    }
                }
            }
            
            $projectWorkspaceJson = ConvertTo-Json $projectWorkspaceContent -Depth 10
            Set-Content -Path $projectWorkspacePath -Value $projectWorkspaceJson
            Write-Host "Created workspace file for ${repoName}" -ForegroundColor Green
        } else {
            Write-Host "Directory not found: $repoPath" -ForegroundColor Yellow
        }
    }
    
    $mainWorkspaceJson = ConvertTo-Json $mainWorkspaceContent -Depth 10
    Set-Content -Path $mainWorkspacePath -Value $mainWorkspaceJson
    Write-Host "Created main workspace file at $mainWorkspacePath" -ForegroundColor Green
}

# Main command processing
switch ($Command) {
    "workspace" { Open-Workspace ($Arguments | Select-Object -First 1) }
    "ws" { Open-Workspace ($Arguments | Select-Object -First 1) }
    "list" { List-Workspaces }
    "ls" { List-Workspaces }
    "status" { Check-Status }
    "st" { Check-Status }
    "pull" { Pull-Repositories }
    "fix" { Fix-WorkspaceFiles }
    "help" { Show-Help }
    "" { Show-Help }
    default { 
        Write-Host "Unknown command: $Command" -ForegroundColor Red
        Show-Help
    }
}