-- npm CLIs, installed into the step's tree rather than globally. Gemini
-- CLI and Ollama from the old Containerfile are left out, as in seder's
-- cleanup bundle.
return {
    build = {
        {name = "node-tools", from = "configs",
         cmd = "npm install --prefix \"$PWD/npm\" --no-fund --no-audit @dbml/cli@3 @marp-team/marp-cli@4"
            .. " && mkdir -p out && for b in dbml2sql sql2dbml marp; do ln -s \"$PWD/npm/node_modules/.bin/$b\" out/$b; done",
         install = {["out/dbml2sql"] = "bin/dbml2sql", ["out/sql2dbml"] = "bin/sql2dbml", ["out/marp"] = "bin/marp"}},
    },
    verify = {"dbml2sql --version", "marp --version"},
}
