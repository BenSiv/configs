use-modules
  gnu home
  gnu home services
  gnu home services shells
  gnu services
  guix gexp
  gnu packages
  gnu packages version-control
  gnu packages gnome
  srfi srfi-1

define-public home-config
  home-environment
    packages
      list
        ;; Tools needed for activation scripts
        . git 
        . dconf

    services
      list
        ;; Bash
        service home-bash-service-type
          home-bash-configuration
            bashrc
              list
                local-file "../bash/bashrc.sh"

        ;; Git Configuration
        simple-service 'git-config
          home-files-service-type
          list
            list ".gitconfig"
              local-file "../git/gitconfig.toml"

        ;; Nano Configuration
        simple-service 'nano-config
          home-files-service-type
          list
            list ".nanorc"
              local-file "../nano/nanorc"

        ;; Link Config Directories (Micro)
        simple-service 'link-config-dirs
          home-activation-service-type
          #~ begin
              use-modules (guix build utils)
              let ((config-dir (string-append (getenv "HOME") "/.config"))
                   (micro-src (string-append (getenv "HOME") "/Documents/configs/micro")))
                mkdir-p config-dir
                unless (file-exists? (string-append config-dir "/micro"))
                  symlink micro-src (string-append config-dir "/micro")

        ;; Clone Projects
        simple-service 'clone-repos
          home-activation-service-type
          #~ begin
              let ((home (getenv "HOME"))
                   (repos '(("https://github.com/BenSiv/brain-ex.git" . "brain-ex")
                            ("https://github.com/BenSiv/lua-utils.git" . "lua-utils")
                            ("https://github.com/BenSiv/luam.git" . "luam"))))
                for-each
                  lambda (repo)
                    let ((url (car repo))
                         (dir (cdr repo))
                         (target (string-append home "/" dir)))
                      unless (file-exists? target)
                        format #t "Cloning ~a...~%" dir
                        system* "git" "clone" url target
                  repos

        ;; GNOME Settings (Declarative)
        service home-dconf-service-type
          home-dconf-configuration
            settings
              `(("org/gnome/desktop/interface"
                 ((color-scheme . "prefer-dark")
                  (clock-format . "24h")
                  (clock-show-date . #t)
                  (show-battery-percentage . #t)))

                ("org/gnome/mutter"
                 ((dynamic-workspaces . #t)))

                ("org/gnome/shell"
                 ((favorite-apps . '())))

                ("org/gnome/desktop/background"
                 ((picture-uri . "file:///run/current-system/profile/share/backgrounds/gnome/blobs-l.svg")
                  (picture-uri-dark . "file:///run/current-system/profile/share/backgrounds/gnome/blobs-d.svg"))))

        ;; Zen Browser Information
        simple-service 'zen-browser-info
          home-activation-service-type
          #~ begin
               format #t "\n[NOTE] Zen Browser is not in Guix. Install via Flatpak:\n"
               format #t "flatpak install flathub app.zen_browser.zen\n"
