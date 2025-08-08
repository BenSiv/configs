#!/bin/bash

# Append the commands to ~/.bashrc
cat /root/configs/bashrc.sh >> ~/.bashrc
cp /root/configs/bash_aliases.sh >> ~/.bash_aliases
source ~/.bashrc

bash /root/lua-utils/install_requirements.sh

cp -r /root/configs/micro /root/.config/
cp /root/git/configs/gitconfig.toml /root/.gitconfig

# Run the specified command or default to starting a shell
exec "${@:-bash}"
