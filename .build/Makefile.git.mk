DST_HOOKS_DIR := $(HOME)/.config/git/hooks
SRC_HOOKS_DIR := files/git/hooks

.PHONY: git git-config

git: git-config git-alias git-hooks

git-config:
	@if [ "$(shell git config --get push.autoSetupRemote)" != "true" ]; then \
		echo "Setting push.autoSetupRemote to true..."; \
		git config --global push.autoSetupRemote true; \
	else \
		echo "push.autoSetupRemote is already set to true."; \
	fi

	@if [ "$(shell git config --get --global core.autocrlf input)" != "input" ]; then \
		echo "Enabling new line normalisation to \\n..."; \
		git config --global core.autocrlf input; \
	else \
		echo "global core.autocrlf input is already enabled."; \
	fi
	
	@# Ensure core.excludesfile points to ~/.gitignore_global
	@if [ "$$(git config --global --get core.excludesfile)" != "$$HOME/.gitignore_global" ]; then \
	echo "Configuring core.excludesfile -> $$HOME/.gitignore_global ..."; \
		git config --global core.excludesfile "$$HOME/.gitignore_global"; \
	else \
		echo "core.excludesfile already points to $$HOME/.gitignore_global."; \
	fi

	@# Copy repo version to ~/ if ~/ does not exist OR is different
	@if [ -f files/git/.gitignore_global ]; then \
		if [ ! -f $$HOME/.gitignore_global ]; then \
			echo "Global ignore file missing. Creating $$HOME/.gitignore_global ..."; \
			cp files/git/.gitignore_global $$HOME/.gitignore_global; \
		elif ! diff -q files/git/.gitignore_global $$HOME/.gitignore_global >/dev/null 2>&1; then \
			echo "Updating $$HOME/.gitignore_global from repository version..."; \
			cp files/git/.gitignore_global $$HOME/.gitignore_global; \
		else \
			echo "$$HOME/.gitignore_global is already up-to-date."; \
		fi; \
	else \
		echo "No files/git/.gitignore_global found in this repo — skipping copy."; \
	fi

git-hooks:
	@# Add global git hooks path
	@if [ "$$(git config --global --get core.hookspath)" != "$(DST_HOOKS_DIR)" ]; then \
	echo "Configuring core.hookspath -> $(DST_HOOKS_DIR) ..."; \
		git config --global core.hookspath $(DST_HOOKS_DIR); \
	else \
		echo "core.hookspath already points to $(DST_HOOKS_DIR)"; \
	fi

	@echo "Copying hooks into $(DST_HOOKS_DIR)..."
	@mkdir -p "$(DST_HOOKS_DIR)"
	@for f in $(SRC_HOOKS_DIR)/*; do \
  		[ -f "$$f" ] || continue; \
		dst="$(DST_HOOKS_DIR)/$${f##*/}"; \
		\
		if [ ! -e "$$dst" ]; then \
			echo "  -> Installing $${f##*/}"; \
			install -m 0755 "$$f" "$$dst"; \
		elif ! cmp -s "$$f" "$$dst"; then \
			echo "  -> Updating  $${f##*/} (changed)"; \
			install -m 0755 "$$f" "$$dst"; \
		else \
			echo "  -> Skipping  $${f##*/} (unchanged)"; \
		fi; \
	done

	@# 2) Copy/update lib/ recursively (if it exists)
	@if [ -d "$(SRC_HOOKS_DIR)/lib" ]; then \
        echo "  -> Syncing   lib/"; \
        mkdir -p "$(DST_HOOKS_DIR)/lib"; \
        ( cd "$(SRC_HOOKS_DIR)" && tar cf - lib ) | ( cd "$(DST_HOOKS_DIR)" && tar xf - ); \
        find "$(DST_HOOKS_DIR)/lib" -type f -name '*.sh' -exec chmod 0755 {} \; ; \
    else \
        echo "  -> No lib/ directory found, skipping"; \
    fi

	@echo "Done."




git-alias:
	@git config --global alias.squash-clean '!f() { \
	  if [ -z "$$1" ]; then echo "Usage: git squash-clean \"commit message\""; exit 1; fi; \
	  git fetch origin && \
	  git reset $$(git merge-base HEAD origin/master) && \
	  git add -A && \
	  git commit -m "$$1" && \
	  git rebase origin/master && \
	  git log --oneline --graph --decorate -n 10; \
	}; f'

	@# Add 'lg' alias: compact graph view (no implicit -n to allow custom limits)
	@if [ "$$(git config --global --get alias.lg)" != "log --oneline --graph --decorate -n 15" ]; then \
		echo "Adding alias lg -> 'log --oneline --graph --decorate -n 15'..."; \
		git config --global alias.lg "log --oneline --graph --decorate -n 15"; \
	else \
		echo "alias lg already set."; \
	fi

	@# Optional: 'lgs' shows stats too
	@if [ "$$(git config --global --get alias.lgs)" != "log --oneline --graph --decorate -n 10 --stat" ]; then \
		echo "Adding alias lgs -> 'log --oneline --graph --decorate -n 10 --stat'..."; \
			git config --global alias.lgs "log --oneline --graph --decorate -n 10 --stat"; \
	else \
		echo "alias lgs already set."; \
	fi

# these setting should only be used in a personal build not a work environment build
# create a branch of make commands for personal would make the most sense here.
#
# user.email=keith.sharratt@gmail.com
# user.name=Keith Sharratt
#
# This will work with Git for windows installation for git credential manager
# credential.helper=/mnt/c/Program\ Files/Git/mingw64/libexec/git-core/git-credential-wincred.exe
