-- Project checkouts and the dotfile/IDE symlinks into this repo.
-- Not ported yet (still in ansible/roles/dotfiles): git global config.
-- The private password store needs a token; still in ansible/roles/dev_user.
return {
    path = {
        present = {
            "${projects}", "${projects}/external",
            "~/.config/Antigravity/User", "~/.config/Antigravity IDE/User",
            "~/.antigravity/extensions", "~/.antigravity-ide/extensions",
        },
    },
    repo = {
        present = {
            {path = "${projects}/configs", url = "https://github.com/BenSiv/configs.git"},
            {path = "${projects}/automations", url = "https://github.com/BenSiv/lua-automations.git"},
            {path = "${projects}/brain-ex", url = "https://github.com/BenSiv/brain-ex.git"},
            {path = "${projects}/luam", url = "https://github.com/BenSiv/luam.git"},
            {path = "${projects}/luametry", url = "https://github.com/BenSiv/luametry.git"},
            {path = "${projects}/daat", url = "https://github.com/BenSiv/daat.git"},
            {path = "${projects}/camopass", url = "https://github.com/BenSiv/camopass.git"},
            {path = "${projects}/external/manifold", url = "https://github.com/elalish/manifold.git"},
        },
    },
    link = {
        present = {
            {path = "~/.bashrc", target = "${configs}/bash/bashrc.sh"},
            {path = "~/.bash_aliases", target = "${configs}/bash/bash_aliases.sh"},
            {path = "~/.config/micro", target = "${configs}/micro"},
            {path = "~/.config/Antigravity/User/settings.json", target = "${configs}/vscode/settings.json"},
            {path = "~/.config/Antigravity/User/keybindings.json", target = "${configs}/vscode/keys.json"},
            {path = "~/.config/Antigravity IDE/User/settings.json", target = "${configs}/vscode/settings.json"},
            {path = "~/.config/Antigravity IDE/User/keybindings.json", target = "${configs}/vscode/keys.json"},
            {path = "~/.antigravity/extensions/luam-lang", target = "${projects}/luam/dev/vscode"},
            {path = "~/.antigravity-ide/extensions/luam-lang", target = "${projects}/luam/dev/vscode"},
        },
    },
}
