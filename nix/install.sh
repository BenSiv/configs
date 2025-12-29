#!/bin/sh
set -e

# ANSI Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}==============================================${NC}"
echo -e "${BLUE}   NixOS System Automated Installer Wrapper   ${NC}"
echo -e "${BLUE}==============================================${NC}"

# 1. Check Mounts
echo -e "\n${GREEN}[1/3] Checking Partitions...${NC}"
if ! mount | grep -q "/mnt "; then
    echo -e "${RED}Error: Root partition is not mounted at /mnt${NC}"
    echo "Please mount your root partition to /mnt and EFI to /mnt/boot"
    echo "Example:"
    echo "  sudo mount /dev/nvme0n1p2 /mnt"
    echo "  sudo mkdir -p /mnt/boot"
    echo "  sudo mount /dev/nvme0n1p1 /mnt/boot"
    exit 1
fi
echo "Partitions detected."

# 2. Generate Hardware Config
echo -e "\n${GREEN}[2/3] Generating Hardware Configuration...${NC}"
# We generate it to a temp dir so we don't overwrite our managed configs entirely,
# but we actually WANT the hardware-configuration.nix from the live system detection.
nixos-generate-config --root /mnt --dir /tmp/nixos-install-config

# 3. Setup Configs
echo -e "\n${GREEN}[3/3] Setting up Configuration...${NC}"
TARGET_DIR="/mnt/etc/nixos"
mkdir -p "$TARGET_DIR"

# Copy our managed configs
echo "Copying config files..."
cp flake.nix "$TARGET_DIR/"
cp flake.lock "$TARGET_DIR/"
cp configuration.nix "$TARGET_DIR/"
cp home.nix "$TARGET_DIR/"
cp -r iso "$TARGET_DIR/"

# Copy the generated hardware config
echo "Copying generated hardware-configuration.nix..."
if [ -f /tmp/nixos-install-config/hardware-configuration.nix ]; then
    cp /tmp/nixos-install-config/hardware-configuration.nix "$TARGET_DIR/"
else
    echo -e "${RED}Error: hardware-configuration.nix was not generated!${NC}"
    exit 1
fi

# 4. Install System
echo -e "\n${GREEN}Starting NixOS Install...${NC}"
echo "This may take a while..."

# Use the flake to install
# We need to make sure git is available for flakes if the flake uses git inputs, 
# but here we use direct urls or the flake is local.
# We modify the flake to use the generated hardware config if needed, but our flake imports it.

nixos-install --flake "$TARGET_DIR#system" --no-root-passwd

echo -e "\n${GREEN}==============================================${NC}"
echo -e "${GREEN}   Installation Complete!                     ${NC}"
echo -e "${GREEN}==============================================${NC}"
echo "1. Reboot: 'sudo reboot'"
echo "2. Login (bensiv / 1234)"
echo "3. Remember to change your password and add your SSH keys."
