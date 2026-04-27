#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting Ansible Installation/Run...${NC}"

# Install Ansible if not present
if ! command -v ansible-playbook &> /dev/null; then
    echo "Ansible not found. Installing..."
    sudo apt update
    sudo apt install -y ansible
fi

# Install requirements
if [ -f "requirements.yml" ]; then
    echo "Installing Ansible requirements..."
    ansible-galaxy collection install -r requirements.yml
fi

# Run the playbook
# Note: We run site.yml which imports both system (sudo) and user (non-sudo) tasks.
# --ask-become-pass is needed for the system part.
echo -e "${GREEN}Running Ansible Playbook...${NC}"
ansible-playbook site.yml --ask-become-pass

echo -e "${GREEN}Done!${NC}"
