# Environment initialization for Guix shell
# Usage: guix shell -m guix.scm -- bash --rcfile env_init.sh

# Configurable paths (default to HOME as per setup_repos.sh)
REPO_BASE="${REPO_BASE:-$HOME}"

# Export LUA_PATH
# Export LUA_PATH (prepend to existing or default)
# Note: We use ${LUA_PATH} to preserve Guix profile paths if set.
export LUA_PATH="$REPO_BASE/lua-utils/src/?.lua;${LUA_PATH:-;;}"
export LUA_CPATH="${LUA_CPATH:-;;}"

# Set PS1 to indicate we are in the dev environment
export PS1='\[\033[32m\]guix-bensiv\[\033[0m\] | \[\033[34m\]\w\[\033[0m\] > '

# Aliases from bash/bash_aliases.sh adapted for local paths
alias readdir="ls --format=single-column --almost-all --group-directories-first --color=auto"

# Lua automations aliases
alias rd="lua $REPO_BASE/lua-automations/readdir.lua"
alias edit="lua $REPO_BASE/lua-automations/edit.lua"
alias find="lua $REPO_BASE/lua-automations/find.lua"
alias repo="lua $REPO_BASE/lua-automations/repo.lua"

# Other aliases
alias sqlite="sqlite3"
alias python="python3"
alias brex="$REPO_BASE/brain-ex/brex"
alias ted="gnome-text-editor"

echo "Environment initialized."
echo "Repos assumed at: $REPO_BASE"
