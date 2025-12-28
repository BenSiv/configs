{ config, pkgs, inputs, lib, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "bensiv";
  home.homeDirectory = "/home/bensiv";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # Core Tools
    git
    micro
    curl
    wget
    ripgrep
    fd
    jq
    tree
    
    # Dev Tools
    pkgs.lua5_1
    gnumake
    gcc
    nodejs
    python3
    
    # UI Tools
    google-chrome
    inputs.zen-browser.packages."${pkgs.system}".default
    inputs.antigravity.packages."${pkgs.system}".default
    
    # My Utils
    # (Assuming these will be fetched or built separately, but adding placeholder)
  ];

  # GNOME Configuration
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      accent-color = "orange";
      clock-show-weekday = false;
      clock-format = "24h";
    };
    
    "org/gnome/shell" = {
      favorite-apps = [];
    };

    "org/gnome/mutter" = {
      dynamic-workspaces = false;
      experimental-features = ["scale-monitor-framebuffer"];
    };

    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 1;
    };
    
    # Custom Keybindings
    "org/gnome/desktop/wm/keybindings" = {
      toggle-fullscreen = ["<Control>Return"];
    };

    # Clock Format - use native GNOME format
    "org/gnome/desktop/interface".clock-show-date = true;
    
    # Custom Background
    "org/gnome/desktop/background" = {
      picture-uri = "file:///home/bensiv/Pictures/cosy cabin.png";
      picture-uri-dark = "file:///home/bensiv/Pictures/cosy cabin.png";
    };
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".bash_aliases".text = ''
      # User Aliases
      alias readdir="ls --format=single-column --almost-all --group-directories-first --color=auto"
      alias rd="lua $HOME/lua-automations/readdir.lua"
      alias edit="lua $HOME/lua-automations/edit.lua"
      alias find="lua $HOME/lua-automations/find.lua"
      alias repo="lua $HOME/lua-automations/repo.lua"
      alias sqlite="sqlite3"
      alias python="python3"
      alias brex="$HOME/brain-ex/brex"
      alias ted="gnome-text-editor"
      alias mde="podman exec -it min-dev-env bash"
    '';
  };

  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/bensiv/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "micro";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "BenSiv";
    userEmail = "bensiv92@gmail.com";
    aliases = {
      tree = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n'' %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all";
    };
    extraConfig = {
      init.defaultBranch = "main";
      push.default = "current";
      credential.helper = "store";
      core.editor = "micro";
    };
  };

  programs.micro = {
    enable = true;
    settings = {
      colorscheme = "bensiv";
      statusline = false;
      tabstospaces = true;
      tabsize = 4;
      clipboard = "external";
      "filetype.bats" = "sh";
    };
  };

  xdg.configFile."micro/bindings.json".text = builtins.toJSON {
      "Alt-/" = "lua:comment.comment";
      "CtrlUnderscore" = "lua:comment.comment";
      "Ctrl-Space" = "CommandMode";
      "Alt-PageUp" = "NextSplit";
      "Alt-PageDown" = "PreviousSplit";
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      ll = "ls -l";
      lsa = "ls -la";
      ".." = "cd ..";
    };
    initExtra = ''
      export PS1='\[\033[32m\]\h\[\033[0m\] | \[\033[34m\]\w\[\033[0m\] > '
      export LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:'
      
      if [ -f ~/.bash_aliases ]; then
          . ~/.bash_aliases
      fi
      
      if [ -f ~/.path_addons ]; then
          . ~/.path_addons
      fi
      
      export LUA_PATH="$HOME/lua-utils/src/?.lua;;"
      export TERM=xterm-256color
    '';
  };

  # Git Projects Fetcher
  # Add your specific repositories to the list below.
  home.activation.downloadGitProjects = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p $HOME/Projects
    
    # USER: Add your repository URLs here. Example:
    # REPOS=("https://github.com/myuser/myrepo.git")
    REPOS=()
    
    for repo in "''${REPOS[@]}"; do
        name=$(basename "$repo" .git)
        if [ ! -d "$HOME/Projects/$name" ]; then
            echo "Cloning $name..."
            ${pkgs.git}/bin/git clone "$repo" "$HOME/Projects/$name"
        else
            echo "$name already exists, skipping."
        fi
    done
  '';
}
