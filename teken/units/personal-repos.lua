-- Personal repositories in ~/Personal (documents, notes, resume, etc.),
-- cloned when missing and never touched after.
function personal_repo(name, url)
    return {path = "~/Personal/" .. name, git = url}
end

return {
    repos = {
        personal_repo("configs", "https://github.com/BenSiv/configs.git"),
        personal_repo("portfolio", "https://github.com/BenSiv/portfolio.git"),
        personal_repo("canada-sole-proprietorship", "https://github.com/BenSiv/canada-sole-proprietorship.git"),
        personal_repo("finance", "https://github.com/BenSiv/finance.git"),
        personal_repo("jobs", "https://github.com/BenSiv/jobs.git"),
        personal_repo("notes", "https://github.com/BenSiv/notes.git"),
        personal_repo("resume", "https://github.com/BenSiv/resume.git"),
        personal_repo("separation", "https://github.com/BenSiv/separation.git"),
    },
}
