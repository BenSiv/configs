-- Builds of the checked-out projects, and their binaries on PATH. A
-- build reruns when its output is missing or older than a git-tracked
-- file in its sources -- after a pull, an edit, or a luam change, since
-- every static binary bundles luam's src and lib.

-- The luam inputs every luam-built binary depends on.
function luam_project(dir)
    return {dir .. "/src", dir .. "/bld", "${projects}/luam/src", "${projects}/luam/lib"}
end

return {
    -- What the builds below compile or link against. luam's static
    -- build (lib/static/build.lua) compiles daat's sqlite3, bcrypt,
    -- hmac and mariadb modules from source, so it needs their headers.
    apt = {
        present = {
            "libsqlite3-dev",   -- sqlite3
            "libcrypt-dev",     -- bcrypt
            "libssl-dev",       -- hmac (openssl/hmac.h, -lcrypto)
            "libmariadb-dev",   -- mariadb; skipped with a warning when missing
            "cmark-gfm",        -- daat renders documents with it at runtime
        },
    },
    run = {
        present = {
            {name = "manifold configure", dir = "${projects}/external/manifold",
             cmd = "cmake -S . -B build -DCMAKE_BUILD_TYPE=Release",
             creates = "${projects}/external/manifold/build/Makefile"},
            {name = "manifold build", dir = "${projects}/external/manifold",
             cmd = "cmake --build build -j\"$(nproc)\"",
             creates = "${projects}/external/manifold/build/bindings/c/libmanifoldc.so"},
            -- install.sh builds the interpreter and seder itself to bootstrap.
            {name = "luam", dir = "${projects}/luam",
             cmd = "bash bld/build_lang.sh",
             creates = "${projects}/luam/bin/luam",
             sources = {"${projects}/luam/src"}},
            {name = "luam libs", dir = "${projects}/luam",
             cmd = "bash bld/build_libs.sh",
             creates = "${projects}/luam/lib/sqlite/lsqlite3.so",
             sources = {"${projects}/luam/src", "${projects}/luam/lib"}},
            {name = "seder", dir = "${projects}/seder",
             cmd = "bash bld/build.sh",
             env = {LUAM_DIR = "${projects}/luam"},
             creates = "${projects}/seder/bin/seder",
             sources = luam_project("${projects}/seder")},
            {name = "brain-ex", dir = "${projects}/brain-ex",
             cmd = "bash bld/build.sh",
             env = {LUAM_DIR = "${projects}/luam"},
             creates = "${projects}/brain-ex/bin/brex",
             sources = luam_project("${projects}/brain-ex")},
            {name = "luametry", dir = "${projects}/luametry",
             cmd = "PATH=\"$LUAM_DIR/bin:$PATH\" bash bld/build.sh",
             env = {LUAM_DIR = "${projects}/luam", MANIFOLD_DIR = "${projects}/external/manifold"},
             creates = "${projects}/luametry/bin/luametry",
             -- entry.lua sits at the repo root rather than in src/.
             sources = {"${projects}/luametry/src", "${projects}/luametry/bld",
                        "${projects}/luametry/entry.lua",
                        "${projects}/luam/src", "${projects}/luam/lib"}},
            {name = "daat", dir = "${projects}/daat",
             cmd = "bash bld/build.sh",
             env = {LUAM_DIR = "${projects}/luam"},
             creates = "${projects}/daat/bin/daat",
             sources = luam_project("${projects}/daat")},
            {name = "camopass", dir = "${projects}/camopass",
             cmd = "bash bld/build.sh",
             env = {LUAM_DIR = "${projects}/luam"},
             creates = "${projects}/camopass/bin/camopass",
             sources = luam_project("${projects}/camopass")},
        },
    },
    link = {
        present = {
            {path = "/usr/local/bin/luam", target = "${projects}/luam/bin/luam"},
            {path = "/usr/local/bin/luamc", target = "${projects}/luam/bin/luamc"},
            {path = "/usr/local/bin/seder", target = "${projects}/seder/bin/seder"},
            {path = "/usr/local/bin/brex", target = "${projects}/brain-ex/bin/brex"},
            {path = "/usr/local/bin/luametry", target = "${projects}/luametry/bin/luametry"},
            {path = "/usr/local/bin/daat", target = "${projects}/daat/bin/daat"},
            {path = "/usr/local/bin/camopass", target = "${projects}/camopass/bin/camopass"},
        },
    },
}
