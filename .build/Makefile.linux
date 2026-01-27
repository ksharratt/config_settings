
.PHONY: sys-tools


sys-tools: apt-update install-bat install-ansifilter install-neovim install-fzf 

apt-update:
	@sudo apt-get update

bat-symlink:
	@echo "Creating bat → batcat symlink..."
	@mkdir -p ~/.local/bin
	@if [ ! -e ~/.local/bin/bat ]; then \
		ln -s /usr/bin/batcat ~/.local/bin/bat; \
		echo "Symlink created: ~/.local/bin/bat → /usr/bin/batcat"; \
	else \
		echo "Symlink already exists, skipping."; \
	fi


install-bat:
	@sudo apt-get install -y bat
	make bat-symlink

install-ansifilter:
	@sudo apt-get install -y ansifilter

install-neovim:
	@sudo apt-get install -y neovim

install-fzf:
	@command -v fzf >/dev/null 2>&1 || { \
		echo "Installing fzf ...."; \
		git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf; \
		~/.fzf/install; \
		source ~/.zshrc; \
		}
	@echo "✅ fzf is installed."
