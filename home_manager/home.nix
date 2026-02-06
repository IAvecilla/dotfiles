{ config, pkgs, username, paneru, ... }:

{
  imports = [
    paneru.homeModules.paneru
  ];
  # Home Manager needs to know your username and home directory
  home.username = username;
  home.homeDirectory = "/Users/${username}";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "24.11"; # You can update this to the latest release

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # User packages to install
  # These become available in your PATH
  home.packages = with pkgs; [
    # Essential tools
    curl
    wget
  ];

  # Neovim configuration
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # Additional packages available to neovim at runtime
    extraPackages = with pkgs; [
      # Add any tools your nvim config needs here
      # For example: tree-sitter, nodejs, etc.
    ];
  };

  # Link your existing nvim config from this repo
  home.file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/misc/dotfiles/nvim";

  # Paneru window manager configuration
  services.paneru = {
    enable = true;
    settings = {
      options = {
        focus_follows_mouse = false;
        preset_column_widths = [ 0.25 0.33 0.5 0.66 0.75 ];
        swipe_gesture_fingers = 4;
        animation_speed = 4000;
      };
      bindings = {
        window_focus_west = "cmd - h";
        window_focus_east = "cmd - l";
        window_focus_north = "cmd - k";
        window_focus_south = "cmd - j";
        window_swap_west = "alt - h";
        window_swap_east = "alt - l";
        window_swap_first = "alt + shift - h";
        window_swap_last = "alt + shift - l";
        window_center = "alt - c";
        window_resize = "alt - r";
        window_fullwidth = "alt - f";
        window_manage = "ctrl + alt - t";
        window_stack = "alt - ]";
        window_unstack = "alt + shift - ]";
        quit = "ctrl + alt - q";
      };
    };
  };

  # Git configuration
  programs.git = {
    enable = true;
    settings = {
      user.name = "IAvecilla";
      user.email = "iavecilla@fi.uba.ar";
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
  };

  # Zsh configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      theme = "";  # Disabled - using oh-my-posh instead
      plugins = [ "git" ];
    };
    initExtra = ''
    export PATH="$HOME/.local/bin:$PATH"
  '';
  };

  # Ghostty terminal
  programs.ghostty = {
    enable = true;
    package = null;
    settings = {
      font-size = 15;
      cursor-style = "underline";
      theme = "flexoki-light";
      keybind = [
        "super+right=next_tab"
        "super+left=previous_tab"
      ];
    };
  };

  # Oh My Posh prompt
  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
    settings = builtins.fromTOML (builtins.readFile ../ohmyposh/zen.toml);
  };}
