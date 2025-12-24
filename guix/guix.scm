(use-modules (guix packages)
             (gnu packages)
             (gnu packages admin) ;; Added as per instruction
             (gnu packages base)
             (gnu packages commencement)
             (gnu packages curl)
             (gnu packages databases)
             ;; (gnu packages editors)
             (gnu packages lua)
             (gnu packages pkg-config)
             (gnu packages readline)
             (gnu packages sqlite)
             ;; (gnu packages tree)
             (gnu packages version-control)
             (gnu packages wget)
             (gnu packages compression))

(packages->manifest
 (list git
       curl
       wget
       unzip
       tree
       gcc-toolchain
       gnu-make
       pkg-config
       readline
       sqlite
       (specification->package "lua@5.1")
       lua5.1-filesystem
       ;; luarocks
       ;; micro
       ))
