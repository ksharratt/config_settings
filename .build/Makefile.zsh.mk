# Makefile.zsh — zsh config management

INSTALL_DIR        := $(HOME)
ZSH_SOURCE_DIR     := ./files

.PHONY: install_custom_shell_commands

install_custom_shell_commands:
	@mkdir -p $(INSTALL_DIR)
	@for f in $(ZSH_SOURCE_DIR)/.custom_shell_commands*; do \
		[ -f "$$f" ] || continue; \
		case "$$f" in \
			*.bak|*~|*.swp) continue ;; \
		esac; \
		cp -f "$$f" $(INSTALL_DIR)/ && echo "Installed $$(basename $$f)"; \
	done; \
	true

check_powerlevel10k:
	@command p10k --version >/dev/null 2>&1 || \
	( echo "Installing powerlevel10k for zsh..."; \
	git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" )



.PHONY: install_custom_shell_commands check_powerlevel10k
