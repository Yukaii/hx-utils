#!/usr/bin/env bash

# Determine the multiplexer mode
if [[ -n "$TMUX" ]]; then
    export HX_MODE="tmux"
elif [[ -n "$WEZTERM_PANE" ]]; then
    export HX_MODE="wezterm"
else
    echo "Error: Unsupported multiplexer environment."
    exit 1
fi

hx_log() {
    local log_level="$1"
    shift
    local message="$*"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] [$log_level] $message" >> /tmp/hx-utils.log
}

# Common functions
get_pane_direction() {
    case $1 in
        bottom) echo "down" ;;
        left) echo "left" ;;
        right) echo "right" ;;
        top) echo "up" ;;
        *) echo "Error: Invalid direction. Only 'top', 'bottom', 'left', and 'right' are supported." >&2; return 1 ;;
    esac
}

# Function to get the current Helix editor status
get_helix_status() {
    local status
    case $HX_MODE in
        tmux)
            status=$(tmux capture-pane -p -t $TMUX_PANE | rg -e "(?:NORMAL|INSERT|SELECT)\s+[\x{2800}-\x{28FF}]*\s+(\S*)\s[^│]* (\d+):*.*" -o --replace '$1 $2')
            ;;
        wezterm)
            status=$(wezterm cli get-text | rg -e "(?:NORMAL|INSERT|SELECT)\s+[\x{2800}-\x{28FF}]*\s+(\S*)\s[^│]* (\d+):*.*" -o --replace '$1 $2')
            ;;
    esac
    hx_log "INFO" "Helix status: $status"
    echo "$status"
}

# Function to get the current session name
get_session_name() {
    echo $PWD | sed "s:$HOME:~:" | tr '/' '_'
}

# Other common configurations and functions can be added here
