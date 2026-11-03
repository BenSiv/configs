-- Puts the active generation on PATH: bashrc sources ~/.path_addons,
-- which sources the env.sh teken writes into every generation (PATH and
-- the env vars below).
return {
    env = {LUAM_LIB = "${home}/.local/state/teken/envs/${env}/current/lib/luam"},
    files = {
        {path = "files/path_addons",
         content = ". \"${home}/.local/state/teken/envs/${env}/current/env.sh\"\n"},
    },
    links = {
        {path = "~/.path_addons", target = "files/path_addons"},
    },
}
