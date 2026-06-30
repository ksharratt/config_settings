# Makefile - tmux helpers
TMUX_CBC_DIR    := $(HOME)/repos//home/d655605/repos/cbc-manage-instances
TMUX_CONFIG_DIR := $(HOME)/repos/config_settings
TMUX_DOCS_DIR   := $(HOME)/repos/config_settings/files/docs
TMUX_CONF_SRC := ./files/.tmux.conf
TMUX_CONF_DST := $(HOME)/.tmux.conf
TPM_DIR       := $(HOME)/.tmux/plugins/tpm

.PHONY: install_tmux check_tmux start_tmux config_tmux install_tpm

install_tpm:
	@if [ ! -d $(TPM_DIR) ]; then \
		git clone https://github.com/tmux-plugins/tpm $(TPM_DIR); \
	else \
		echo "TPM already installed"; \
	fi

config_tmux: install_tpm
	@mkdir -p $(HOME)/tmux-logs
	@cp -f $(TMUX_CONF_SRC) $(TMUX_CONF_DST)
	@tmux start-server
	@tmux source-file $(TMUX_CONF_DST)
	@$(TPM_DIR)/bin/install_plugins
	@echo "tmux config + plugins applied"

install_tmux: config_tmux
	@sudo apt-get install -y tmux

check_tmux:
	@tmux -V || echo "tmux not installed"


start_tmux:
	@tmux has-session -t cbc    2>/dev/null || tmux new-session -d -s cbc    -c $(TMUX_CBC_DIR)
	@tmux has-session -t config 2>/dev/null || tmux new-session -d -s config -c $(TMUX_CONFIG_DIR)
	@tmux has-session -t docs   2>/dev/null || tmux new-session -d -s docs   -c $(TMUX_DOCS_DIR)
	@echo "Sessions ready:"
	@tmux ls
	@tmux attach -t cbc
