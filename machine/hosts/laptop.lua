-- Ben's laptop (Ubuntu desktop). Modules apply in this order; within a
-- run, all removals happen first, then additions.
return {
    vars = {
        projects = "~/Projects",
        configs = "${projects}/configs",
        timezone = "America/Los_Angeles",
    },
    modules = {"base", "gnome", "dev", "dotfiles", "builds", "cleanup"},
}
