# Makefile to install Glow (terminal Markdown renderer) if not present
# - Fetches the latest release from GitHub
# - Supports Linux x86_64 and arm64
# - Installs to /usr/local/bin by default

# ===== Config =====
PREFIX      ?= /usr/local
BINDIR      ?= $(PREFIX)/bin
SUDO        ?= sudo

# Detect arch → map to Glow’s release naming
UNAME_M := $(shell uname -m)
ifeq ($(UNAME_M),x86_64)
  GLOW_RELEASE_ARCH := Linux_x86_64
else ifeq ($(UNAME_M),aarch64)
  GLOW_RELEASE_ARCH := Linux_arm64
else
  # Fallback (adjust if you need other architectures)
  GLOW_RELEASE_ARCH := Linux_x86_64
endif

# Query latest version tag from GitHub (no jq needed)
GLOW_VERSION := $(shell curl -s https://api.github.com/repos/charmbracelet/glow/releases/latest | grep -Po '"tag_name": "v\K[0-9.]+' )

TARFILE  := glow.tar.gz
TMPDIR   := glow-temp
URL      := https://github.com/charmbracelet/glow/releases/download/v$(GLOW_VERSION)/glow_$(GLOW_VERSION)_$(GLOW_RELEASE_ARCH).tar.gz

.PHONY: install install-glow uninstall-glow verify-glow clean-glow help-glow

# Default target: install if missing
install: install-glow

help-glow:
	@echo "Targets:"
	@echo "  install-glow        Install Glow if not already installed (default)"
	@echo "  uninstall-glow      Remove $(BINDIR)/glow"
	@echo "  verify-glow         Print installed Glow version"
	@echo "  clean-glow          Remove download/extract artifacts"
	@echo ""
	@echo "Variables (override with make VAR=value):"
	@echo "  PREFIX=$(PREFIX)"
	@echo "  BINDIR=$(BINDIR)"
	@echo "  SUDO=$(SUDO)"

# Idempotent installer: only installs if 'glow' isn't found
install-glow: _precheck
	@if command -v glow >/dev/null 2>&1; then \
	  echo "glow already installed: $$(glow --version)"; \
	else \
	  $(MAKE) _install_glow; \
	fi

# Verify required tools exist
_precheck:
	@for t in curl wget tar; do \
	  if ! command -v $$t >/dev/null 2>&1; then \
	    echo "Missing dependency: $$t" >&2; exit 1; \
	  fi; \
	done

# Full install pipeline
_install_glow: _download _extract _move verify-glow clean-glow

_download:
	@echo "→ Downloading Glow v$(GLOW_VERSION) for $(GLOW_RELEASE_ARCH)…"
	@wget -qO "$(TARFILE)" "$(URL)"

_extract:
	@echo "→ Extracting archive…"
	@mkdir -p "$(TMPDIR)"
	@tar xf "$(TARFILE)" --strip-components=1 -C "$(TMPDIR)"

_move:
	@echo "→ Installing to $(BINDIR)…"
	@sh -c 'if [ -w "$(BINDIR)" ]; then S=""; else S="$(SUDO)"; fi; \
	        $$S mkdir -p "$(BINDIR)"; \
	        $$S mv "$(TMPDIR)/glow" "$(BINDIR)/glow"; \
	        $$S chmod 0755 "$(BINDIR)/glow"'

verify-glow:
	@echo -n "✓ Installed: "
	@glow --version

uninstall-glow:
	@if command -v glow >/dev/null 2>&1; then \
	  echo "→ Removing $(BINDIR)/glow"; \
	  sh -c 'if [ -w "$(BINDIR)" ]; then S=""; else S="$(SUDO)"; fi; $$S rm -f "$(BINDIR)/glow"'; \
	else \
	  echo "glow is not installed"; \
	fi

clean-glow:
	@rm -rf "$(TARFILE)" "$(TMPDIR)"

