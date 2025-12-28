{
  description = "NixOS Configuration for BenSiv";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Zen Browser
    zen-browser.url = "github:youwen5/zen-browser-flake";

    # Antigravity
    antigravity.url = "github:jacopone/antigravity-nix";

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
      system = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.bensiv = import ./home.nix;
          }
        ];

      };

      iso = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix"
          home-manager.nixosModules.home-manager
          {
            nixpkgs.config.allowUnfree = true;
            
            # Remove unwanted default GNOME apps
            environment.gnome.excludePackages = with nixpkgs.legacyPackages.x86_64-linux; [
              epiphany
              totem
              evince
              geary
              gnome-contacts
              gnome-music
              gnome-maps
              gnome-weather
              gnome-photos
              gnome-characters
              gnome-font-viewer
              gnome-connections
              simple-scan
              yelp
              gnome-tour
            ];
            
            # Add gnome-tweaks
            environment.systemPackages = [ nixpkgs.legacyPackages.x86_64-linux.gnome-tweaks ];
            
            # User setup
            users.users.bensiv = {
              isNormalUser = true;
              extraGroups = [ "wheel" "networkmanager" "video" ];
              initialPassword = "nixos"; # Default password for live session
            };
            
            # Auto-login as bensiv instead of 'nixos' for the full experience
            services.displayManager.autoLogin.user = nixpkgs.lib.mkForce "bensiv";

            # Home Manager setup
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.bensiv = import ./home.nix;
          }
        ];
      };
    };
  };
}
