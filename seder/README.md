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

## Fresh install

```sh
git clone https://github.com/BenSiv/configs.git ~/Projects/configs
~/Projects/configs/seder/install.sh            # machine "laptop"
```

It installs `git build-essential libreadline-dev`, clones and builds luam
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

## Not ported from ../ansible yet

- GNOME extensions, dconf settings, wallpaper (`gnome_user`)
- git global config (`dotfiles`)
- GPG key import and the private password-store checkout (`dev_user`)
- stopping the Ollama service and removing its account and data (`dev_system`)
