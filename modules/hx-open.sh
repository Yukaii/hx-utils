#!/usr/bin/env bash

# Function to display help
show_help() {
  echo "Usage: $(basename "$0") [OPTIONS] [FILE]"
  echo "Options:"
  echo "  -m, --mode [tmux|wezterm]  Specify the multiplexer mode. Auto-detected if not specified."
  echo "  -d, --direction [DIRECTION]  Specify the pane direction ('top', 'bottom', 'left', 'right'). Default is 'right'."
  echo "  -s, --split [TYPE]  Specify the split type ('v' for vertical, 'h' for horizontal, 'none' for no split)."
  echo "  -p, --percent [PERCENT] Specify the default panel size percentage"
  echo "  -h, --help  Display this help and exit."
}

hx_open() {
  # Default values
  mode=""
  direction="right"
  split=""
  percent=80

  # Parse command-line options
  while [[ "$#" -gt 0 ]]; do
    case $1 in
    -m | --mode)
      mode="$2"
      shift 2
      ;;
    -d | --direction)
      direction="$2"
      shift 2
      ;;
    -p | --percent)
      percent="$2"
      shift 2
      ;;
    -s | --split)
      split="$2"
      shift 2
      ;;
    -h | --help)
      show_help
      exit 0
      ;;
    -*)
      echo "Unknown option: $1" >&2
      show_help
      exit 1
      ;;
    *)
      fpath="$1"
      shift
      ;;
    esac
  done

  if [[ -z "$fpath" ]]; then
    echo "Error: File path is required."
    show_help
    exit 1
  fi

  # Determine the mode based on environment variables if not specified
  if [[ -z "$mode" ]]; then
    if [[ -n "$TMUX" ]]; then
      mode="tmux"
    elif [[ -n "$WEZTERM_PANE" ]]; then
      mode="wezterm"
    else
      echo "Error: Multiplexer mode could not be determined. Please specify --mode."
      exit 1
    fi
  fi

  # Main logic based on mode
  case $mode in
  tmux)
    handle_tmux "$direction" "$split" "$percent" "$fpath"
    ;;
  wezterm)
    pane_direction=$(get_pane_direction "$direction")
    handle_wezterm "$pane_direction" "$direction" "$split" "$percent" "$fpath"
    ;;
  *)
    echo "Error: Unsupported mode '$mode'." >&2
    exit 1
    ;;
  esac
}

# Function to handle tmux
handle_tmux() {
  local direction="$1"
  local split="$2"
  local percent="$3"
  local fpath="$4"

  local tmux_direction
  case "$direction" in
  right) tmux_direction="right" ;;
  left) tmux_direction="left" ;;
  top) tmux_direction="top" ;;
  bottom) tmux_direction="bottom" ;;
  *)
    echo "Error: Invalid direction '$direction'." >&2
    return 1
    ;;
  esac

  local size="${percent}%"
  local pane_id=$(tmux list-panes -F '#{pane_title} #{pane_id}' | grep -E '^hx ' | grep -v "$TMUX_PANE" | awk '{ print $NF }')

  if [ -n "$pane_id" ]; then
    if [ -n "$split" ]; then
      case $split in
      v)
        tmux send-keys -t "$pane_id" ":vs" Enter
        ;;
      h)
        tmux send-keys -t "$pane_id" ":hs" Enter
        ;;
      esac
    fi
    tmux send-keys -t "$pane_id" ":open ${fpath}" Enter
    tmux select-pane -t "$pane_id"
  else
    if [ -n "$split" ]; then
      case $split in
      v)
        winmux -p 80 vsp "hx ${fpath}"
        ;;
      h)
        winmux sp "hx ${fpath}"
        ;;
      esac
    else
      winmux -p 80 vsp "hx ${fpath}"
    fi
  fi
}

# Function to handle wezterm
handle_wezterm() {
  local pane_direction="$1"
  local direction="$2"
  local split="$3"
  local percent="$4"
  local fpath="$5"

  local pane_id=$(wezterm cli get-pane-direction "$pane_direction")
  if [ -z "${pane_id}" ]; then
    pane_id=$(wezterm cli split-pane --"${direction}" --percent $percent)
  fi

  local program=$(wezterm cli list | awk -v pane_id="$pane_id" '$3==pane_id { print $6 }')
  if [ "$program" = "hx" ]; then
    # enter
    send_esc 3

    if [ -n "$split" ]; then
      case $split in
      v)
        echo -e ":vs\r" | wezterm cli send-text --pane-id $pane_id --no-paste
        ;;
      h)
        echo -e ":hs\r" | wezterm cli send-text --pane-id $pane_id --no-paste
        ;;
      esac
    fi
    echo -e ":open ${fpath}\r" | wezterm cli send-text --pane-id $pane_id --no-paste >/dev/null
  else
    echo "hx ${fpath}" | wezterm cli send-text --pane-id $pane_id --no-paste >/dev/null
  fi

  wezterm cli activate-pane-direction --pane-id $pane_id "$pane_direction"
}

send_esc() {
  local count=${1:-1} # Default to 1 if no argument is provided

  if ! [[ "$count" =~ ^[0-9]+$ ]]; then
    echo "Error: Please provide a valid positive integer."
    return 1
  fi

  for ((i = 0; i < count; i++)); do
    wezterm cli send-text --no-paste $'\e'
  done
}
