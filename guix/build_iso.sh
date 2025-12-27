#!/bin/bash
set -e

echo "Building Bootable ISO..."
echo "This may take a while as it downloads/builds the system..."

# Use /var/tmp for larger temporary space (avoids /tmp filling up during kernel compile)
export TMPDIR=/var/tmp

echo "---------------------------------------------------"
echo "NOTE: If this process takes a long time (compiling linux/vmlinux),"
echo "      it means proper substitutes are missing or not authorized."
echo "      Ensure you ran: wget -qO- https://substitutes.nonguix.org/signing-key.pub | sudo guix archive --authorize"
echo "---------------------------------------------------"

# Check for dependencies
if ! command -v guile &> /dev/null; then
    echo "Guile not found. Rerunning in 'guix shell guile guile-wisp'..."
    exec guix shell guile guile-wisp guix -- bash "$0" "$@"
fi

# Make sure channels.scm and system.scm exist, and generate iso_config.scm
make channels.scm system.scm iso_config.scm

# Build the image and create a symlink to it
# We use --root to create a persistent GC root (symlink) named 'install-image.iso'
rm -f install-image.iso
guix time-machine -C channels.scm -- system image --image-type=iso9660 --root=install-image.iso iso_config.scm

echo "---------------------------------------------------"
echo "ISO created at: ./install-image.iso"
echo "---------------------------------------------------"
echo "To write to USB drive (replace /dev/sdX):"
echo "sudo dd if=./install-image.iso of=/dev/sdX status=progress && sync"
