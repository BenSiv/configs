#!/bin/bash

# List of plugins (space-separated or read from a file)
plugins=(
    "quoter"
)

# Loop over each plugin and install
for plugin in "${plugins[@]}"; do
    echo "Installing plugin: $plugin"
    micro -plugin install "$plugin"
done

echo "All plugins installed."
