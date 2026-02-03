# Makefile.zsh — zsh config management

INSTALL_DIR := $(HOME)/
SOURCE_FILE := ./files/.custom_shell_commands

zsh: install_custom_shell_commands

install_custom_shell_commands:
	mkdir -p $(INSTALL_DIR)
	cp -f $(SOURCE_FILE) $(INSTALL_DIR)/


check_powerlevel10k:
	@command p10k --version >/dev/null 2>&1 || \
	( echo "Installing powerlevel10k for zsh..."; \
	git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" )



.PHONY: install_custom_shell_commands check_powerlevel10k

