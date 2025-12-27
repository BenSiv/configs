#!/bin/sh
set -e

# ANSI Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}==============================================${NC}"
echo -e "${BLUE}   Guix System Automated Installer Wrapper    ${NC}"
echo -e "${BLUE}==============================================${NC}"

# 1. Authorize Substitutes
echo -e "\n${GREEN}[1/3] Authorizing Substitutes...${NC}"
wget -qO- https://substitutes.nonguix.org/signing-key.pub | guix archive --authorize
echo "Done."

# 2. Check Mounts
echo -e "\n${GREEN}[2/3] Checking Partitions...${NC}"
if ! mount | grep -q "/mnt "; then
    echo -e "${RED}Error: Root partition is not mounted at /mnt${NC}"
    echo "Please mount your root partition to /mnt and EFI to /mnt/boot/efi"
    echo "Example:"
    echo "  sudo mount /dev/nvme0n1p2 /mnt"
    echo "  sudo mkdir -p /mnt/boot/efi"
    echo "  sudo mount /dev/nvme0n1p1 /mnt/boot/efi"
    exit 1
fi
echo "Partitions detected."

# 3. Install System
echo -e "\n${GREEN}[3/3] Installing System...${NC}"
echo "Using config: /etc/guix-install/system.scm"
echo "This may take a while..."

# Embed home.scm for the user
# Config path in the installed package
CONFIG_DIR="/run/current-system/profile/share/guix-install"

# Embed home.scm for the user
mkdir -p /mnt/home/bensiv/Documents/configs/guix
cp "$CONFIG_DIR/home.scm" /mnt/home/bensiv/Documents/configs/guix/home.scm
cp "$CONFIG_DIR/channels.scm" /mnt/home/bensiv/Documents/configs/guix/channels.scm

# Use time-machine to ensure channels (nonguix) are loaded
echo "Running installation with proper channels..."
guix time-machine -C "$CONFIG_DIR/channels.scm" -- system init "$CONFIG_DIR/system.scm" /mnt

echo -e "\n${GREEN}==============================================${NC}"
echo -e "${GREEN}   Installation Complete!                     ${NC}"
echo -e "${GREEN}==============================================${NC}"
echo "1. Reboot: 'sudo reboot'"
echo "2. Login (bensiv / 1234)"
echo "3. Run: 'guix home reconfigure ~/Documents/configs/guix/home.scm'"
