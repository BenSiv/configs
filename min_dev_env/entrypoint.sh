#!/bin/bash

# Append the commands to ~/.bashrc
cat /root/configs/bash/bashrc.sh >> /root/.bashrc
cp /root/configs/bash/bash_aliases.sh /root/.bash_aliases
source /root/.bashrc

bash /root/lua-utils/install_requirements.sh

cp -r /root/configs/micro /root/.config/
cp /root/git/configs/gitconfig.toml /root/.gitconfig

# Run the specified command or default to starting a shell
exec "${@:-bash}"
