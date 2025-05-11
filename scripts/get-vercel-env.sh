#!/bin/bash
# Script to fetch Vercel environment variables from a frontend project
# Usage: vv get-vercel-env [project-name] [environment]

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Vercel CLI is installed
if ! command -v vercel &> /dev/null; then
    echo -e "${RED}Error: Vercel CLI is not installed.${NC}"
    echo -e "${YELLOW}Please install it using: npm i -g vercel${NC}"
    exit 1
fi

# Check if user is logged in to Vercel
vercel whoami &> /dev/null
if [ $? -ne 0 ]; then
    echo -e "${YELLOW}You need to log in to Vercel first.${NC}"
    vercel login
fi

# Get project name from argument or current directory
PROJECT_NAME=$1
if [ -z "$PROJECT_NAME" ]; then
    PROJECT_NAME=$(basename $(pwd))
    echo -e "${YELLOW}No project name provided, using current directory name: ${GREEN}${PROJECT_NAME}${NC}"
fi

# Get environment (default: production)
ENVIRONMENT=$2
if [ -z "$ENVIRONMENT" ]; then
    ENVIRONMENT="production"
    echo -e "${YELLOW}No environment specified, using: ${GREEN}${ENVIRONMENT}${NC}"
fi

echo -e "${BLUE}Fetching environment variables for ${GREEN}${PROJECT_NAME}${BLUE} (${ENVIRONMENT})...${NC}"

# Fetch environment variables using Vercel CLI
echo -e "${YELLOW}Environment variables:${NC}"
vercel env pull --environment ${ENVIRONMENT} .env.vercel --token $(vercel token) --yes

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Environment variables have been saved to .env.vercel${NC}"
    echo -e "${YELLOW}Contents of .env.vercel:${NC}"
    cat .env.vercel
else
    echo -e "${RED}Failed to fetch environment variables.${NC}"
    echo -e "${YELLOW}Make sure the project exists and you have the right permissions.${NC}"
    exit 1
fi