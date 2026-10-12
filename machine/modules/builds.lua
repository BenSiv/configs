-- Builds of the checked-out projects, and their binaries on PATH. Each
-- build runs only while its output is missing; delete the output (or
-- rebuild by hand) to pick up new commits.
return {
    run = {
        present = {
            {name = "manifold configure", dir = "${projects}/external/manifold",
             cmd = "cmake -S . -B build -DCMAKE_BUILD_TYPE=Release",
             creates = "${projects}/external/manifold/build/Makefile"},
            {name = "manifold build", dir = "${projects}/external/manifold",
             cmd = "cmake --build build -j\"$(nproc)\"",
             creates = "${projects}/external/manifold/build/bindings/c/libmanifoldc.so"},
            -- install.sh builds the interpreter itself to bootstrap.
            {name = "luam", dir = "${projects}/luam",
             cmd = "bash bld/build_lang.sh",
             creates = "${projects}/luam/bin/luam"},
            {name = "luam libs", dir = "${projects}/luam",
             cmd = "bash bld/build_libs.sh",
             creates = "${projects}/luam/lib/sqlite/lsqlite3.so"},
            {name = "brain-ex", dir = "${projects}/brain-ex",
             cmd = "bash bld/build.sh",
             env = {LUAM_DIR = "${projects}/luam"},
             creates = "${projects}/brain-ex/bin/brex"},
            {name = "luametry", dir = "${projects}/luametry",
             cmd = "PATH=\"$LUAM_DIR/bin:$PATH\" bash bld/build.sh",
             env = {LUAM_DIR = "${projects}/luam", MANIFOLD_DIR = "${projects}/external/manifold"},
             creates = "${projects}/luametry/bin/luametry"},
            {name = "daat", dir = "${projects}/daat",
             cmd = "bash bld/build.sh",
             env = {LUAM_DIR = "${projects}/luam"},
             creates = "${projects}/daat/bin/daat"},
            {name = "camopass", dir = "${projects}/camopass",
             cmd = "bash bld/build.sh",
             env = {LUAM_DIR = "${projects}/luam"},
             creates = "${projects}/camopass/bin/camopass"},
        },
    },
    link = {
        present = {
            {path = "/usr/local/bin/luam", target = "${projects}/luam/bin/luam"},
            {path = "/usr/local/bin/luamc", target = "${projects}/luam/bin/luamc"},
            {path = "/usr/local/bin/brex", target = "${projects}/brain-ex/bin/brex"},
            {path = "/usr/local/bin/luametry", target = "${projects}/luametry/bin/luametry"},
            {path = "/usr/local/bin/daat", target = "${projects}/daat/bin/daat"},
            {path = "/usr/local/bin/camopass", target = "${projects}/camopass/bin/camopass"},
        },
    },
}
