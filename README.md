# vv-dev-tools

A centralized repository for development tools, configurations, and utilities that standardize and streamline the development workflow across all VV projects.

## Overview

This repository contains shared development resources including:

- VSCode workspace configurations
- Automation scripts
- Shared configurations (linting, formatting)
- Templates and boilerplates
- Development workflow documentation

## Repository Structure

``` text
vv-dev-tools/
├── workspaces/                   # VSCode workspace files
│   ├── vv-projects.code-workspace # Main multi-root workspace
│   └── individual project workspaces...
├── scripts/                      # Shared utility scripts
│   ├── setup/                    # Environment setup scripts
│   ├── build/                    # Build automation scripts
│   └── utils/                    # Utility scripts
├── configs/                      # Shared configurations
│   ├── eslint/                   # Linting configurations
│   ├── prettier/                 # Code formatting configurations
│   └── git/                      # Git configurations
├── templates/                    # Project templates and boilerplates
└── docs/                         # Documentation for development workflow
```

## Getting Started

### Prerequisites

- Git
- Visual Studio Code
- Node.js (for JavaScript/TypeScript projects)

### Setup

1. Clone this repository alongside your project repositories:

```bash
# Navigate to your main development directory
cd your-main-directory

# Clone this repository
git clone https://github.com/your-org/vv-dev-tools.git

# Ensure your project repositories are cloned at the same level
# Example directory structure:
# your-main-directory/
# ├── vv-dev-tools/
# ├── w-chain-services/
# ├── w-docs/
# ├── w-game-suite/
# ├── w-iac/
# └── w-landing/
```

2. Install the `vv` command utility:

**For Unix-based systems (Linux, macOS):**
```bash
cd your-main-directory
./vv-dev-tools/scripts/setup/install-vv-command.sh
```

**For Windows:**
```powershell
cd your-main-directory
.\vv-dev-tools\scripts\setup\Install-VvCommand.ps1
# Restart PowerShell or run:
. $PROFILE
```

## The `vv` Command Utility

The `vv` command provides a convenient way to work with VV projects.

### Opening Workspaces

```bash
vv                    # Opens the main multi-root workspace
vv chain              # Opens w-chain-services workspace
vv docs               # Opens w-docs workspace
vv game               # Opens w-game-suite workspace
vv iac                # Opens w-iac workspace
vv landing            # Opens w-landing workspace
```

### Configuration Management

```bash
vv config dev-dir             # Show current development directory
vv config dev-dir /path/to/dev # Set development directory
vv config list                # List all available scripts and workspaces
```

### Custom Scripts

You can add your own scripts to the `vv` command:

**For Unix-based systems:**
```bash
# Add a script
vv script add build-all /path/to/build-all.sh

# Run the script
vv build-all
```

**For Windows:**
```powershell
# Add a script
vv script add build-all C:\path\to\build-all.ps1

# Run the script
vv build-all
```

**Common commands:**
```bash
# List all available scripts
vv script list

# Remove a script
vv script remove build-all
```

### Getting Help

```bash
vv help               # Show help and list all available commands
```

## Using the Tools

### Workspaces

- **Multi-root workspace**: Opens all projects for cross-project development
- **Individual workspaces**: Focus on a specific project with optimized settings

### Scripts

Run scripts from the command line:

```bash
# Example: Setup script
./vv-dev-tools/scripts/setup/install-dependencies.sh  # Unix
.\vv-dev-tools\scripts\setup\Install-Dependencies.ps1  # Windows

# Example: Build script
./vv-dev-tools/scripts/build/build-all.sh  # Unix
.\vv-dev-tools\scripts\build\Build-All.ps1  # Windows

# Or use the vv command for registered scripts
vv build-all  # Works on both Unix and Windows
```

### Configurations

Apply shared configurations to your projects by referencing them or copying them to your project.

Example for ESLint:

```js
// In your project's .eslintrc.js
module.exports = {
  extends: [
    '../vv-dev-tools/configs/eslint/.eslintrc.js',
    // Your project-specific overrides...
  ],
};
```

### Templates

Copy templates as starting points for new components or projects:

```bash
# Unix example
cp -r ./vv-dev-tools/templates/component-templates/basic-component ./your-project/src/components/new-component

# Windows example
Copy-Item -Recurse .\vv-dev-tools\templates\component-templates\basic-component .\your-project\src\components\new-component
```

## Contributing

1. Create a branch: `git checkout -b feature/your-feature-name`
2. Make your changes
3. Submit a pull request

Please follow our coding standards and update documentation as necessary.

## Maintenance

This repository is maintained by the VV development team. For questions or suggestions, please contact [team lead contact information].

## License

[Appropriate license information]
