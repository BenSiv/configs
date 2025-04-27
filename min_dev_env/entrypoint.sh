#!/bin/bash

# Append the commands to ~/.bashrc
cat /root/configs/bashrc.sh >> ~/.bashrc
source ~/.bashrc

bash /root/lua-utils/install_requirements.sh

cp /root/configs/micro /root/.config/
cp /root/configs/gitconfig.toml /root/.gitconfig

# Run the specified command or default to starting a shell
exec "${@:-bash}"
