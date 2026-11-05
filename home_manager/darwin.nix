{ pkgs, username, ... }:

{
  # Primary user for user-specific system settings
  system.primaryUser = username;

  # Nix settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System packages (available to all users)
  environment.systemPackages = with pkgs; [
    vim
  ];

  # macOS system defaults
  system.defaults = {
    # Spaces / Mission Control
    spaces.spans-displays = false;  # "Displays have separate spaces" = enabled

    # Dock settings
    dock = {
      autohide = true;
      show-recents = false;
      # Disable hot corners
      wvous-bl-corner = 1;
      wvous-br-corner = 1;
      wvous-tl-corner = 1;
      wvous-tr-corner = 1;
    };

    # Finder settings
    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
      FXEnableExtensionChangeWarning = false;
    };

    # Global settings
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      # Disable press-and-hold for accent characters
      ApplePressAndHoldEnabled = false;
    };

    # Trackpad
    trackpad = {
      Clicking = true;  # Tap to click
      TrackpadRightClick = true;
    };

    # Custom preferences
    CustomUserPreferences = {
      "com.apple.dock" = {
        mru-spaces = false;
      };
    };
  };

  # Enable Touch ID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  # Homebrew (for macOS-only apps not in nixpkgs)
  homebrew = {
    enable = true;
    casks = [
      "ghostty"
      "discord"
      "raindropio"
    ];
    onActivation.cleanup = "zap";
  };

  # Create /etc/zshrc that loads nix-darwin environment
  programs.zsh.enable = true;

  # Set hostname
  networking.hostName = "Ignacios-MacBook-Pro-2";
  networking.computerName = "Ignacios-MacBook-Pro-2";
  networking.localHostName = "Ignacios-MacBook-Pro-2";

  # Used for backwards compatibility
  system.stateVersion = 6;

  # The platform the configuration will be used on
  nixpkgs.hostPlatform = "aarch64-darwin";

  # User configuration
  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };
}
