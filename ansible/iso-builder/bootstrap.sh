#!/bin/bash
# This script runs in the installer environment (not target) during late-commands.
# It handles the complex logic of installing Ansible and running the playbook.

TARGET="/target"

echo "=== STARTING ANSIBLE BOOTSTRAP ==="

# 1. Copy Ansible Configs
echo "Copying ansible directory..."
if [ -d "/mnt/cidata/ansible" ]; then
    cp -r /mnt/cidata/ansible "$TARGET/home/bensiv/ansible"
    # Fix ownership to bensiv (uid 1000)
    curtin in-target --target="$TARGET" -- chown -R 1000:1000 /home/bensiv/ansible
else
    echo "ERROR: /mnt/cidata/ansible not found!"
fi

# 2. Install Ansible (Robust Mode)
echo "Installing Ansible..."
# We use || true to ensure the script doesn't exit if apt fails (offline mode)
curtin in-target --target="$TARGET" -- bash -c "apt-get update && apt-get install -y software-properties-common && add-apt-repository -y universe && apt-get update && apt-get install -y ansible" || echo "WARNING: Ansible install failed. Proceeding without it."

# 3. Run Playbook
echo "Checking for Ansible..."
if curtin in-target --target="$TARGET" -- command -v ansible-playbook >/dev/null; then
    echo "Ansible found. Running playbook..."
    curtin in-target --target="$TARGET" -- ansible-playbook /home/bensiv/ansible/site.yml || echo "WARNING: Playbook finished with errors."
else
    echo "SKIPPING: Ansible not found. You can run ./install.sh manually after reboot."
fi

echo "=== BOOTSTRAP FINISHED ==="
