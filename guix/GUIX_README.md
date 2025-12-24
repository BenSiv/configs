# Guix Development Environment

This directory contains configuration to reproduce the minimal development environment using GNU Guix.

## Prerequisites

- [GNU Guix](https://guix.gnu.org/manual/en/html_node/Installation.html) installed.

### Installing Guix

Since Guix is not available in the default package repositories, you need to use the official installer script:

```bash
cd /tmp
wget https://git.savannah.gnu.org/cgit/guix.git/plain/etc/guix-install.sh
chmod +x guix-install.sh
sudo ./guix-install.sh
```

Follow the prompts (accepting the key, etc.).

> [!IMPORTANT]
> **After installing, you should run `guix pull` to get the latest package definitions.**
> The default installation (1.4.0) is from 2022 and provides older packages.
> `guix pull` may take a long time (hours on slow machines) as it rebuilds dependencies.
> 
> ```bash
> guix pull
> ```
> 
> **Note:** The `guix.scm` provided has `micro` and `luarocks` commented out because they are not available in the base 1.4.0 installation. Uncomment them after running `guix pull`.

## Setup

1.  **Clone Dependencies**
    Run the setup script to clone the required repositories into your home directory (or specified target).
    ```bash
    bash setup_repos.sh
    # OR to a specific directory
    # bash setup_repos.sh $HOME/my-workspace
    ```

2.  **Make Scripts Executable**
    ```bash
    chmod +x setup_repos.sh
    ```

## Usage

To spawn the development environment with all tools (lua, micro, git, etc.) and aliases configured:

```bash
guix shell -m guix.scm -- bash --rcfile env_init.sh
```

If you installed the repositories in a custom location, export `REPO_BASE` before running:

```bash
export REPO_BASE=$HOME/my-workspace
guix shell -m guix.scm -- bash --rcfile env_init.sh
```

## Contents

- `guix.scm`: Manifest of packages (Lua 5.1, Micro, Build tools, etc.).
- `setup_repos.sh`: Helper to clone `lua-utils`, `lua-automations`, `configs`, `brain-ex`.
- `env_init.sh`: Sets up `LUA_PATH`, shell prompt, and aliases (`rd`, `edit`, `brex`, etc.).
