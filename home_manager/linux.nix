{ pkgs, nixgl, ... }:

let
  nixGL = nixgl.packages.${pkgs.system}.nixGLDefault;
  ghostty-gl = pkgs.writeShellScriptBin "ghostty" ''
    exec ${nixGL}/bin/nixGL ${pkgs.ghostty}/bin/ghostty "$@"
  '';
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
