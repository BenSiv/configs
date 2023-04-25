using JuliaSyntax
JuliaSyntax.enable_in_core!(true)

using Pkg
if isfile("Project.toml") && isfile("Manifest.toml")
    Pkg.activate(".")
end
