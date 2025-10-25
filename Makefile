# Makefile — setup a uv-managed environment in the repo root
# Usage:
#   make init                     # Default: installs Python 3.12 and Ansible
#   make init PYTHON_VERSION=3.11 # Choose Python version
#   make init PKGS="ansible pytest black"  # Add more packages

SHELL := /bin/bash

PYTHON_VERSION ?= 3.12
PKGS ?= ansible

.PHONY: init check_uv ensure_python venv install show-test

init: check_uv ensure_python venv install show-test
	@echo "✅ Environment ready with Python $(PYTHON_VERSION)."

check_uv:
	@command -v uv >/dev/null 2>&1 || { \
		echo "⚙️  uv not found — installing..."; \
		curl -LsSf https://astral.sh/uv/install.sh | sh; \
	}
	@echo "✅ uv is installed."

ensure_python:
	@echo "🔎 Ensuring Python $(PYTHON_VERSION) is available via uv..."
	@uv python install $(PYTHON_VERSION) >/dev/null
	@echo "✅ Python $(PYTHON_VERSION) available."

venv:
	@echo "📦 Creating or updating local .venv..."
	@uv venv --python $(PYTHON_VERSION) --seed
	@echo "✅ .venv ready."

install:
	@echo "📥 Installing packages into .venv: $(PKGS)"
	@uv pip install $(PKGS)
	@echo "✅ Packages installed."

show-test:
	@echo
	@echo "🚀 Running test command via uv:"
	@uv run python --version
	@echo "To run Ansible, use:"
	@echo "  uv run ansible --version"
	@echo

