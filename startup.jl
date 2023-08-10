atreplinit() do repl
    @eval begin
        import JuliaSyntax
        JuliaSyntax.enable_in_core!(true)
    end
end

using OhMyREPL
colorscheme!("JuliaDefault")

# using Pkg
# if isfile("Project.toml") && isfile("Manifest.toml")
#     Pkg.activate(".")
# end

using MyJulia