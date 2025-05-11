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

```
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
# ├── vv-chain-services/
# ├── vv-docs/
# ├── vv-game-suite/
# ├── vv-iac/
# └── vv-landing/
```

2. Open a workspace:

```bash
# Open VS Code with the multi-root workspace
code ./vv-dev-tools/workspaces/vv-projects.code-workspace

# Or open an individual project workspace
code ./vv-dev-tools/workspaces/w-chain-services.code-workspace
```

## Using the Tools

### Workspaces

- **Multi-root workspace**: Opens all projects for cross-project development
- **Individual workspaces**: Focus on a specific project with optimized settings

### Scripts

Run scripts from the command line:

```bash
# Example: Setup script
./vv-dev-tools/scripts/setup/install-dependencies.sh

# Example: Build script
./vv-dev-tools/scripts/build/build-all.sh
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
# Example: Copy a component template
cp -r ./vv-dev-tools/templates/component-templates/basic-component ./your-project/src/components/new-component
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
