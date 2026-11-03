# configs/teken

Ben's environments for [teken](https://github.com/BenSiv/teken) (`tkn`),
which builds each one as a whole new generation, verifies it, and swaps it
in atomically, keeping the previous one for rollback. teken is the engine;
this directory is only data, like `../seder` is for seder. seder puts the
machine in order (apt, GNOME, services); teken owns what can be rebuilt
and swapped whole: the tools on PATH, the dotfiles, the dev container.

| Path | What |
|---|---|
| `envs/work.lua` | The work machine (WSL on Windows 11): luam tools on PATH, dotfiles linked from the active generation; `~/Projects` is state |
| `envs/personal.lua` | The personal laptop (Debian 13, set up by seder): the same units |
| `envs/devenv.lua` | The Celleste dev container, ported from `software/devenv/bensiv` |
| `units/<topic>.lua` | What goes into an env: `luam-stack` and `dotfiles` serve both; the rest are per env |
| `files/` | Files the units copy into a generation |
| `lock.lua` | Pinned commits, image digest and download hashes; written by `tkn lock` / `tkn update` |

Dotfiles come from `../bash`, `../git` and `../micro`, copied into each
generation, so an edit there takes effect on the next `tkn switch`. They
find the checkouts through `$PROJECTS` (default `~/Projects`); the
devenv image sets it to `/root/projects`.

## Use

From this directory:

```sh
tkn plan   envs/devenv.lua     # what would be built and changed
tkn build  envs/devenv.lua     # build and verify only
tkn switch envs/devenv.lua     # the full swap, rolled back on any failure
tkn rollback envs/devenv.lua
tkn update                     # move pins forward, then plan/switch
```

`lock` and `build` clone `celleste-bio/software` (private) on the host
with the host's git credentials; no token goes into the image.

## devenv: repos live on a volume

Every repo is on the `devenv-projects` volume at `/root/projects`
(lowercase, as in the old container), declared as state, so
rebuilding or swapping the image never loses work. `/data` (brex) stays
on `celleste-bensiv-data`, and `~/rnd` is bind-mounted at `/root/rnd`.
After the first switch, or whenever a repo is missing, run inside the
container:

```sh
devenv-clone      # clones only what is missing; never touches a checkout
```

Before the first `tkn switch` replaces the container `deploy.sh` made:
teken refuses a container it didn't create, and the old one keeps its
repos in its own layer (`/root/software`, `/root/projects`, ...), not
on a volume. Commit and
push or copy that work out first, then `podman rm -f celleste-bensiv`.

Not ported yet (they wait for teken's runtime start): the old
entrypoint's per-start steps (`claude/sync.sh`, `brex/setup.sh`, the
Wayland clipboard sync, the `~/rnd/Data-science` links) and the Wayland
socket mount. Dropped on purpose, as in `../seder/bundles/cleanup.lua`:
Gemini CLI and Ollama.

## work (WSL on Windows 11)

No seder here, so the build prerequisites are installed by hand:

```sh
sudo apt install build-essential libreadline-dev libsqlite3-dev libmariadb-dev libssl-dev libcrypt-dev
tkn switch envs/work.lua
```

The switch moves the existing `~/.bashrc`, `~/.bash_aliases`,
`~/.gitconfig` and micro config files to
`~/.local/state/teken/envs/work/adopted/` (rollback puts them back) and
links them to the generation. `~/.path_addons` puts the generation's
`bin/` on PATH.

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

seder's `/usr/local/bin` links from the builds bundle can stay: the
generation's `bin/` comes first on PATH.
