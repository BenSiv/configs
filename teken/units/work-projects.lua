-- The Celleste checkouts the work machine keeps in ~/Projects. The dev
-- container's own list is in celleste-bio/software, devenv/bensiv.
return {
    repos = {
        {path = "~/Projects/software", git = "https://github.com/celleste-bio/software.git"},
        {path = "~/Projects/cvs-flask-holder", git = "https://github.com/celleste-bio/cvs-flask-holder.git"},
    },
}
