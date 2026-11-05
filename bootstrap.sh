#!/usr/bin/env bash
# Fresh-Mac setup: Homebrew, Nix, this repo and the first nix-darwin switch.
# Safe to re-run; every step is skipped when already done.
#
#   bash <(curl -fsSL https://raw.githubusercontent.com/IAvecilla/dotfiles/main/bootstrap.sh)
set -euo pipefail

HOST="Ignacios-MacBook-Pro-2"
USERNAME="ignacioavecilla"
DIR="$HOME/misc/dotfiles"
REPO_HTTPS="https://github.com/IAvecilla/dotfiles.git"
REPO_SSH="git@github.com:IAvecilla/dotfiles.git"

step() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }

[ "$(uname -s)" = "Darwin" ] || { echo "This script is for macOS."; exit 1; }
if [ "$(whoami)" != "$USERNAME" ]; then
  echo "The flake expects the user '$USERNAME' (you are '$(whoami)')."
  echo "Edit darwinUsername in home_manager/flake.nix or create that user."
  exit 1
fi

step "Caching sudo credentials"
sudo -v
# keep sudo alive until the script exits
while true; do sudo -n true; sleep 50; kill -0 "$$" || exit; done 2>/dev/null &

step "Homebrew (also installs the Xcode Command Line Tools)"
if [ ! -x /opt/homebrew/bin/brew ]; then
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "already installed"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

step "Nix"
if [ ! -e /nix/var/nix/profiles/default/bin/nix ]; then
  sh <(curl -fsSL https://nixos.org/nix/install) --daemon --yes
else
  echo "already installed"
fi
# shellcheck disable=SC1091
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

step "Dotfiles repo"
if [ ! -d "$DIR/.git" ]; then
  mkdir -p "$(dirname "$DIR")"
  # HTTPS: SSH keys (1Password agent) may not be set up yet
  git clone "$REPO_HTTPS" "$DIR"
else
  echo "already cloned at $DIR"
fi

step "nix-darwin switch"
# The Nix installer edits these; nix-darwin refuses to overwrite unknown files.
for f in /etc/bashrc /etc/zshrc /etc/zshenv; do
  if [ -f "$f" ] && [ ! -L "$f" ]; then
    sudo mv "$f" "$f.before-nix-darwin"
  fi
done
cd "$DIR/home_manager"
if command -v darwin-rebuild >/dev/null 2>&1; then
  sudo -H darwin-rebuild switch --flake ".#$HOST"
else
  sudo -H nix --extra-experimental-features 'nix-command flakes' \
    run nix-darwin -- switch --flake ".#$HOST"
fi

git -C "$DIR" remote set-url origin "$REPO_SSH"

cat <<'EOF'

Done. Remaining manual steps:
  1. Open a new terminal.
  2. 1Password -> Settings -> Developer -> "Use the SSH agent".
  3. Restore your private hosts to ~/.ssh/config.local.
  4. System Settings -> Privacy & Security -> App Management -> enable Ghostty.
  5. In tmux: prefix + I to install plugins.
From now on: make -C ~/misc/dotfiles darwin
EOF
