# Makefile to copy cheats files to ~/.config/cheats

CHEATS_SRC := ./files/cheats
CHEATS_DEST := $(HOME)/.config/cheats

install-cheats:
	mkdir -p $(CHEATS_DEST)
	cp -r $(CHEATS_SRC)/* $(CHEATS_DEST)/
	@echo "Cheatsheet installed."

