#!/bin/bash
# Install script for the vv command utility

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Installing VV Command Utility...${NC}"

# Get the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Get the parent directory of the script directory (should be vv-dev-tools)
VV_DEV_TOOLS_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"

# Get the parent directory of vv-dev-tools (main development directory)
DEV_DIR="$(dirname "$VV_DEV_TOOLS_DIR")"

# Configuration directory
VV_CONFIG_DIR="${HOME}/.vv"
VV_SCRIPTS_DIR="${VV_CONFIG_DIR}/scripts"
VV_WORKSPACES_DIR="${VV_CONFIG_DIR}/workspaces"

# Create config directories
mkdir -p "${VV_CONFIG_DIR}"
mkdir -p "${VV_SCRIPTS_DIR}"
mkdir -p "${VV_WORKSPACES_DIR}"

# Save the development directory
echo "$DEV_DIR" > "${VV_CONFIG_DIR}/dev_dir"
echo -e "${GREEN}Development directory set to: ${DEV_DIR}${NC}"

# Copy the vv script to the bin directory
VV_SCRIPT_PATH="${VV_DEV_TOOLS_DIR}/scripts/utils/vv"

if [ -f "$VV_SCRIPT_PATH" ]; then
  # Determine the appropriate bin directory
  if [ -d "${HOME}/bin" ] && [[ ":$PATH:" == *":${HOME}/bin:"* ]]; then
    BIN_DIR="${HOME}/bin"
  elif [ -d "${HOME}/.local/bin" ] && [[ ":$PATH:" == *":${HOME}/.local/bin:"* ]]; then
    BIN_DIR="${HOME}/.local/bin"
  else
    # Create and use ~/.local/bin if it doesn't exist
    BIN_DIR="${HOME}/.local/bin"
    mkdir -p "$BIN_DIR"
    
    # Add to PATH in shell configuration files if not already present
    for SHELL_RC in "${HOME}/.bashrc" "${HOME}/.zshrc"; do
      if [ -f "$SHELL_RC" ]; then
        if ! grep -q "export PATH=\"\$PATH:${BIN_DIR}\"" "$SHELL_RC"; then
          echo -e "\n# Add ~/.local/bin to PATH for vv command utility" >> "$SHELL_RC"
          echo "export PATH=\"\$PATH:${BIN_DIR}\"" >> "$SHELL_RC"
          echo -e "${YELLOW}Added ${BIN_DIR} to PATH in ${SHELL_RC}${NC}"
          echo -e "${YELLOW}Please restart your terminal or run 'source ${SHELL_RC}' to apply changes${NC}"
        fi
      fi
    done
  fi
  
  # Copy and make executable
  cp "$VV_SCRIPT_PATH" "${BIN_DIR}/vv"
  chmod +x "${BIN_DIR}/vv"
  echo -e "${GREEN}VV command installed to: ${BIN_DIR}/vv${NC}"
  
  # Create symbolic links to workspaces
  echo -e "${BLUE}Creating workspace references...${NC}"
  for WORKSPACE_FILE in "${VV_DEV_TOOLS_DIR}"/workspaces/*.code-workspace; do
    if [ -f "$WORKSPACE_FILE" ]; then
      WS_NAME=$(basename "$WORKSPACE_FILE")
      ln -sf "$WORKSPACE_FILE" "${VV_WORKSPACES_DIR}/${WS_NAME}"
      echo -e "${GREEN}Linked workspace: ${WS_NAME}${NC}"
    fi
  done
  
  echo -e "\n${GREEN}Installation complete!${NC}"
  echo -e "You can now use the ${YELLOW}vv${NC} command to open workspaces and run scripts."
  echo -e "Try ${YELLOW}vv help${NC} to see available commands."
else
  echo -e "${RED}Error: VV script not found at ${VV_SCRIPT_PATH}${NC}"
  echo -e "Please make sure you're running this script from the correct location."
  exit 1
fi