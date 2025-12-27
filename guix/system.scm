(use-modules
  (gnu)
  (gnu system)
  (gnu tests)
  (gnu services)
  (gnu services desktop)
  (gnu services networking)
  (gnu services cups)
  (gnu packages)
  (gnu packages base)
  (gnu packages nss)
  (gnu packages gnome)
  (gnu packages version-control)
  (gnu packages web)
  (gnu packages wget)
  (gnu packages curl)
  (gnu packages admin)
  (gnu packages lua)
  (gnu packages commencement)
  (gnu packages readline)
  (gnu packages text-editors)
  (gnu packages compression)
  (gnu packages sqlite)
  (gnu packages password-utils)
  (nongnu packages linux)
  (nongnu packages firmware)
  (srfi srfi-1))

(use-service-modules desktop networking avahi dbus cups)

(operating-system
  (host-name "guix-machine")
  (timezone "Etc/UTC")
  (locale "en_US.utf8")

  (kernel linux-lts)
  (firmware (list linux-firmware))

  (keyboard-layout (keyboard-layout "us"))

  (bootloader
    (bootloader-configuration
      (bootloader grub-efi-bootloader)
      (targets (list "/boot/efi"))))

  (file-systems
    (cons*
      (file-system
        (mount-point "/")
        (device (uuid "bd4918c3-0360-4f14-b075-7f5ff95a686c"))
        (type "ext4"))
      (file-system
        (mount-point "/boot/efi")
        (device (uuid "8A1B-0591" 'fat))
        (type "vfat"))
      %base-file-systems))

  (users
    (cons
      (user-account
        (name "bensiv")
        (password "$6$5WOfFv1MJ7fer/vu$/jiZpcR.lEV9fsSdxm0H0Dtda/yWfrR87q.j1QRvP6r8b/A4nOFTG7zP4P038c9R1rlgJD6/aRafvOVADU.pn1")
        (group "users")
        (supplementary-groups (list "wheel" "netdev" "audio" "video"))
        (home-directory "/home/bensiv"))
      %base-user-accounts))

  (packages
    (append
      (list
        gnome
        nano
        git
        curl
        wget
        unzip
        tree
        sqlite
        lua-5.1
        gcc-toolchain
        gnu-make
        readline
        password-store)
      %base-packages))

  (services
    (append
      (list
        (service gnome-desktop-service-type)
        (service cups-service-type))
      %desktop-services)))
