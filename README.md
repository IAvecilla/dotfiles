# dotfiles

Config files for the tools that I use, managed with [Nix](https://nixos.org/), [Home Manager](https://github.com/nix-community/home-manager), and [nix-darwin](https://github.com/LnL7/nix-darwin) (macOS).

Supports **macOS** (aarch64-darwin) and **Linux** (x86_64-linux).

## What Home Manager installs and configures

### Packages (both platforms)

- `curl`, `wget`
- `rustup` (Rust toolchain manager)
- `docker`

### Programs

| Program | What it configures |
|---|---|
| **Neovim** | Default editor, `vi`/`vim` aliases. Config symlinked from `nvim/` |
| **Git** | User, default branch, auto-setup remote |
| **Zsh** | oh-my-zsh (git plugin), autocompletion, syntax highlighting |
| **Oh My Posh** | Zen prompt theme (from `ohmyposh/zen.toml`) |
| **Ghostty** | Font size, cursor, theme, keybinds. Binary installed separately per-platform |

### macOS-only (nix-darwin)

- **Dock**: autohide, no recents, hot corners disabled
- **Finder**: show extensions, show path bar
- **Keyboard**: fast key repeat, press-and-hold disabled
- **Trackpad**: tap to click, two-finger right-click
- **Touch ID**: enabled for sudo
- **Homebrew**: installs Ghostty cask

### Linux-only

- **Niri**: scrollable tiling Wayland compositor with vim-style keybindings
- **Wayland tools**: fuzzel, swaybg, swaylock, mako, wl-clipboard, grim, slurp, xwayland-satellite
- **nixGL**: wraps Ghostty and Niri for GPU compatibility on non-NixOS

## Neovim setup

Plugins are managed by **Packer** (auto-bootstraps on first launch).

### Plugins

- **nvim-treesitter** — syntax highlighting (lua, rust, toml parsers)
- **nvim-tree** — file explorer
- **telescope** — fuzzy finder
- **nvim-cmp** — completion engine (LSP, buffer, path, snippets)
- **mason** — LSP/tool installer
- **nvim-autopairs** — auto-closing brackets
- **vim-floaterm** — floating terminal
- **vim-tmux-navigator** — seamless vim/tmux split navigation
- **markdown-preview** — live markdown preview
- **catppuccin** — colorscheme (default)

### LSP

- **rust-analyzer** configured via native `vim.lsp.config` (Neovim 0.11+)

## Setup

### Prerequisites

- [Nix](https://nixos.org/download/) with flakes enabled

### macOS

```sh
# First time
make bootstrap-darwin

# After that
make darwin
```

### Linux

```sh
# First time
make bootstrap-linux

# After that
make linux
```

### Post-install (manual steps)

1. **Open Neovim** — Packer will auto-bootstrap and install plugins. Close and reopen Neovim, then run:
   ```
   :PackerSync
   ```

2. **Rust toolchain** — install rust-analyzer for LSP support:
   ```sh
   rustup component add rust-analyzer
   rustup component add rust-src
   ```

3. **Tree-sitter CLI** — needed for building treesitter parsers:
   ```sh
   cargo install tree-sitter-cli
   ```

4. **C compiler** — required by treesitter to compile parsers (`gcc` or `clang`)

5. **Linux: Niri session** — register Niri as a GDM login option (one-time):
   ```sh
   make setup-niri
   ```

## Make targets

| Command | Description |
|---|---|
| `make linux` | Apply home-manager config (Linux) |
| `make darwin` | Apply nix-darwin + home-manager config (macOS) |
| `make bootstrap-linux` | First-time setup (Linux) |
| `make bootstrap-darwin` | First-time setup (macOS) |
| `make update` | Update all flake inputs |
| `make build-linux` | Dry-run build (Linux) |
| `make build-darwin` | Dry-run build (macOS) |
| `make rollback` | Revert to previous generation |
| `make generations` | List past generations |
| `make gc` | Garbage collect Nix store |
| `make setup-niri` | Install Niri as GDM session (Linux, requires sudo) |
