#!/bin/bash

# Define the PS1 and alias configurations as a string
my_bash_configs='
export PS1="${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\h\[\033[01;0m\] | \[\033[01;34m\]\w\[\033[01;0m\] > "
export LUA_PATH="/root/lua-utils/src/?.lua;;"
export PATH="/root/lua-automations/:${PATH}"
alias rd="/root/lua-automations/readdir"
alias brex="/root/brain-ex/brex"
alias sqlite=sqlite3
'
# Append the commands to ~/.bashrc
echo "$my_bash_configs" >> ~/.bashrc
source ~/.bashrc

source /root/lua-utils/install_requirements.sh

# Run the specified command or default to starting a shell
exec "${@:-bash}"
