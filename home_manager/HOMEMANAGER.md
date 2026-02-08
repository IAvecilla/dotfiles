# Home Manager Setup

This guide explains how to use Home Manager with Nix on macOS and Linux (Pop!_OS).

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      flake.nix (entry point)                │
├────────────────────────────┬────────────────────────────────┤
│         macOS              │           Linux                │
│  ┌──────────────────┐      │   ┌──────────────────┐         │
│  │   darwin.nix      │      │   │   linux.nix       │         │
│  │  (system config)  │      │   │  (niri + wayland) │         │
│  └──────────────────┘      │   └──────────────────┘         │
│           │                │            │                   │
│           ▼                │            ▼                   │
│  ┌──────────────────────────────────────────────────┐       │
│  │              home.nix (shared config)             │       │
│  │   neovim, git, zsh, ghostty, oh-my-posh           │       │
│  └──────────────────────────────────────────────────┘       │
└─────────────────────────────────────────────────────────────┘
```

## Files Explained

### `flake.nix`
Entry point. Defines inputs and configurations for both platforms:
- **darwinConfigurations** — nix-darwin + home-manager for macOS
- **homeConfigurations.nacho** — standalone home-manager for Linux (Pop!_OS)
- **homeConfigurations.ignacioavecilla** — standalone home-manager for macOS

### `home.nix`
Shared configuration that works on both macOS and Linux:
- Packages (curl, wget)
- Programs (neovim, git, zsh, ghostty, oh-my-posh)
- Dotfile symlinks
- Automatically detects the platform for paths and packages

### `darwin.nix`
macOS-only system configuration (nix-darwin):
- Dock, Finder, trackpad settings
- Homebrew integration
- Touch ID for sudo

### `linux.nix`
Linux-only configuration:
- Niri (scrollable tiling Wayland compositor)
- Wayland companion tools (fuzzel, mako, swaybg, etc.)

## Installation

### 1. Install Nix

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Or use the official installer:
```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

Restart your shell after installation.

### 2. Enable Flakes (if not already enabled)

```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### 3. Apply Configuration

**On Linux (Pop!_OS):**
```bash
cd ~/dotfiles/home_manager
nix run nixpkgs#home-manager -- switch --flake .#nacho
```

After first install:
```bash
home-manager switch --flake ~/dotfiles/home_manager#nacho
```

**On macOS (with nix-darwin):**
```bash
cd ~/misc/dotfiles/home_manager
darwin-rebuild switch --flake .
```

**On macOS (standalone home-manager):**
```bash
cd ~/misc/dotfiles/home_manager
home-manager switch --flake .#ignacioavecilla
```

## Daily Usage

### Edit your configuration

```bash
nvim ~/dotfiles/home_manager/home.nix    # Shared config
nvim ~/dotfiles/home_manager/linux.nix   # Linux/niri config
nvim ~/dotfiles/home_manager/darwin.nix  # macOS config
```

### Apply changes

**Linux:**
```bash
home-manager switch --flake ~/dotfiles/home_manager#nacho
```

**macOS:**
```bash
darwin-rebuild switch --flake ~/misc/dotfiles/home_manager
```

### Add a new package

Edit `home.nix` for shared packages or `linux.nix`/`darwin.nix` for platform-specific ones:

```nix
home.packages = with pkgs; [
  # ... existing packages
  htop
  zoxide
];
```

Then apply with the commands above.

### Search for packages

```bash
nix search nixpkgs htop
```

Or search on [search.nixos.org](https://search.nixos.org/packages).

## Useful Commands

| Command | Description |
|---------|-------------|
| `home-manager switch --flake .#nacho` | Apply Linux config |
| `darwin-rebuild switch --flake .` | Apply macOS config |
| `home-manager build --flake .#nacho` | Build without applying (test) |
| `home-manager generations` | List all generations |
| `home-manager switch --rollback` | Rollback to previous generation |
| `nix flake update` | Update all inputs to latest versions |
| `nix store gc` | Garbage collect unused packages |

## Niri (Linux Window Manager)

Niri is a scrollable tiling Wayland compositor configured in `linux.nix`.

### Key bindings

| Binding | Action |
|---------|--------|
| `Mod+H/J/K/L` | Focus left/down/up/right |
| `Mod+Shift+H/J/K/L` | Move window left/down/up/right |
| `Mod+Q` | Close window |
| `Mod+F` | Maximize column |
| `Mod+Shift+F` | Fullscreen |
| `Mod+C` | Center column |
| `Mod+T` | Open terminal (ghostty) |
| `Mod+D` | App launcher (fuzzel) |
| `Mod+1-5` | Switch workspace |
| `Mod+Shift+1-5` | Move to workspace |
| `Print` | Screenshot |
| `Mod+Shift+E` | Quit niri |

## Troubleshooting

### "error: experimental Nix feature 'flakes' is disabled"
Enable flakes: `echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf`

### "error: file 'home-manager' was not found"
You need to use `nix run nixpkgs#home-manager` for the first run.

### Package not found
Check the exact name with `nix search nixpkgs <name>`.

### Changes not applying
Try with `--impure` flag: `home-manager switch --flake . --impure`
