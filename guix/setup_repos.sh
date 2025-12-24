#!/bin/bash

# Directory to store dependencies (relative to where this script is run, or customizable)
TARGET_DIR="${1:-$HOME}"

echo "Setting up repositories in $TARGET_DIR..."

cd "$TARGET_DIR" || exit 1

# Clone repositories if they don't exist
if [ ! -d "configs" ]; then
    git clone --recurse-submodules https://github.com/BenSiv/configs.git
else
    echo "configs already exists, skipping..."
fi

if [ ! -d "lua-utils" ]; then
    git clone --recurse-submodules https://github.com/BenSiv/lua-utils.git
else
    echo "lua-utils already exists, skipping..."
fi

if [ ! -d "lua-automations" ]; then
    git clone --recurse-submodules https://github.com/BenSiv/lua-automations.git
else
    echo "lua-automations already exists, skipping..."
fi

if [ ! -d "brain-ex" ]; then
    git clone --recurse-submodules https://github.com/BenSiv/brain-ex.git
else
    echo "brain-ex already exists, skipping..."
fi

echo "Repository setup complete."
