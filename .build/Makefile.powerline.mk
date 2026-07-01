.PHONY: check_powerline_uv install_powerline install_powerline_config \
        install_powerline_bashrc install_powerline_tmux reload_powerline_tmux

POWERLINE_BASHRC     := $(HOME)/.bashrc
POWERLINE_VENV       := $(CURDIR)/.venv
POWERLINE_TMUX_CONF  := $(HOME)/.tmux.conf
POWERLINE_CONFIG_DIR := $(HOME)/.config/powerline

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

# ---- Seed user config + custom segment ----
install_powerline_config: install_powerline
	@echo "Seeding $(POWERLINE_CONFIG_DIR)"
	@mkdir -p "$(POWERLINE_CONFIG_DIR)/themes/shell" "$(POWERLINE_CONFIG_DIR)/segments"
	@SRC=$$("$(POWERLINE_VENV)/bin/python" -c 'import powerline, os; print(os.path.join(os.path.dirname(powerline.__file__), "config_files"))'); \
	 cp -rn "$$SRC"/. "$(POWERLINE_CONFIG_DIR)/"
	@echo "Writing custom short_branch segment"
	@printf '%s\n' \
	'from powerline.segments.common.vcs import branch' \
	'' \
	'def short_branch(pl, segment_info, max_length=18, **kwargs):' \
	'    segs = branch(pl, segment_info=segment_info, **kwargs)' \
	'    if not segs:' \
	'        return segs' \
	'    for s in segs:' \
	'        name = s.get("contents", "")' \
	'        if len(name) > max_length:' \
	'            s["contents"] = name[:max_length - 1] + "…"' \
	'    return segs' \
	> "$(POWERLINE_CONFIG_DIR)/segments/custom.py"
	@echo "Writing shell theme"
	@printf '%s\n' \
	'{' \
	'  "segments": {' \
	'    "left": [' \
	'      {' \
	'        "function": "powerline.segments.common.env.cwd",' \
	'        "args": { "dir_shorten_len": 1, "dir_limit_depth": 1 }' \
	'      },' \
	'      {' \
	'        "function": "custom.short_branch",' \
	'        "args": { "status_colors": true, "max_length": 18 }' \
	'      }' \
	'    ]' \
	'  }' \
	'}' \
	> "$(POWERLINE_CONFIG_DIR)/themes/shell/default.json"
	@echo "Powerline user config ready"

install_powerline_bashrc: install_powerline_config
	@echo "Updating $(POWERLINE_BASHRC)"
	@touch "$(POWERLINE_BASHRC)"
	@awk '/# BEGIN CONFIG_SETTINGS_POWERLINE/{skip=1} /# END CONFIG_SETTINGS_POWERLINE/{skip=0; next} !skip{print}' "$(POWERLINE_BASHRC)" > "$(POWERLINE_BASHRC).tmp"
	@printf '%s\n' \
	'' \
	'# BEGIN CONFIG_SETTINGS_POWERLINE' \
	'export POWERLINE_VENV="$(POWERLINE_VENV)"' \
	'export PATH="$$POWERLINE_VENV/bin:$$PATH"' \
	'export POWERLINE_CONFIG_COMMAND="$$POWERLINE_VENV/bin/powerline-config"' \
	'export POWERLINE_CONFIG_PATHS="$(POWERLINE_CONFIG_DIR)"' \
	'export PYTHONPATH="$(POWERLINE_CONFIG_DIR):$$PYTHONPATH"' \
	'export POWERLINE_BASH_CONTINUATION=1' \
	'export POWERLINE_BASH_SELECT=1' \
	'' \
	'POWERLINE_BASH_BINDING="$$( "$$POWERLINE_VENV/bin/python" -c '\''import pathlib, powerline; print(pathlib.Path(powerline.__file__).parent / "bindings/bash/powerline.sh")'\'' 2>/dev/null )"' \
	'' \
	'if [ -n "$$POWERLINE_BASH_BINDING" ] && [ -f "$$POWERLINE_BASH_BINDING" ]; then' \
	'    "$$POWERLINE_VENV/bin/powerline-daemon" -q 2>/dev/null || true' \
	'    source "$$POWERLINE_BASH_BINDING"' \
	'fi' \
	'# END CONFIG_SETTINGS_POWERLINE' \
	>> "$(POWERLINE_BASHRC).tmp"
	@mv "$(POWERLINE_BASHRC).tmp" "$(POWERLINE_BASHRC)"
	@echo "Updated Bash Powerline config"

install_powerline_tmux: install_powerline_config
	@echo "Updating $(POWERLINE_TMUX_CONF)"
	@touch "$(POWERLINE_TMUX_CONF)"
	@awk '/# BEGIN CONFIG_SETTINGS_POWERLINE_TMUX/{skip=1} /# END CONFIG_SETTINGS_POWERLINE_TMUX/{skip=0; next} !skip{print}' "$(POWERLINE_TMUX_CONF)" > "$(POWERLINE_TMUX_CONF).tmp"
	@printf '%s\n' \
	'' \
	'# BEGIN CONFIG_SETTINGS_POWERLINE_TMUX' \
	'set -g status on' \
	'set -g status-position bottom' \
	'set -g status-interval 2' \
	'set -gu status-format' \
	'setenv -g POWERLINE_CONFIG_PATHS "$(POWERLINE_CONFIG_DIR)"' \
	'setenv -g PYTHONPATH "$(POWERLINE_CONFIG_DIR)"' \
	'' \
	'run-shell -b "$(POWERLINE_VENV)/bin/powerline-daemon -q"' \
	'run-shell -b "$(POWERLINE_VENV)/bin/powerline tmux"' \
	'# END CONFIG_SETTINGS_POWERLINE_TMUX' \
	>> "$(POWERLINE_TMUX_CONF).tmp"
	@mv "$(POWERLINE_TMUX_CONF).tmp" "$(POWERLINE_TMUX_CONF)"
	@echo "Updated tmux Powerline config"

reload_powerline_tmux: install_powerline_tmux
	@if [ -n "$$TMUX" ]; then \
		echo "Reloading tmux config"; \
		tmux source-file "$(POWERLINE_TMUX_CONF)"; \
		tmux set-option -gu status-format; \
		tmux set-option -g status on; \
		tmux run-shell -b "$(POWERLINE_VENV)/bin/powerline-daemon -q"; \
		tmux run-shell -b "$(POWERLINE_VENV)/bin/powerline tmux"; \
	else \
		echo "Not inside tmux; start or attach tmux to see the updated status line"; \
	fi
