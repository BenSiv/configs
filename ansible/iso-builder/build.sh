#!/bin/bash
set -e

# Configuration
UBUNTU_ISO="ubuntu-24.04.3-live-server-amd64.iso"
ISO_URL="https://releases.ubuntu.com/24.04/ubuntu-24.04.3-live-server-amd64.iso"
WORK_DIR="iso_work"
OUTPUT_ISO="custom-ubuntu-ansible.iso"

# Dependencies check
command -v xorriso >/dev/null 2>&1 || { echo >&2 "xorriso is required."; exit 1; }
command -v 7z >/dev/null 2>&1 || { echo >&2 "7z (p7zip) is required."; exit 1; }

# Download ISO if not present
if [ ! -f "$UBUNTU_ISO" ]; then
    echo "ISO not found. Downloading..."
    wget -O "$UBUNTU_ISO" "$ISO_URL"
fi

# Clean previous build
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"

# Extract ISO
echo "Extracting ISO..."
7z x "$UBUNTU_ISO" -o"$WORK_DIR" -y > /dev/null

# Prepare ncloud directory
mkdir -p "$WORK_DIR/ncloud"
cp user-data "$WORK_DIR/ncloud/user-data"
touch "$WORK_DIR/ncloud/meta-data" # Empty meta-data is fine

# Inject Ansible configuration
echo "Injecting Ansible..."
cp -r ../ "$WORK_DIR/ansible"
# Exclude the iso-builder itself to avoid recursion/bloat
rm -rf "$WORK_DIR/ansible/iso-builder"

# Patch GRUB to enable Autoinstall
echo "Patching GRUB..."
# This sed is specific to standard Ubuntu 20.04+ layout.
# We append 'autoinstall ds=nocloud;s=/cdrom/ncloud/' to the linux command line.
sed -i 's|---|autoinstall ds=nocloud\\\;s=/cdrom/ncloud/ ---|g' "$WORK_DIR/boot/grub/grub.cfg"

# Repack ISO
echo "Building new ISO..."
cd "$WORK_DIR"
xorriso -as mkisofs -r \
  -V 'ubuntu-cidata' \
  -o "../$OUTPUT_ISO" \
  --grub2-mbr "../$WORK_DIR/boot/grub/i386-pc/boot_hybrid.img" \
  -partition_offset 16 \
  --mbr-force-bootable \
  -append_partition 2 28732ac11ff8d211eba50090273fc04f "../$WORK_DIR/boot/grub/efi.img" \
  -appended_part_as_gpt \
  -iso_mbr_part_type a2a0d0ebe5b9334487c068b6b72699c7 \
  -c '/boot.catalog' \
  -b '/boot/grub/i386-pc/eltorito.img' \
    -no-emul-boot -boot-load-size 4 -boot-info-table --grub2-boot-info \
  -eltorito-alt-boot \
  -e '--interval:appended_partition_2:all::' \
    -no-emul-boot \
  . 

echo "Done! ISO available at $OUTPUT_ISO"
