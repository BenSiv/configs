-- AWS CLI, gcloud and Terraform at pinned versions. teken's `fetch` lands
-- after the build steps, so it can't feed an installer; these steps
-- download a versioned release and check its sha256 instead. The
-- `configs` source is only the step's working tree.
return {
    sources = {
        configs = {git = "https://github.com/BenSiv/configs.git"},
    },
    build = {
        {name = "awscli", from = "configs",
         cmd = "curl -fsSL -o awscli.zip https://awscli.amazonaws.com/awscli-exe-linux-x86_64-2.27.50.zip"
            .. " && echo '2ed5b5a1d92f3aa860034b0d9ec0902574852c3e60916e221414abb6f1504d9e  awscli.zip' | sha256sum -c -"
            .. " && unzip -q awscli.zip && ./aws/install -i \"$PWD/aws-cli\" -b \"$PWD/out\"",
         install = {["out/aws"] = "bin/aws"}},
        {name = "gcloud", from = "configs",
         cmd = "curl -fsSL -o gcloud.tgz https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-530.0.0-linux-x86_64.tar.gz"
            .. " && echo 'ecaa6e34afb8abb0e8a71b46b0ce7af44fa9832c867e6e3266193d368f498eaf  gcloud.tgz' | sha256sum -c -"
            .. " && tar -xzf gcloud.tgz && mkdir -p out"
            .. " && for b in gcloud gsutil bq; do ln -s \"$PWD/google-cloud-sdk/bin/$b\" out/$b; done",
         install = {["out/gcloud"] = "bin/gcloud", ["out/gsutil"] = "bin/gsutil", ["out/bq"] = "bin/bq"}},
        {name = "terraform", from = "configs",
         cmd = "curl -fsSL -o tf.zip https://releases.hashicorp.com/terraform/1.12.2/terraform_1.12.2_linux_amd64.zip"
            .. " && echo '1eaed12ca41fcfe094da3d76a7e9aa0639ad3409c43be0103ee9f5a1ff4b7437  tf.zip' | sha256sum -c -"
            .. " && unzip -q tf.zip terraform",
         install = {["terraform"] = "bin/terraform"}},
    },
    verify = {"aws --version", "gcloud --version", "terraform -version"},
}
