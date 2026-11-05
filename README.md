# dotfiles

Cross-platform system configuration managed declaratively with [nix-darwin](https://github.com/LnL7/nix-darwin) (macOS) and [home-manager](https://github.com/nix-community/home-manager) (macOS + Linux).

## What's managed

| Tool | How it's configured |
|------|-------------------|
| **Neovim** | Out-of-store symlink to `nvim/` — edit configs directly, no rebuild needed |
| **tmux** | Out-of-store symlink to `tmux/tmux.conf` — edit directly, no rebuild needed |
| **Git** | Declarative via `programs.git` in `home.nix` |
| **Zsh** | Declarative via `programs.zsh` (oh-my-zsh, autosuggestions, syntax highlighting) |
| **Ghostty** | Declarative via `programs.ghostty` in `home.nix` |
| **Oh My Posh** | Theme loaded from `ohmyposh/zen.toml` via `programs.oh-my-posh` |
| **macOS defaults** | Dock, Finder, trackpad, keyboard settings in `darwin.nix` |
| **Homebrew casks** | Managed via `homebrew.casks` in `darwin.nix` (Ghostty) |

## Prerequisites

- [Nix](https://nixos.org/) with flakes enabled
- **macOS**: Apple Silicon (aarch64-darwin)
- **Linux**: x86_64-linux

## Installation

### macOS (fresh machine)

Prerequisites: user `ignacioavecilla`, enrolled in Kandji/Iru, 1Password installed and signed in.

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/IAvecilla/dotfiles/main/bootstrap.sh)
```

`bootstrap.sh` installs Homebrew (+ Xcode Command Line Tools) and Nix, clones this repo to
`~/misc/dotfiles` and runs the first nix-darwin switch (packages, casks, macOS defaults,
hostname, Claude Code, herdr, TPM). It is safe to re-run. Then:

1. 1Password → Settings → Developer → **Use the SSH agent** (SSH + commit signing).
2. Restore private SSH hosts to `~/.ssh/config.local` (kept out of this public repo).
3. System Settings → Privacy & Security → **App Management** → enable Ghostty.
4. In tmux: `prefix + I` (Ctrl-Space then I) to install plugins.

### Linux

```bash
# install Nix first: https://nixos.org/download
git clone https://github.com/IAvecilla/dotfiles.git ~/dotfiles
make -C ~/dotfiles bootstrap-linux
```

## Daily usage

### Apply changes after editing nix files

```bash
# macOS
make darwin

# Linux
make linux
```

### Edit symlinked configs directly

Neovim and tmux configs are symlinked out-of-store — changes take effect immediately without a rebuild:

```bash
nvim ~/misc/dotfiles/nvim/init.lua       # neovim config
nvim ~/misc/dotfiles/tmux/tmux.conf      # tmux config
```

### Add a package

Edit `home.nix` and add to `home.packages`:

```nix
home.packages = with pkgs; [
  curl
  wget
  htop  # new package
];
```

Then rebuild: `make darwin` or `make linux`

### Search for packages

```bash
nix search nixpkgs <name>
```

### Update flake inputs

```bash
make update
make darwin  # or: make linux
```

### Rollback

```bash
# macOS
make rollback-darwin

# Linux
make rollback-linux

# List past generations
make generations
```

### Garbage collect

```bash
make gc
```

## Repository structure

```
dotfiles/
├── Makefile               # Build/switch/rollback commands for both platforms
├── home_manager/
│   ├── flake.nix          # Entry point — inputs, system arch, username
│   ├── flake.lock         # Pinned dependency versions
│   ├── darwin.nix         # macOS system settings (dock, finder, keyboard, homebrew)
│   ├── linux.nix          # Linux settings (nixGL, Wayland tools)
│   └── home.nix           # Shared user config (packages, git, zsh, ghostty, oh-my-posh)
├── nvim/                  # Neovim config (symlinked to ~/.config/nvim)
│   ├── init.lua
│   └── lua/user/
│       ├── colorscheme.lua
│       ├── keymaps.lua
│       ├── options.lua
│       └── plugins.lua
├── tmux/
│   └── tmux.conf          # tmux config (symlinked to ~/.config/tmux/tmux.conf)
└── ohmyposh/
    └── zen.toml           # Oh My Posh prompt theme
```

## Architecture

```
flake.nix
├── nix-darwin (darwin.nix)                    [macOS only]
│   ├── macOS system defaults (dock, finder, trackpad, keyboard)
│   ├── Homebrew casks (ghostty)
│   ├── Touch ID sudo
│   └── System packages
└── home-manager (home.nix)                    [shared]
    ├── User packages (curl, wget, rustup)
    ├── programs.neovim   ──symlink──▶  nvim/
    ├── programs.git      ──generates──▶  ~/.config/git/config
    ├── programs.zsh      ──generates──▶  ~/.zshrc
    ├── programs.ghostty  ──generates──▶  ~/.config/ghostty/config
    ├── programs.oh-my-posh (theme from ohmyposh/zen.toml)
    ├── home.file         ──symlink──▶  tmux/tmux.conf
    └── linux.nix                              [Linux only]
        ├── Ghostty wrapped with nixGL
        └── Wayland tools (fuzzel, mako, grim, slurp, etc.)
```

## Customization

To adapt this for a different machine:

1. In `flake.nix`, update:
   - `darwinSystem` / `linuxSystem` — architecture
   - `darwinUsername` / `linuxUsername` — your username
   - `darwinHostname` — run `hostname` to check yours (macOS)
   - `darwinDotfilesDir` / `linuxDotfilesDir` — repo location

2. In `home.nix`, update:
   - `userName` / `userEmail` in `programs.git`

3. Rebuild: `make darwin` or `make linux`

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `experimental Nix feature 'flakes' is disabled` | Run: `echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf` |
| `file 'darwin' was not found` | Use `make bootstrap-darwin` for first install |
| Package not found | Search with `nix search nixpkgs <name>` or check [search.nixos.org](https://search.nixos.org/packages) |
| Changes not applying | Try `make darwin` or add `--impure` flag |
| Symlink conflict | Remove the existing file first: `rm ~/.config/<path>`, then rebuild |
| tmux plugins not loading | Install TPM: `git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`, then press `prefix + I` |
