{ config, pkgs, username, dotfilesDir, ... }:

{
  # Home Manager needs to know your username and home directory
  home.username = username;
  home.homeDirectory =
    if pkgs.stdenv.isDarwin
    then "/Users/${username}"
    else "/home/${username}";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "24.11";

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # User packages to install
  home.packages = with pkgs; [
    curl
    wget
    rustup
    docker
  ];

  # Neovim configuration
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    extraPackages = with pkgs; [
      # Add any tools your nvim config needs here
    ];
  };

  # Link your existing nvim config from this repo
  home.file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink
    "${dotfilesDir}/nvim";

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

  # Ghostty terminal (config only - binary managed per-platform)
  programs.ghostty = {
    enable = true;
    package = null;
    enableZshIntegration = true;
    systemd.enable = false;
    settings = {
      font-size = 15;
      cursor-style = "underline";
      command = "${pkgs.zsh}/bin/zsh";
      theme = if pkgs.stdenv.isDarwin then "flexoki-light" else "Flexoki Light";
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
  };
}
