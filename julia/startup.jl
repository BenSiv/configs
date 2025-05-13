using Pkg
using MyJulia
using OhMyREPL
colorscheme!("JuliaDefault")

function activate_local_environment(current_dir)
    current_env = dirname(Base.active_project())
    while true
        if isfile(joinpath(current_dir, "Project.toml"))
            if current_env != current_dir
                Pkg.activate(current_dir)
            else
                println("Local environment already active")
            end
            return
        end

        parent_dir = normpath(dirname(current_dir))
        if parent_dir == current_dir
            break
        end

        current_dir = parent_dir
    end
    println("No Project.toml found in any parent directory.")
end

# using Pkg
# if isfile("Project.toml") && isfile("Manifest.toml")
#     Pkg.activate(".")
# end

# julia version < 1.10
# atreplinit() do repl
#     @eval begin
#         import JuliaSyntax
#         JuliaSyntax.enable_in_core!(true)
#     end
# end
