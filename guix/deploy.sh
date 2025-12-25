#!/bin/bash
set -e

# Build the scheme files
echo "Building Scheme files from Wisp..."
if ! command -v guile &> /dev/null; then
    echo "Guile not found. Running build in 'guix shell guile guile-wisp'..."
    # Check if guix is available
    if ! command -v guix &> /dev/null; then
        echo "Error: neither guile nor guix command found."
        exit 1
    fi
    # Force clean first to avoid stale bad files
    guix shell guile guile-wisp guix -- bash -c "make clean && make"
else
    make clean && make
fi

echo "---------------------------------------------------"
echo "Configuration built successfully."
echo "---------------------------------------------------"
echo "1. [USER ACTION] Configure Channels & Update Guix:"
echo "   cp channels.scm ~/.config/guix/channels.scm
   wget -qO- https://substitutes.nonguix.org/signing-key.pub | sudo guix archive --authorize
"
echo "   guix pull"
echo "   hash guix"
echo ""
echo "2. [OPTIONAL] Build Bootable ISO (for fresh install):"
echo "   This will create a bootable USB image with your configuration an custom kernel."
echo "   guix time-machine -C channels.scm -- system image --image-type=iso9660 system.scm"
echo ""
echo "3. [USER ACTION] Zen Browser Installation:"
echo "   Zen Browser is not available in Guix."
echo "   Run: flatpak install flathub app.zen_browser.zen"
echo ""
echo "2. Apply HOME configuration (Safe, User-level):"
echo "   guix home reconfigure home.scm"
echo ""
echo "3. Apply SYSTEM configuration (Requires Root):"
echo "   > [!IMPORTANT] Update UUIDs in system.wisp first!"
echo "   sudo guix system reconfigure system.scm"
echo "---------------------------------------------------"
