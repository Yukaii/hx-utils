#!/usr/bin/env bash

set -e

echo "Setting up hx-utils..."

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for required dependencies
base_dependencies=("make" "rg" "fzf" "bat")
missing_deps=()

for dep in "${base_dependencies[@]}"; do
    if ! command_exists "$dep"; then
        missing_deps+=("$dep")
    fi
done

# Check for either tmux or wezterm
if command_exists "tmux"; then
    MULTIPLEXER="tmux"
elif command_exists "wezterm"; then
    MULTIPLEXER="wezterm"
else
    missing_deps+=("tmux or wezterm")
fi

if [ ${#missing_deps[@]} -ne 0 ]; then
    echo "Error: The following dependencies are missing:"
    for dep in "${missing_deps[@]}"; do
        echo "  - $dep"
    done
    echo "Please install these dependencies and try again."
    exit 1
fi

# Check if the script is run from the correct directory
if [ ! -f "Makefile" ]; then
    echo "Error: Makefile not found. Please run this script from the hx-utils directory."
    exit 1
fi

# Run make install
make install

# Add the installation directory to PATH if it's not already there
INSTALL_DIR="$HOME/.local/bin"
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo "Adding $INSTALL_DIR to PATH..."
    echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$HOME/.bashrc"
    echo "Please restart your shell or run 'source ~/.bashrc' to update your PATH."
fi

echo "Setup complete!"
echo "Detected multiplexer: $MULTIPLEXER"
echo "You can now use 'hx-utils', 'hx-grep', and 'winmux' commands."
echo "Type 'hx-utils help' for usage information on hx-utils."
echo "Type 'winmux --help' for usage information on winmux."

