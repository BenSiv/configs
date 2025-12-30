#!/bin/bash
set -e

# Install Ansible if not present
if ! command -v ansible-playbook &> /dev/null; then
    echo "Ansible not found. Installing..."
    sudo apt update
    sudo apt install -y ansible
fi

# Run the playbook
echo "Running Ansible Playbook..."
ansible-playbook site.yml --ask-become-pass
