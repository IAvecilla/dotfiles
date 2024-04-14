.PHONE: update

update:
	cp -rf ~/.config/nvim nvim
	cp -rf ~/.config/tmux tmux
	cp -rf ~/.zshrc .

install:	
	brew install asdf
	brew install tmux
	brew install neovim
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	cp -rf nvim ~/.config/nvim
	cp -rf tmux ~/.config/tmux 
	cp -rf .zshrc ~/.zshrc
