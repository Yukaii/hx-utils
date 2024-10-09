# Makefile for hx-utils

# Default installation directory
INSTALL_DIR := $(HOME)/.local/bin

# Targets
.PHONY: all install uninstall update clean help

all: install

install:
	@echo "Installing hx-utils..."

	@mkdir -p $(INSTALL_DIR)/hx-utils-bin
	@cp scripts/* $(INSTALL_DIR)/hx-utils-bin

	@mkdir -p $(INSTALL_DIR)/hx-utils-modules
	@cp modules/*.sh $(INSTALL_DIR)/hx-utils-modules/
	# setup binaries
	@chmod +x $(INSTALL_DIR)/hx-utils-bin/*
	@echo "Installation complete. Please add $(INSTALL_DIR)/hx-utils-bin to your PATH if it's not already there."

uninstall:
	@echo "Uninstalling hx-utils..."
	@rm -rf $(INSTALL_DIR)/hx-utils-modules
	@rm -rf $(INSTALL_DIR)/hx-utils-bin
	@echo "Uninstallation complete."

update: uninstall install
	@echo "hx-utils has been updated."

clean:
	@echo "Cleaning up..."
	@rm -rf $(INSTALL_DIR)/hx-utils-modules
	@rm -rf $(INSTALL_DIR)/hx-utils-bin

help:
	@echo "Available commands:"
	@echo "  make install   - Install hx-utils"
	@echo "  make uninstall - Uninstall hx-utils"
	@echo "  make update    - Update hx-utils"
	@echo "  make clean     - Remove installed files"
	@echo "  make help      - Show this help message"
