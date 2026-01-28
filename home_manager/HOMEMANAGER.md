# Home Manager Setup

This guide explains how to use Home Manager with Nix on macOS.

## What is Home Manager?

Home Manager is a Nix-powered tool that manages your user environment (dotfiles, packages, and configurations) in a declarative, reproducible way. Instead of manually installing packages and editing config files, you define everything in `.nix` files and Home Manager sets it up for you.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Your Mac                              │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────┐  │
│  │   flake.nix │───▶│   home.nix  │───▶│ ~/.config/nvim  │  │
│  │  (entry)    │    │ (config)    │    │ ~/.gitconfig    │  │
│  └─────────────┘    └─────────────┘    │ ~/.zshrc        │  │
│                                        │ Packages...     │  │
│                                        └─────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │   Nix Store     │
                    │  (/nix/store)   │
                    └─────────────────┘
```

## Files Explained

### `flake.nix`
The entry point. Defines:
- Input sources (nixpkgs, home-manager)
- Your system architecture (`aarch64-darwin` for Apple Silicon, `x86_64-darwin` for Intel)
- Your username

### `home.nix`
Your actual configuration. Defines:
- Packages to install
- Program configurations (neovim, git, zsh, etc.)
- Dotfile symlinks
- Environment variables

## Installation

### 1. Install Nix

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Or use the official installer:
```bash
sh <(curl -L https://nixos.org/nix/install)
```

Restart your shell after installation.

### 2. Enable Flakes (if not already enabled)

```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### 3. Apply Home Manager Configuration

```bash
# Navigate to your dotfiles directory
cd ~/misc/dotfiles

# Build and switch to the configuration
nix run nixpkgs#home-manager -- switch --flake .#ignacioavecilla
```

After first install, you can use:
```bash
home-manager switch --flake .#ignacioavecilla
```

## Daily Usage

### Edit your configuration

```bash
cd ~/misc/dotfiles
# Edit home.nix or flake.nix
nvim home.nix
```

### Apply changes

```bash
cd ~/misc/dotfiles
home-manager switch --flake .#ignacioavecilla
```

Or use the shorthand:
```bash
home-manager switch --flake ~/misc/dotfiles
```

### Add a new package

Edit `home.nix` and add to `home.packages`:

```nix
home.packages = with pkgs; [
  # ... existing packages
  htop
  zoxide  # smarter cd command
];
```

Then apply:
```bash
home-manager switch --flake .
```

### Search for packages

```bash
nix search nixpkgs htop
nix search nixpkgs nodejs
```

## Useful Commands

| Command | Description |
|---------|-------------|
| `home-manager switch --flake .` | Apply configuration changes |
| `home-manager build --flake .` | Build without applying (test) |
| `home-manager generations` | List all generations |
| `home-manager switch --rollback` | Rollback to previous generation |
| `nix flake update` | Update all inputs to latest versions |
| `nix store gc` | Garbage collect unused packages |

## How It Works with Your Existing Config

Your existing `nvim/` directory stays as-is. In `home.nix`:

```nix
home.file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink
  "${config.home.homeDirectory}/misc/dotfiles/nvim";
```

This creates a symlink from `~/.config/nvim` to your repo's `nvim/` folder. You can edit your nvim config directly in the repo, and changes are reflected immediately (no need to run `home-manager switch` for nvim edits).

## Adding More Configs

To add your other configs (ghostty, ohmyposh, tmux), add entries like:

```nix
home.file.".config/ghostty".source = config.lib.file.mkOutOfStoreSymlink
  "${config.home.homeDirectory}/misc/dotfiles/ghostty";

home.file.".config/ohmyposh".source = config.lib.file.mkOutOfStoreSymlink
  "${config.home.homeDirectory}/misc/dotfiles/ohmyposh";

home.file.".config/tmux".source = config.lib.file.mkOutOfStoreSymlink
  "${config.home.homeDirectory}/misc/dotfiles/tmux";
```

## Troubleshooting

### "error: experimental Nix feature 'flakes' is disabled"
Enable flakes: `echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf`

### "error: file 'home-manager' was not found"
You need to use `nix run nixpkgs#home-manager` for the first run.

### Package not found
Check the exact name with `nix search nixpkgs <name>` or search on [search.nixos.org](https://search.nixos.org/packages).

### Changes not applying
Try with `--impure` flag: `home-manager switch --flake . --impure`
