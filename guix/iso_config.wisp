use-modules
  gnu
  guix gexp

use-service-modules desktop

use-package-modules bootloaders certs fonts gnome

;; Load the base system configuration
define system-os
  load "system.scm"

;; Create the ISO system by inheriting and adding installer files
operating-system
  inherit system-os
  
  ;; Add installer files to services
  services
    append
      list
        ;; Embed Configuration Files
        extra-special-file "/etc/guix-install/system.scm"
                           local-file "system.scm"
        extra-special-file "/etc/guix-install/home.scm"
                           local-file "home.scm"
        extra-special-file "/etc/guix-install/channels.scm"
                           local-file "channels.scm"
        
        ;; Embed Installer Script
        extra-special-file "/etc/guix-install/install.sh"
                           local-file "install.sh" #:recursive? #t
        
        ;; Global Alias for ease of use
        extra-special-file "/etc/profile.d/install-alias.sh"
                           plain-file "install-alias.sh" "alias install-system='sudo bash /etc/guix-install/install.sh'"
        
        ;; Message of the Day
        extra-special-file "/etc/motd"
                           plain-file "motd" "\n\n   Welcome to Guix System Installer!   \n   Run 'install-system' to install.    \n\n"
      
      operating-system-user-services system-os
