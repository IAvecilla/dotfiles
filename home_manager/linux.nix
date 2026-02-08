{ pkgs, nixgl, ... }:

let
  nixGL = nixgl.packages.${pkgs.system}.nixGLDefault;
  ghostty-gl = pkgs.writeShellScriptBin "ghostty" ''
    exec ${nixGL}/bin/nixGL ${pkgs.ghostty}/bin/ghostty "$@"
  '';
  # Wrap niri with libraries that winit dlopen's at runtime
  # (not in Nix closure, so unavailable on non-NixOS)
  niri-wrapped = (pkgs.symlinkJoin {
    name = "niri-wrapped";
    paths = [ pkgs.niri ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/niri \
        --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath [
          pkgs.libxcursor
          pkgs.libxi
          pkgs.libxrandr
        ]}"
    '';
  }) // {
    inherit (pkgs.niri) cargoBuildNoDefaultFeatures cargoBuildFeatures;
  };
in {
  # Set Ghostty as default terminal
  home.sessionVariables.TERMINAL = "ghostty";

  xdg.desktopEntries.ghostty = {
    name = "Ghostty";
    genericName = "Terminal Emulator";
    exec = "ghostty";
    terminal = false;
    categories = [ "System" "TerminalEmulator" ];
  };

  # Niri scrollable tiling Wayland compositor
  programs.niri = {
    enable = true;
    package = niri-wrapped;
    settings = {
      prefer-no-csd = true;

      input.keyboard.xkb.layout = "us";

      input.touchpad = {
        tap = true;
        natural-scroll = true;
        dwt = true; # disable while typing
      };

      binds = {
        # Window focus (vim-style)
        "Mod+H".action.focus-column-left = [];
        "Mod+L".action.focus-column-right = [];
        "Mod+J".action.focus-window-down = [];
        "Mod+K".action.focus-window-up = [];

        # Move windows
        "Mod+Shift+H".action.move-column-left = [];
        "Mod+Shift+L".action.move-column-right = [];
        "Mod+Shift+J".action.move-window-down = [];
        "Mod+Shift+K".action.move-window-up = [];

        # Window management
        "Mod+Q".action.close-window = [];
        "Mod+F".action.maximize-column = [];
        "Mod+Shift+F".action.fullscreen-window = [];
        "Mod+C".action.center-column = [];

        # Column width
        "Mod+Minus".action.set-column-width = "-10%";
        "Mod+Equal".action.set-column-width = "+10%";

        # Terminal & launcher
        "Mod+T".action.spawn = "ghostty";
        "Mod+D".action.spawn = "fuzzel";

        # Workspaces
        "Mod+1".action.focus-workspace = 1;
        "Mod+2".action.focus-workspace = 2;
        "Mod+3".action.focus-workspace = 3;
        "Mod+4".action.focus-workspace = 4;
        "Mod+5".action.focus-workspace = 5;
        "Mod+Shift+1".action.move-column-to-workspace = 1;
        "Mod+Shift+2".action.move-column-to-workspace = 2;
        "Mod+Shift+3".action.move-column-to-workspace = 3;
        "Mod+Shift+4".action.move-column-to-workspace = 4;
        "Mod+Shift+5".action.move-column-to-workspace = 5;

        # Screenshot
        "Print".action.screenshot = [];
        "Mod+Print".action.screenshot-window = [];

        # Quit niri
        "Mod+Shift+E".action.quit = [];
      };
    };
  };

  # Symlink niri systemd services so systemd can find them
  systemd.user.services.niri = {
    Unit = {
      Description = "Niri scrollable tiling Wayland compositor";
      BindsTo = [ "graphical-session.target" ];
      Before = [ "graphical-session.target" ];
      After = [ "graphical-session-pre.target" ];
    };
    Service = {
      Slice = "session.slice";
      Type = "notify";
      ExecStart = "${niri-wrapped}/bin/niri --session";
    };
  };

  systemd.user.targets.niri-shutdown = {
    Unit = {
      Description = "Niri shutdown";
      Conflicts = [ "graphical-session.target" ];
    };
  };

  # Wayland companion packages
  home.packages = [
    ghostty-gl             # Ghostty wrapped with nixGL
    nixGL                  # nixGL available in PATH for other apps
    pkgs.fuzzel            # Application launcher
    pkgs.swaybg            # Wallpaper
    pkgs.swaylock          # Screen locker
    pkgs.mako              # Notification daemon
    pkgs.xwayland-satellite # X11 app compatibility
    pkgs.wl-clipboard      # Clipboard utilities
    pkgs.grim              # Screenshot tool
    pkgs.slurp             # Region selection for screenshots
  ];
}
