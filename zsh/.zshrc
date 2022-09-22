# If you come from bash you might have to change your $PATH.
export PATH=/opt/homebrew/bin:$PATH:$HOME/.deno/bin

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

zstyle ':omz:update' mode reminder  # just remind me to update when it's time

plugins=(
	git
	zsh-autosuggestions
    asdf
)

source $ZSH/oh-my-zsh.sh
if [ -n $SSH_CONNECTION]; then
    export EDITOR='vim'
else
    export EDITOR='nvim'
fi
