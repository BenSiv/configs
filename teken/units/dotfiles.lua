-- Dotfiles from this repo, copied into the generation and linked from
-- home (seder's dotfiles bundle). micro's runtime dirs (buffers,
-- backups) stay writable outside the generation, so only its config is
-- linked, not the whole ~/.config/micro.
return {
    files = {
        {path = "files/bashrc", source = "../bash/bashrc.sh"},
        {path = "files/bash_aliases", source = "../bash/bash_aliases.sh"},
        {path = "files/gitconfig", source = "../git/gitconfig.toml"},
        {path = "files/micro/settings.json", source = "../micro/settings.json"},
        {path = "files/micro/bindings.json", source = "../micro/bindings.json"},
        -- teken copies single files only (it hashes each source).
        {path = "files/micro/colorschemes/bensiv.micro", source = "../micro/colorschemes/bensiv.micro"},
        {path = "files/micro/plug/runline/init.lua", source = "../micro/plug/runline/init.lua"},
        {path = "files/micro/plug/runline/manifest.json", source = "../micro/plug/runline/manifest.json"},
        {path = "files/micro/plug/runline/bindings.json", source = "../micro/plug/runline/bindings.json"},
    },
    links = {
        {path = "~/.bashrc", target = "files/bashrc"},
        {path = "~/.bash_aliases", target = "files/bash_aliases"},
        {path = "~/.gitconfig", target = "files/gitconfig"},
        {path = "~/.config/micro/settings.json", target = "files/micro/settings.json"},
        {path = "~/.config/micro/bindings.json", target = "files/micro/bindings.json"},
        {path = "~/.config/micro/colorschemes/bensiv.micro", target = "files/micro/colorschemes/bensiv.micro"},
        {path = "~/.config/micro/plug/runline/init.lua", target = "files/micro/plug/runline/init.lua"},
        {path = "~/.config/micro/plug/runline/manifest.json", target = "files/micro/plug/runline/manifest.json"},
        {path = "~/.config/micro/plug/runline/bindings.json", target = "files/micro/plug/runline/bindings.json"},
    },
}
