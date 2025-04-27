#!/bin/bash

# Append the commands to ~/.bashrc
if ! grep -qF "$(cat /root/configs/bashrc.sh)" ~/.bashrc; then
    cat /root/configs/bashrc.sh >> ~/.bashrc
    source ~/.bashrc
fi

source /root/lua-utils/install_requirements.sh

cp /root/configs/micro /root/.config/
cp /root/configs/gitconfig.toml /root/.gitconfig

# Run the specified command or default to starting a shell
exec "${@:-bash}"
