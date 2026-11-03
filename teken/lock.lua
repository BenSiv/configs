-- Written by tkn lock / tkn update. Commit it with the spec.
return {
    fetch = {
        ["https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem"] = "90a6f1a7978a1b1b096dca6c57511ca48d3b8cf052f8e704baf358f34ea2f21b",
    },
    images = {
        ["ubuntu:24.04"] = "sha256:fe81560990fae86dc4743202b2cb4d3df98d0bcf949173cecef15ce1127ef852",
    },
    sources = {
        brain_ex = {
            commit = "4529c4bbace21068baa259115a8a70305d536c42",
            git = "https://github.com/BenSiv/brain-ex.git",
        },
        camopass = {
            commit = "72dcac09efab3044a5d842d438407b330f0026dc",
            git = "https://github.com/BenSiv/camopass.git",
        },
        configs = {
            commit = "cbc65a3475ba7031de4a96c0c62e84f127f1c8f8",
            git = "https://github.com/BenSiv/configs.git",
        },
        daat = {
            commit = "87db22eac6be3169d5c776089ccbebc361c72a8d",
            git = "https://github.com/BenSiv/daat.git",
        },
        luam = {
            commit = "ecb4ff2dbfa2682bf9850a20f17c9d482c2f5251",
            git = "https://github.com/BenSiv/luam.git",
        },
        seder = {
            commit = "01e180362ccad4c9b11ec53514ba8c2fa342935b",
            git = "https://github.com/BenSiv/seder.git",
        },
        software = {
            commit = "1eecc8fd7fce99f8e9972ba74e605479eebffb8f",
            git = "https://github.com/celleste-bio/software.git",
        },
        teken = {
            commit = "e36a781ff2aa18d4b4b755882ca4685ce3c9c094",
            git = "https://github.com/BenSiv/teken.git",
        },
    },
}
