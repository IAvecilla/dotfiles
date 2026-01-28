{ config, pkgs, username, ... }:

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
    git
    curl
    wget

    # Neovim and dependencies
    neovim
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

  # Git configuration
  programs.git = {
    enable = true;
    userName = "IAvecilla";
    userEmail = "iavecilla@fi.uba.ar";
    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
  };

  # Zsh configuration (optional but recommended)
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" ];
    };
  };
}
