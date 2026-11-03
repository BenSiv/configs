-- luam and the tools written in it, built from pinned commits and put on
-- PATH from the generation (seder's builds bundle, without the checkouts:
-- those are state). Serves the home env and the container alike.

-- A luam project built by its bld/build.sh into bin/<bin>.
function luam_tool(name, source, bin)
    return {name = name, from = source, needs = {"luam"},
            env = {LUAM_DIR = "${build.luam}"},
            cmd = "bash bld/build.sh",
            install = {["bin/" .. bin] = "bin/" .. bin}}
end

return {
    sources = {
        luam = {git = "https://github.com/BenSiv/luam.git"},
        seder = {git = "https://github.com/BenSiv/seder.git"},
        teken = {git = "https://github.com/BenSiv/teken.git"},
        brain_ex = {git = "https://github.com/BenSiv/brain-ex.git"},
        daat = {git = "https://github.com/BenSiv/daat.git"},
        camopass = {git = "https://github.com/BenSiv/camopass.git"},
    },
    build = {
        {name = "luam", from = "luam",
         -- build_libs too: luam's static build orchestrator, which every
         -- tool below runs, needs its lfs module. It needs libsqlite3-dev
         -- and libmariadb-dev (seder's builds bundle installs them).
         cmd = "bash bld/build_lang.sh && bash bld/build_libs.sh",
         -- lib/: luam's Lua libraries and the modules build_libs compiled,
         -- found through LUAM_LIB (bashrc).
         install = {["bin/luam"] = "bin/luam", ["bin/luamc"] = "bin/luamc", ["lib"] = "lib/luam"}},
        luam_tool("seder", "seder", "seder"),
        luam_tool("teken", "teken", "tkn"),
        luam_tool("brex", "brain_ex", "brex"),
        luam_tool("daat", "daat", "daat"),
        luam_tool("camopass", "camopass", "camopass"),
    },
    verify = {
        "test -x \"$TEKEN_GEN/bin/luam\"",
        "seder --version", "tkn --version",
        "test -x \"$TEKEN_GEN/bin/brex\"", "test -x \"$TEKEN_GEN/bin/daat\"",
        "test -x \"$TEKEN_GEN/bin/camopass\"",
    },
}
