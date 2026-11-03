#!/bin/sh
# Git editor for the devenv container (GIT_EDITOR). In a VS Code terminal,
# open the message in a VS Code tab and wait for it to close: micro's
# save/quit keys are captured by VS Code there. Anywhere else, micro.
if [ -n "$VSCODE_IPC_HOOK_CLI" ] && command -v code >/dev/null 2>&1; then
    exec code --wait "$@"
fi
exec micro "$@"
