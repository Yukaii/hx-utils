# Makefile for hx-utils

# Default installation directory
INSTALL_DIR := $(HOME)/.local/bin

# Source files
SOURCES := hx-utils.sh config.sh modules/hx-integration.sh hx-grep winmux hx-open

# Targets
.PHONY: all install uninstall update clean help

all: install

install:
	@echo "Installing hx-utils..."
	@mkdir -p $(INSTALL_DIR)/hx-utils-modules
	@cp hx-utils.sh $(INSTALL_DIR)/hx-utils
	@cp modules/*.sh $(INSTALL_DIR)/hx-utils-modules/
	@cp hx-grep $(INSTALL_DIR)/
	@cp winmux $(INSTALL_DIR)/
	@chmod +x $(INSTALL_DIR)/hx-utils
	@chmod +x $(INSTALL_DIR)/hx-grep
	@chmod +x $(INSTALL_DIR)/winmux
	@echo "Installation complete. Please add $(INSTALL_DIR) to your PATH if it's not already there."

uninstall:
	@echo "Uninstalling hx-utils..."
	@rm -f $(INSTALL_DIR)/hx-utils
	@rm -f $(INSTALL_DIR)/hx-grep
	@rm -f $(INSTALL_DIR)/winmux
	@rm -f $(INSTALL_DIR)/hx-open
	@rm -rf $(INSTALL_DIR)/hx-utils-modules
	@echo "Uninstallation complete."

update: uninstall install
	@echo "hx-utils has been updated."

clean:
	@echo "Cleaning up..."
	@rm -f $(INSTALL_DIR)/hx-utils
	@rm -f $(INSTALL_DIR)/hx-grep
	@rm -f $(INSTALL_DIR)/winmux
	@rm -f $(INSTALL_DIR)/hx-open
	@rm -rf $(INSTALL_DIR)/hx-utils-modules

help:
	@echo "Available commands:"
	@echo "  make install   - Install hx-utils"
	@echo "  make uninstall - Uninstall hx-utils"
	@echo "  make update    - Update hx-utils"
	@echo "  make clean     - Remove installed files"
	@echo "  make help      - Show this help message"
