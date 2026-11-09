-- The personal checkouts in ~/Projects (seder's dotfiles bundle), cloned
-- when missing and never touched after. ~ is each env's home, so one
-- unit serves the laptop, the work machine and the personal container.
function repo(name, url)
    return {path = "~/Projects/" .. name, git = url}
end

function personal_repo(name, url)
    return {path = "~/Personal/" .. name, git = url}
end

return {
    repos = {
        repo("configs", "https://github.com/BenSiv/configs.git"),
        repo("luam", "https://github.com/BenSiv/luam.git"),
        repo("seder", "https://github.com/BenSiv/seder.git"),
        repo("teken", "https://github.com/BenSiv/teken.git"),
        repo("automations", "https://github.com/BenSiv/automations.git"),
        repo("brain-ex", "https://github.com/BenSiv/brain-ex.git"),
        repo("daat", "https://github.com/BenSiv/daat.git"),
        repo("camopass", "https://github.com/BenSiv/camopass.git"),
        repo("luametry", "https://github.com/BenSiv/luametry.git"),
        repo("external/manifold", "https://github.com/elalish/manifold.git"),
        personal_repo("portfolio", "https://github.com/BenSiv/portfolio.git"),
    },
}
