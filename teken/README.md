# configs/teken

Ben's personal environments for [teken](https://github.com/BenSiv/teken)
(`tkn`), which builds each one as a whole new generation, verifies it,
and swaps it in atomically, keeping the previous one for rollback. teken
is the engine; this directory is only data, like `../seder` is for seder.
seder puts a machine in order (apt, GNOME, services); teken owns what can
be rebuilt and swapped whole: the tools on PATH, the dotfiles, a dev
container.

| Path | What |
|---|---|
| `envs/work.lua` | The work machine's home (WSL on Windows 11) |
| `envs/personal.lua` | The personal laptop's home (Debian 13, set up by seder) |
| `envs/devenv.lua` | The personal dev container: the laptop's tools in a container |
| `units/<topic>.lua` | What goes into an env (see below) |
| `lock.lua` | Pinned commits, image digest and download hashes; written by `tkn lock` / `tkn update` |

The work dev container is not here: it is in celleste-bio/software,
`devenv/bensiv`, and takes its dotfiles from this repo at a pinned commit.

| Unit | In | What |
|---|---|---|
| `luam-stack` | all | luam, seder, tkn, brex, daat and camopass, built from pinned commits onto PATH |
| `dotfiles` | all | `../bash`, `../git` and `../micro`, copied into the generation and linked from home |
| `projects` | all | The personal checkouts in `~/Projects`, cloned when missing, never touched after |
| `work-projects` | work | The Celleste checkouts the work machine keeps in `~/Projects` |
| `home-shell` | work, personal | `~/.path_addons`, which puts the generation's `bin/` on PATH |
| `build-deps`, `base-tools` | devenv | apt packages of the container |

Dotfiles take effect on the next `tkn switch`. They find the checkouts
through `$PROJECTS` (default `~/Projects`), which the work container sets
to `/root/projects`.

## Use

From this directory:

```sh
tkn plan   envs/work.lua     # what would be built and changed
tkn build  envs/work.lua     # build and verify only
tkn switch envs/work.lua     # the full switch, rolled back on any failure
tkn rollback envs/work.lua
tkn update                   # move pins forward, then plan/switch
```

## work (WSL on Windows 11)

No seder here, so the build prerequisites are installed by hand once:

```sh
sudo apt install build-essential libreadline-dev libsqlite3-dev libmariadb-dev libssl-dev libcrypt-dev
tkn switch envs/work.lua
```

The first switch moves the existing `~/.bashrc`, `~/.bash_aliases`,
`~/.gitconfig` and micro config files to
`~/.local/state/teken/envs/work/adopted/` (rollback puts them back), and
links them to the generation.

## personal (Debian 13)

seder (`../seder/machines/laptop.lua`) installs the prerequisites, but
its `dotfiles` bundle also links `~/.bashrc`, `~/.bash_aliases`,
`~/.gitconfig` and the whole `~/.config/micro` straight into this repo.
Hand those to teken before the first switch, or teken would adopt files
from inside the configs checkout through the `~/.config/micro` link:

1. Remove those four links from `../seder/bundles/dotfiles.lua`.
2. `rm ~/.bashrc ~/.bash_aliases ~/.gitconfig ~/.config/micro` (they are
   symlinks; check with `ls -l` first), then `mkdir ~/.config/micro`.
3. `tkn switch envs/personal.lua`

seder's `/usr/local/bin` links and `repo` entries can stay: the
generation's `bin/` comes first on PATH, and a checkout that exists is
left alone by both.

## devenv (personal container)

Every checkout is on the `devenv-personal` volume at `/root/Projects`,
so a rebuild never loses work; missing ones are cloned when the
container starts.

```sh
tkn switch envs/devenv.lua
podman exec -it devenv-personal bash
```
