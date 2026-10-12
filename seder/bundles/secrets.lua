-- The pass password store and the GPG key that decrypts it. Needs, at
-- apply time: GitHub credentials for the private repo (git asks; the
-- linked gitconfig stores them), and the phone holding the key connected
-- over USB so ${gpg_keys} is mounted. Listed last on a machine so a
-- missing phone stops the apply only after everything else is done.
return {
    repo = {
        present = {
            {path = "~/.password-store", url = "https://github.com/BenSiv/pass.git"},
        },
    },
    run = {
        present = {
            {name = "gpg import pass key",
             cmd = "gpg --batch --import \"${gpg_keys}/pass-public-key.asc\" \"${gpg_keys}/pass-secret-key.asc\"",
             unless = "gpg --batch --list-secret-keys C37113A9F2DD0CCC798522DEA748A133F7C13732"},
            {name = "gpg trust pass key",
             cmd = "echo C37113A9F2DD0CCC798522DEA748A133F7C13732:6: | gpg --batch --import-ownertrust",
             unless = "gpg --export-ownertrust | grep -qx C37113A9F2DD0CCC798522DEA748A133F7C13732:6:"},
        },
    },
}
