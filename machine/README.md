# machine

Declarative setup for this repo's Ubuntu machines, written in
[luam](https://github.com/BenSiv/luam). It is meant to replace `../ansible`.

You write down what should be on the machine. `machine` checks what is
actually there and changes only the difference. Removing something that
isn't installed does nothing, on every machine, without per-task guards.

## Layout: data, config, code

Same split as daat and its lims deployment:

| Layer | Where | What |
|---|---|---|
| Data | `modules/*.lua` | What should be present or absent, grouped by topic |
| Config | `hosts/*.lua` | One machine: its variables and which modules it uses |
| Code | `src/` | The engine and one provider per kind of resource |

Module and host files are data, not scripts. They run in luam's data-only
sandbox (no `os`, `io` or `require`), the one daat uses for
`platform.lua`, and must return a table. Every field is checked against
its provider before anything runs, so a typo fails the plan instead of
breaking an install halfway.

## Usage

On a fresh Ubuntu install:

```sh
git clone https://github.com/BenSiv/configs.git ~/Projects/configs
~/Projects/configs/machine/install.sh            # host "laptop"
```

`install.sh` installs `git build-essential libreadline-dev`, clones and
builds luam, builds `bin/machine`, then runs `machine apply`. Every step
checks first, so rerunning it is safe.

Afterwards, from this directory:

```sh
bin/machine plan  hosts/laptop.lua      # what would change
bin/machine plan  hosts/laptop.lua -v   # ...including what already matches
bin/machine check hosts/laptop.lua      # exit 2 when anything would change
bin/machine apply hosts/laptop.lua      # show the plan, confirm, apply (-y skips the prompt)
```

The host file defaults to `hosts/$(hostname).lua`.

The plan marks each item:

- `+` add
- `-` remove
- `=` already as wanted (shown with `-v`)
- `!` conflict, such as a file where a directory should be

`apply` refuses to run while any conflict remains.

### How apply runs

- **Probing:** each provider checks the machine once per run, e.g. one
  `dpkg-query` for all apt items.
- **Order:** all removals run first, in reverse provider order, then all
  additions in provider order: apt, snap, npm, path, repo, link, run. So
  npm packages are uninstalled before npm itself, and builds run after
  their packages and checkouts.
- **Failure:** apply stops at the first failed command. Rerunning probes
  again and continues from where it stopped.
- **Privileges:** `machine` runs as you. System changes use `sudo`; files
  under `$HOME` don't.

## Writing modules

```lua
-- modules/example.lua
return {
    apt  = {present = {"jq", {name = "quarto", url = "https://.../quarto.deb"}},
            absent  = {"thunderbird"}},
    snap = {present = {{name = "android-studio", classic = true}},
            absent  = {"firefox"}},
    link = {present = {{path = "~/.bashrc", target = "${configs}/bash/bashrc.sh"}}},
    run  = {present = {{name = "luam", dir = "${projects}/luam",
                        cmd = "bash bld/build_lang.sh",
                        creates = "${projects}/luam/bin/luam"}}},
}
```

- **Items:** an item is a string (its key field) or a table of fields.
- **Variables:** `${name}` is replaced from the host's `vars`, plus the
  built-in `home` and `user`. A leading `~/` becomes `$HOME/`. An unknown
  variable is an error.
- **Conflicts:** the same resource wanted `present` in one module and
  `absent` in another is an error that names both files.

### Providers

| Provider | Key | Fields | present | absent |
|---|---|---|---|---|
| `apt` | `name` | `url` (install a .deb from this URL) | install | purge |
| `snap` | `name` | `classic`, `channel` | install | remove |
| `npm` | `name` | | `npm install -g` | `npm uninstall -g` |
| `path` | `path` | | `mkdir -p` | `rm -rf` (absolute paths, at least 2 levels deep, never `$HOME`) |
| `link` | `path` | `target` | symlink; an existing real file moves to `<path>.orig` | remove the symlink; real files are left alone |
| `repo` | `path` | `url` | `git clone --recurse-submodules`; never pulls | not supported |
| `run` | `name` | `cmd`, `dir`, `env`, `sudo`, and `creates` or `unless` | run `cmd` | not supported |

**Missing tools:** when a provider's tool isn't installed (no `snap`, no
`npm`), its `absent` items are already satisfied. Its `present` items
are attempted at apply time, because an earlier step may install the
tool.

**`run` items** must say how to tell they're done:

- `creates`: a path that exists afterwards. Apply fails if the command
  ran but didn't create it.
- `unless`: a check command that exits 0 when the work is already done.

An unguarded command would run on every apply, so the loader rejects
it. Prefer a dedicated provider over `run` when one exists.

## Adding a provider

Create `src/providers/<name>.lua` returning a table with:

- `key`: the field that identifies an item.
- `fields`: field name → type (`"string"`, `"boolean"`, `"table"`).
- `required`: state → list of required fields.
- `states`: which of `"present"` / `"absent"` the provider supports.
- `available()` → `true`, or `false` and a reason. The reason shows in
  the plan.
- `state(entries)`: one probe, whose result is passed to `status`.
- `status(item, current, wanted)` → `"present"`, `"absent"` or
  `"conflict"`, plus an optional note.
- `add(items)` and/or `remove(items)` → `true` on success. Run commands
  through `shell.run` so they are echoed and testable.
- Optional `validate(item, state)` → an error string or `nil`, checked
  at load time.

Then register it in `engine.providers` and place it in `PROVIDER_ORDER`
(`src/engine.lua`).

## Development

```sh
bld/build.sh     # -> bin/machine (LUAM_DIR defaults to ../../luam)
bld/test.sh      # build + bats tst
```

The tests run `bin/machine` against a scratch `$HOME`. `PATH` holds only
stub package tools that log what they were asked to do, so the tests
cover apply without changing the machine. A tool counts as installed
only when a test creates its stub.

## Not ported yet

These are still only in `../ansible`:

- GNOME extensions, dconf settings, wallpaper (`gnome_user`)
- git global config (`dotfiles`)
- GPG key import and the private password-store checkout (`dev_user`)
- stopping the Ollama service and removing its account and data (`dev_system`)

Each needs a small provider (`dconf`, `git_config`, `service`, `user`)
rather than a `run` item.
