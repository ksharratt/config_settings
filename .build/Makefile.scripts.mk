SCRIPTS_DIR := $(HOME)/.scripts
SOURCE_DIR := ./scripts

# Default target
.PHONY: install_scripts
install_scripts: $(SCRIPTS_DIR)
	@echo "Copying new scripts into $(SCRIPTS_DIR)..."
	@for f in $(SOURCE_DIR)/*; do \
		dst="$(SCRIPTS_DIR)/$${f##*/}"; \
		if [ ! -e "$$dst" ]; then \
			echo "  -> Installing $$f"; \
			cp "$$f" "$(SCRIPTS_DIR)/"; \
		else \
			echo "  -> Skipping $$f (already exists)"; \
		fi; \
	done
	@echo "Done."

# Create ~/.scripts if missing
$(SCRIPTS_DIR):
	@echo "Creating $(SCRIPTS_DIR)..."
	@mkdir -p $(SCRIPTS_DIR)

