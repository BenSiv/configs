# configs/seder

The description of Ben's machines for [seder](https://github.com/BenSiv/seder),
which puts an Ubuntu machine in order from it. seder is the engine; this
directory is only data, the way lims is only data for daat. It replaces
`../ansible`.

| Path | What |
|---|---|
| `machines/<name>.lua` | One computer: its variables and the bundles it uses, in apply order |
| `bundles/<topic>.lua` | What should be present or absent, by provider (apt, snap, link, ...) |
| `install.sh` | Bootstrap for a fresh install |

Git settings come from `../git/gitconfig.toml` and the wallpaper from
`../gnome/cosy_cabin.png`, both linked into place by seder.

## Fresh install

```sh
sudo apt update && sudo apt install -y git
git clone https://github.com/BenSiv/configs.git ~/Projects/configs
~/Projects/configs/seder/install.sh            # machine "laptop"
```

It installs `build-essential libreadline-dev`, clones and builds luam
and seder into `~/Projects`, then runs `seder apply machines/laptop.lua`,
which shows the plan and asks before changing anything.

## Afterwards

From this directory:

```sh
seder plan  machines/laptop.lua -v   # what would change, and what already matches
seder apply machines/laptop.lua
```

Removing something that isn't installed is a no-op, so `cleanup.lua` is
safe on a fresh machine. Provider fields are documented in seder's
`doc/providers.md`.

## What a fresh install needs at hand

- **Desktop session:** run `install.sh` from a terminal inside the logged-in GNOME
  desktop, since dconf settings and extensions are applied to that session.
  Installing an extension may show a GNOME confirmation dialog. Extensions
  start after logging out and back in.
- **GitHub credentials** for the private `pass` repo (`bundles/secrets.lua`).
  git asks once, and the linked gitconfig stores them.
- **The phone** with the GPG key, connected over USB, so its Passtore folder is
  mounted. `secrets` is the last bundle, so without the phone everything else
  is already done when apply stops there. Connect it and rerun.

## Not ported from ../ansible

Removing the Ollama service and its system account (`dev_system`). That is
one-off cleanup of an old install, not state to keep, so do it by hand on a
machine that still has it:

```sh
sudo systemctl disable --now ollama
sudo userdel -r ollama
sudo rm -rf /etc/systemd/system/ollama.service /usr/local/bin/ollama /usr/share/ollama /var/lib/ollama
sudo systemctl daemon-reload
```
