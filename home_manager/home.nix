{ config, lib, pkgs, username, dotfilesDir, ... }:

{
  # Home Manager needs to know your username and home directory
  home.username = username;
  home.homeDirectory =
    if pkgs.stdenv.hostPlatform.isDarwin
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
    docker # CLI only — Docker Desktop (macOS) or dockerd (Linux) installed separately
    tmux
    htop
    mergiraf
    difftastic
  ];

  # Self-updating CLIs installed via their official installers into ~/.local/bin
  # (nixpkgs' claude-code lags far behind, and herdr isn't packaged). Only runs
  # when the binary is missing; failures (e.g. offline) don't abort the switch.
  home.activation.installLocalCLIs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH="${lib.makeBinPath [ pkgs.curl pkgs.bash pkgs.coreutils pkgs.gnutar pkgs.gzip ]}:/usr/bin:/bin:$PATH"
    if [ ! -x "$HOME/.local/bin/claude" ]; then
      run sh -c 'curl -fsSL https://claude.ai/install.sh | bash' || echo "warning: Claude Code install failed"
    fi
    if [ ! -x "$HOME/.local/bin/herdr" ]; then
      run sh -c 'curl -fsSL https://herdr.dev/install.sh | sh' || echo "warning: herdr install failed"
    fi
  '';

  # Neovim configuration
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    # init.lua comes from the symlinked dotfiles/nvim dir; load HM's generated
    # Lua via wrapper args instead of writing ~/.config/nvim/init.lua
    sideloadInitLua = true;
    # keep the pre-26.05 provider defaults (warning otherwise)
    withRuby = true;
    withPython3 = true;

    extraPackages = with pkgs; [
      # Add any tools your nvim config needs here
    ];
  };

  # Link your existing nvim config from this repo
  home.file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink
    "${dotfilesDir}/nvim";

  # Tmux — config only, managed via symlink
  home.file.".config/tmux/tmux.conf".source = config.lib.file.mkOutOfStoreSymlink
    "${dotfilesDir}/tmux/tmux.conf";

  # Git configuration
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "IAvecilla";
        email = "iavecilla@fi.uba.ar";
      };
      alias = {
        pushb = "!git push -u origin $(git rev-parse --abbrev-ref HEAD)";
        # structural diff on demand: `git dft diff`, `git dft show`, `git dft log -p`
        dft = "!f() { GIT_EXTERNAL_DIFF=difft git \"$@\"; }; f";
      };
      init.defaultBranch = "main";
      commit = {
        gpgsign = true;
        verbose = true;
      };
      column.ui = "auto";
      branch.sort = "-committerdate";
      pager = {
        branch = false;
        tag = false;
      };
      tag.sort = "version:refname";
      diff = {
        algorithm = "histogram";
        colorMoved = "plain";
        mnemonicPrefix = true;
        renames = true;
      };
      push = {
        default = "simple";
        autoSetupRemote = true;
        followTags = true;
      };
      fetch = {
        prune = true;
        pruneTags = true;
        all = true;
      };
      rerere = {
        enabled = true;
        autoupdate = true;
      };
      rebase = {
        autoSquash = true;
        autoStash = true;
        updateRefs = true;
      };
      merge.conflictstyle = "zdiff3";
    };
  };

  # delta — syntax-highlighting pager for diffs (git diff/show/log -p/blame,
  # and the `git add -p` interactive hunk view).
  # NOTE: keep `diff.external` unset — an external diff driver replaces git's
  # diff engine entirely and delta would never see a real diff. difftastic
  # stays available on demand via the `git dft` alias above.
  programs.delta = {
    enable = true;
    enableGitIntegration = true;  # sets core.pager + interactive.diffFilter
    options = {
      navigate = true;      # n / N jump between files in the pager
      line-numbers = true;  # old/new line numbers in the gutter
      hyperlinks = true;    # OSC-8 clickable paths (Ghostty supports these)
      dark = true;          # matches the Catppuccin Mocha terminal theme
      side-by-side = false; # unified view
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
    initContent = ''
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
      theme = "Catppuccin Mocha";
      term = "xterm-256color";
      scrollback-limit = 4294967295;
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
