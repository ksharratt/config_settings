.PHONY: check_powerline_uv install_powerline install_powerline_bashrc install_powerline_tmux reload_powerline_tmux

POWERLINE_VENV := $(CURDIR)/.venv
POWERLINE_BASHRC := $(HOME)/.bashrc
POWERLINE_TMUX_CONF := $(HOME)/.tmux.conf

check_powerline_uv:
	@command -v uv >/dev/null 2>&1 || { echo "ERROR: uv not found in PATH"; exit 1; }

$(POWERLINE_VENV)/bin/python:
	@echo "Creating Python venv: $(POWERLINE_VENV)"
	@uv venv "$(POWERLINE_VENV)"

install_powerline: check_powerline_uv $(POWERLINE_VENV)/bin/python
	@echo "Installing powerline-status with uv"
	@uv pip install --python "$(POWERLINE_VENV)/bin/python" powerline-status
	@test -x "$(POWERLINE_VENV)/bin/powerline-config" || { echo "ERROR: powerline-config missing"; exit 1; }
	@echo "Powerline installed OK"

install_powerline_bashrc: install_powerline
	@echo "Updating $(POWERLINE_BASHRC)"
	@touch "$(POWERLINE_BASHRC)"
	@awk '/# BEGIN CONFIG_SETTINGS_POWERLINE/{skip=1} /# END CONFIG_SETTINGS_POWERLINE/{skip=0; next} !skip{print}' "$(POWERLINE_BASHRC)" > "$(POWERLINE_BASHRC).tmp"
	@cat >> "$(POWERLINE_BASHRC).tmp" <<'EOF'

# BEGIN CONFIG_SETTINGS_POWERLINE
export POWERLINE_VENV="$(POWERLINE_VENV)"
export PATH="$$POWERLINE_VENV/bin:$$PATH"
export POWERLINE_CONFIG_COMMAND="$$POWERLINE_VENV/bin/powerline-config"
export POWERLINE_BASH_CONTINUATION=1
export POWERLINE_BASH_SELECT=1

POWERLINE_BASH_BINDING="$$( "$$POWERLINE_VENV/bin/python" -c 'import pathlib, powerline; print(pathlib.Path(powerline.__file__).parent / "bindings/bash/powerline.sh")' 2>/dev/null )"

if [ -n "$$POWERLINE_BASH_BINDING" ] && [ -f "$$POWERLINE_BASH_BINDING" ]; then
    "$$POWERLINE_VENV/bin/powerline-daemon" -q 2>/dev/null || true
    source "$$POWERLINE_BASH_BINDING"
fi
# END CONFIG_SETTINGS_POWERLINE
EOF
	@mv "$(POWERLINE_BASHRC).tmp" "$(POWERLINE_BASHRC)"
	@echo "Updated Bash Powerline config"

install_powerline_tmux: install_powerline
	@echo "Updating $(POWERLINE_TMUX_CONF)"
	@touch "$(POWERLINE_TMUX_CONF)"
	@awk '/# BEGIN CONFIG_SETTINGS_POWERLINE_TMUX/{skip=1} /# END CONFIG_SETTINGS_POWERLINE_TMUX/{skip=0; next} !skip{print}' "$(POWERLINE_TMUX_CONF)" > "$(POWERLINE_TMUX_CONF).tmp"
	@cat >> "$(POWERLINE_TMUX_CONF).tmp" <<'EOF'

# BEGIN CONFIG_SETTINGS_POWERLINE_TMUX
set -g status on
run-shell -b "$(POWERLINE_VENV)/bin/powerline-daemon -q"
run-shell -b "$(POWERLINE_VENV)/bin/powerline-config tmux setup"
# END CONFIG_SETTINGS_POWERLINE_TMUX
EOF
	@mv "$(POWERLINE_TMUX_CONF).tmp" "$(POWERLINE_TMUX_CONF)"
	@echo "Updated tmux Powerline config"

reload_powerline_tmux: install_powerline_tmux
	@if [ -n "$$TMUX" ]; then \
		echo "Reloading tmux config"; \
		tmux source-file "$(POWERLINE_TMUX_CONF)"; \
		"$(POWERLINE_VENV)/bin/powerline-config" tmux setup; \
	else \
		echo "Not inside tmux; start or attach tmux to see the updated status line"; \
	fi
