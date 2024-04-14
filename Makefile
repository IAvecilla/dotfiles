.PHONE: update

update:
	cp -rf ~/.config/nvim nvim
	cp -rf ~/.config/tmux tmux
	cp -rf ~/.zshrc .

zsh:
	cp -rf .zshrc ~/.zhsrc
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

install:	
	brew install asdf
	brew install tmux
	brew install neovim
	cp -rf nvim ~/.config/nvim
	cp -rf tmux ~/.config/tmux 
