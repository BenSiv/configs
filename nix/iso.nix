{ pkgs, lib, inputs, config, ... }:

{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix"
    inputs.home-manager.nixosModules.home-manager
  ];

  nixpkgs.config.allowUnfree = true;
  programs.dconf.enable = true;
  time.timeZone = "America/Los_Angeles";

  # Explicitly disable Firefox module
  programs.firefox.enable = lib.mkForce false;

  # Remove unwanted default GNOME apps
  # We use mkForce on excludePackages to ensure it takes precedence over other modules
  environment.gnome.excludePackages = with pkgs; [
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

  # System packages
  # Removed lib.mkForce to ensure we don't accidentally remove critical boot/installer packages
  environment.systemPackages = with pkgs; [
    # Essential tools
    vim
    wget
    git
    
    # GNOME Customization
    gnome-tweaks
    gnome-console
    gnome-text-editor
    gnome-clocks
    gnome-calendar
    snapshot
  ];

  # Force override the auto-login user
  services.displayManager.autoLogin.user = lib.mkForce "bensiv";
  
  # Define the user
  users.users.bensiv = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" ];
    initialPassword = "nixos";
  };

  # Home Manager Setup
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users.bensiv = {
      imports = [ ./home.nix ];
      home.file."hm-debug-success".text = "Home Manager successfully ran!";
    };
  };
}
