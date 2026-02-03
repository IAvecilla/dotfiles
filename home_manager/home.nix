{ config, pkgs, username, paneruPkg, ... }:

{
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

    # Window manager
    paneruPkg
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
  home.file.".paneru.toml".text = ''
    [options]
    preset_column_widths = [0.25, 0.33, 0.50, 0.66, 0.75]
    animation_speed = 50

    [bindings]
    # Navigation
    window_focus_west = "alt - h"
    window_focus_east = "alt - l"
    window_focus_north = "alt - k"
    window_focus_south = "alt - j"

    # Move/swap windows
    window_swap_west = "alt + shift - h"
    window_swap_east = "alt + shift - l"

    # Resize and manage
    window_resize = "alt - r"
    window_center = "alt - c"
    window_fullwidth = "alt - f"
    window_manage = "alt - t"

    # Quit
    quit = "ctrl + alt - q"
  '';

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
  };

  # Oh My Posh prompt
  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
    settings = builtins.fromTOML (builtins.readFile ../ohmyposh/zen.toml);
  };

  # Paneru launch agent - starts automatically at login
  launchd.agents.paneru = {
    enable = true;
    config = {
      Label = "com.user.paneru";
      ProgramArguments = [ "${paneruPkg}/bin/paneru" ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/tmp/paneru.log";
      StandardErrorPath = "/tmp/paneru.error.log";
    };
  };
}
