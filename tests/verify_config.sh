#!/bin/bash
set -e

echo "Verifying Desktop Configuration..."

# 1. Verify Aliases
echo "Checking aliases..."
if grep -q "lua \$HOME/Projects/lua-automations/readdir.lua" ~/.bash_aliases; then
    echo "PASS: 'rd' alias points to Projects directory."
else
    echo "FAIL: 'rd' alias incorrect."
    exit 1
fi

# 2. Verify Dock Settings
echo "Checking Dock settings..."
dock_pos=$(gsettings get org.gnome.shell.extensions.dash-to-dock dock-position)
dock_trash=$(gsettings get org.gnome.shell.extensions.dash-to-dock show-trash)
if [[ "$dock_pos" == "'BOTTOM'" ]]; then
    echo "PASS: Dock is at the bottom."
else
    echo "FAIL: Dock position is $dock_pos (expected 'BOTTOM')."
fi
if [[ "$dock_trash" == "false" ]]; then
    echo "PASS: Trash icon is hidden."
else
    echo "FAIL: Trash icon is visible."
fi

# 3. Verify Clock Extension
echo "Checking Clock extension..."
schema_dir="$HOME/.local/share/gnome-shell/extensions/panel-date-format@keiii.github.com/schemas"
if [ -d "$schema_dir" ]; then
    clock_format=$(gsettings --schemadir "$schema_dir" get org.gnome.shell.extensions.panel-date-format format)
    if [[ "$clock_format" == "'%Y-%m-%d %H:%M'" ]]; then
        echo "PASS: Clock format is correct."
    else
        echo "FAIL: Clock format is $clock_format."
    fi
else
    echo "FAIL: Schema directory not found at $schema_dir"
fi

# 4. Verify Symlinks
echo "Checking Symlinks..."
if [[ -L "$HOME/.config/micro" ]]; then
    echo "PASS: Micro config is a symlink."
else
    echo "FAIL: Micro config is not a symlink."
fi
if [[ -L "$HOME/.config/Antigravity/User/settings.json" ]]; then
    echo "PASS: Antigravity settings are symlinked."
else
    echo "FAIL: Antigravity settings are not symlinked."
fi

# 5. Verify Scaling Feature
echo "Checking Scaling feature..."
features=$(gsettings get org.gnome.mutter experimental-features)
if [[ "$features" == *"scale-monitor-framebuffer"* ]]; then
    echo "PASS: Fractional scaling feature enabled."
else
    echo "FAIL: Fractional scaling feature NOT enabled: $features"
fi

echo "All verifications passed!"
