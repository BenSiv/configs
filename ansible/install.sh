#!/bin/bash
set -e

# Change directory to the script's location
cd "$(dirname "$0")"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Parse optional arguments
EXTRA_VARS=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --github-token)
            EXTRA_VARS="-e github_token=$2"
            shift 2
            ;;
        *)
            echo -e "${RED}Unknown argument: $1${NC}"
            echo "Usage: $0 [--github-token TOKEN]"
            exit 1
            ;;
    esac
done

echo -e "${BLUE}Starting Ansible Installation/Run...${NC}"

# Install Ansible if not present
if ! command -v ansible-playbook &> /dev/null; then
    echo -e "${BLUE}Ansible not found. Installing...${NC}"
    sudo apt update
    sudo apt install -y ansible
else
    echo -e "${GREEN}Ansible is already installed.${NC}"
fi

# Install requirements
if [ -f "requirements.yml" ]; then
    echo -e "${BLUE}Installing Ansible requirements...${NC}"
    ansible-galaxy collection install -r requirements.yml
fi

# Run the playbook
# Note: We run site.yml which imports both system (sudo) and user (non-sudo) tasks.
# --ask-become-pass is needed for the system part.
if [ -f "site.yml" ]; then
    echo -e "${GREEN}Running Ansible Playbook...${NC}"
    ansible-playbook site.yml --ask-become-pass $EXTRA_VARS
else
    echo -e "${RED}Error: site.yml not found in $(pwd)${NC}"
    exit 1
fi

echo -e "${GREEN}Done!${NC}"

