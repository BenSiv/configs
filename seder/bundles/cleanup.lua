-- Retired tools and their local data (Ansible's clean_slate tag). Each
-- entry is a no-op when the thing is already gone, so this is safe on a
-- fresh install. Drop the bundle from a machine to keep these.
-- Not ported yet (still in ansible/roles/dev_system): stopping the
-- Ollama service and removing its system account and model data.
return {
    npm = {
        absent = {"@google/gemini-cli", "@openai/codex", "@mariozechner/pi-coding-agent"},
    },
    apt = {
        absent = {"nodejs", "npm"},
    },
    path = {
        absent = {
            "~/.claude", "~/.claude.json", "~/.codex", "~/.gemini",
            "~/.local/bin/claude", "~/.local/share/claude", "~/.ollama", "~/.pi",
        },
    },
    link = {
        -- Settings links from when VS Code was the IDE; real files are kept.
        absent = {"~/.config/Code/User/settings.json", "~/.config/Code/User/keybindings.json"},
    },
}
