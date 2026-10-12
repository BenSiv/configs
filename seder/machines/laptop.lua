-- Ben's laptop (Ubuntu desktop). Bundles are listed in apply order;
-- within a run, all removals happen first, then all additions.
return {
    vars = {
        projects = "~/Projects",
        configs = "${projects}/configs",
        timezone = "America/Los_Angeles",
    },
    bundles = {"base", "gnome", "dev", "dotfiles", "builds", "cleanup"},
}
