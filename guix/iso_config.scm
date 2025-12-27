(use-modules
  (gnu)
  (guix gexp)
  (guix packages)
  (guix build-system copy)
  (guix build-system trivial)
  (guix git-download))

(use-service-modules desktop)

(use-package-modules
  bootloaders
  certs
  fonts
  gnome)

(define system-os
  (load "system.scm"))

(define custom-installer
  (package
    (name "custom-installer")
    (version "1.0")
    (source
      (local-file "." "installer-source"
                  #:recursive? #t
                  #:select? (lambda (file stat)
                              ;; Simple filter to avoid copying .git or build artifacts
                              (not (or (string-contains file "/.git")
                                       (string-contains file "/install-image.iso"))))))
    (build-system trivial-build-system)
    (arguments
      (list
        #:modules '((guix build utils))
        #:builder
        #~(begin
            (use-modules (guix build utils))
            (let* ((source (assoc-ref %build-inputs "source"))
                   (out (assoc-ref %outputs "out"))
                   (bin (string-append out "/bin"))
                   (share (string-append out "/share/guix-install")))
              
              (mkdir-p bin)
              (mkdir-p share)

              ;; Install script
              (copy-file (string-append source "/install.sh")
                         (string-append bin "/install-system"))
              (chmod (string-append bin "/install-system") #o555)

              ;; Install configs
              (copy-file (string-append source "/system.scm")
                         (string-append share "/system.scm"))
              (copy-file (string-append source "/home.scm")
                         (string-append share "/home.scm"))
              (copy-file (string-append source "/channels.scm")
                         (string-append share "/channels.scm"))))))
    (synopsis "Custom automated installer script")
    (description "Installs the pre-configured Guix System.")
    (license #f) ;; Private config
    (home-page "https://github.com/BenSiv/configs")))

(operating-system
  (inherit system-os)
  (packages
    (append
      (list custom-installer)
      (operating-system-packages system-os)))
  (services
    (append
      (list (extra-special-file
              "/etc/motd"
              (plain-file
                "motd"
                "\n\n   Welcome to Guix System Installer!   \n   Run 'install-system' to install.    \n\n")))
      (operating-system-user-services system-os))))
