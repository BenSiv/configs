# Ansible Deployment Walkthrough

Complete Ansible configuration to provision and maintain your Ubuntu development environment.

> Being replaced by [seder](https://github.com/BenSiv/seder), a declarative luam tool that checks
> the machine before changing it. This repo's data for it is in [`seder/`](../../seder/README.md),
> whose README lists what is still only here.

## Prerequisites
1. **Operating System**: Ubuntu 26.04 LTS Desktop (or newer).
2. **Git**: Ensure `git` is installed (`sudo apt install git`).
3. **Repository**:
   ```bash
   git clone https://github.com/BenSiv/configs.git ~/Projects/configs
   cd ~/Projects/configs/ansible
   ```

## Directory Structure
The configuration is located in `configs/ansible`:
- `site.yml`: Main playbook (imports system, user, and build playbooks).
- `inventory`: Localhost connection configuration.
- `install.sh`: One-click runner script with dependency checking.
- `roles/`:
  - `system`: Core system packages, apt update, Quarto, Google Chrome, timezone, locale.
  - `gnome_system`: Minimal desktop tools, bloatware cleanup, GIMP from Ubuntu APT, Antigravity as the IDE, and snap apps where no package is available in the enabled APT repositories (Android Studio, Zen Browser, OnlyOffice, Paint, WhatsApp).
  - `dev_system`: Development tools, Lua 5.1/LuaRocks, and Antigravity IDE snap. It removes Ollama (including downloaded models) and the Gemini, Codex, and Pi CLI tools.
  - `dotfiles`: Git global config, project checkouts, dotfile and IDE setting symlinks (Micro and Antigravity).
  - `gnome_user`: GNOME extensions, dconf settings, Ptyxis terminal scaling, and wallpaper.
  - `dev_user`: GPG keys and password-store setup. It removes Claude Code and local state for Claude, Codex, Gemini, Ollama, and Pi.
  - `project_build`: Builds Manifold, luam, brain-ex, luametry, daat, and camopass; links binaries into `/usr/local/bin`.

## How to Run
```bash
cd ~/Projects/configs/ansible
./install.sh
```

To include private password-store checkout:
```bash
./install.sh --github-token <YOUR_GITHUB_TOKEN>
```

To remove the retired AI tools, Node.js/npm, standalone VS Code, and their local data without
rerunning the rest of the setup:
```bash
ansible-playbook -i inventory site.yml --tags clean_slate --ask-become-pass
```
This deletes Ollama models and local Claude, Codex, Gemini, and Pi state.

Cleanup tasks don't assume anything about the machine. The `system` role first records which apt
packages and snaps are installed and whether `npm` exists, and each removal is skipped when its
target is missing. A fresh install and an old machine run the same playbook.
