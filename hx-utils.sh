#!/usr/bin/env bash

# Determine the script's directory
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
MODULES_DIR="${SCRIPT_DIR}/hx-utils-modules"

# Source configuration
source "${MODULES_DIR}/config.sh"

# Source modules
source "${MODULES_DIR}/hx-open.sh"
source "${MODULES_DIR}/hx-integration.sh"

# Main function to handle command routing
main() {
    case "$1" in
        open)
            shift
            hx_open "$@"
            ;;
        blame|explorer|fzf|browse)
            hx_integration "$@"
            ;;
        *)
            echo "Unknown command: $1"
            echo "Available commands: open, blame, explorer, fzf, browse"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
