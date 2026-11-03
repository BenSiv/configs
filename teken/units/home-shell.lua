-- Puts the active generation on PATH: bashrc sources ~/.path_addons,
-- which sources the env.sh teken writes into every generation.
return {
    files = {
        {path = "files/path_addons",
         content = ". \"${home}/.local/state/teken/envs/${env}/current/env.sh\"\n"},
    },
    links = {
        {path = "~/.path_addons", target = "files/path_addons"},
    },
}
