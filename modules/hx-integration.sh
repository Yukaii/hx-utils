#!/usr/bin/env bash


hx_integration() {
  local command="$1"
  shift

  show_subcommand_help() {
    case "$1" in
    open)
      echo "Usage: hx open [FILE] [DIRECTION] [SPLIT] [PERCENT]"
      echo ""
      echo "Open a file in Helix editor."
      echo ""
      echo "Options:"
      echo "  FILE      The file to open."
      echo "  DIRECTION The direction to split the pane (default: right)."
      echo "  SPLIT     The type of split (v for vertical, h for horizontal, default: v)."
      echo "  PERCENT   The percentage of the pane size (default: 80)."
      echo "  --help    Show this help message"
      ;;
    blame)
      echo "Usage: hx blame [OPTIONS]"
      echo ""
      echo "Show git blame information for the file."
      echo ""
      echo "Options:"
      echo "  --filename FILE  Specify the file to blame"
      echo "  --line NUM      Specify the line number"
      echo "  --help          Show this help message"
      ;;
    explorer)
      echo "Usage: hx explorer [OPTIONS]"
      echo ""
      echo "Open file explorer."
      echo ""
      echo "Options:"
      echo "  --filename FILE  Specify the file to focus"
      echo "  --help          Show this help message"
      ;;
    grep)
      echo "Usage: hx grep [OPTIONS]"
      echo ""
      echo "Search for a pattern in files."
      echo ""
      echo "Options:"
      echo "  --help    Show this help message"
      ;;
    browse)
      echo "Usage: hx browse [OPTIONS]"
      echo ""
      echo "Open the git repository URL in the default browser."
      echo ""
      echo "Options:"
      echo "  --filename FILE  Specify the file to browse"
      echo "  --line NUM      Specify the line number"
      echo "  --help          Show this help message"
      ;;
    copy-permalink)
      echo "Usage: hx copy-permalink [OPTIONS]"
      echo ""
      echo "Copy the git repository URL to clipboard."
      echo ""
      echo "Options:"
      echo "  --filename FILE  Specify the file to link"
      echo "  --line NUM      Specify the line number"
      echo "  --help          Show this help message"
      ;;
    git-files)
      echo "Usage: hx git-files [OPTIONS]"
      echo ""
      echo "List files tracked by git."
      echo ""
      echo "Options:"
      echo "  --help    Show this help message"
      ;;
    git-changed-files)
      echo "Usage: hx git-changed-files [OPTIONS]"
      echo ""
      echo "List files changed in git."
      echo ""
      echo "Options:"
      echo "  --help    Show this help message"
      ;;
    harpoon)
      echo "Usage: hx harpoon [OPTIONS]"
      echo ""
      echo "Manage harpoon files."
      echo ""
      echo "Options:"
      echo "  add    Add the current file to harpoon."
      echo "  list   List all harpoon files."
      echo "  remove Remove the current file from harpoon."
      echo "  open   Open the nth item from harpoon."
      echo "  edit   Edit the list with default editor."
      echo "  --help Show this help message"
      ;;
    *)
      echo "Unknown subcommand: $1"
      exit 1
      ;;
    esac
  }

  # Parse common options
  local filename=""
  local line=""
  local column=""

  parse_common_options() {
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --filename)
          filename="$2"
          shift 2
          ;;
        --line)
          line="$2"
          shift 2
          ;;
        --column)
          column="$2"
          shift 2
          ;;
        *)
          return 1
          ;;
      esac
    done
  }

  case "$command" in
  open)
    if [ "$1" = "--help" ]; then
      show_subcommand_help open
    else
      hx_open "$@"
    fi
    ;;
  blame)
    if [ "$1" = "--help" ]; then
      show_subcommand_help blame
    else
      if ! parse_common_options "$@"; then
        echo "Unknown option: $1"
        return 1
      fi

      if [ -z "$filename" ]; then
        echo "Error: --filename is required"
        return 1
      fi

      hx_blame "$filename" "$line"
    fi
    ;;
  explorer)
    if [ "$1" = "--help" ]; then
      show_subcommand_help explorer
    else
      if ! parse_common_options "$@"; then
        echo "Unknown option: $1"
        return 1
      fi

      if [ -z "$filename" ]; then
        echo "Error: --filename is required"
        return 1
      fi

      # Only pass filename to explorer
      hx_explorer "$filename"
    fi
    ;;
  grep)
    if [ "$1" = "--help" ]; then
      show_subcommand_help grep
    else
      hx_grep
    fi
    ;;
  browse)
    if [ "$1" = "--help" ]; then
      show_subcommand_help browse
    else
      if ! parse_common_options "$@"; then
        echo "Unknown option: $1"
        return 1
      fi

      if [ -z "$filename" ]; then
        echo "Error: --filename is required"
        return 1
      fi

      hx_browse "$filename" "$line"
    fi
    ;;
  copy-permalink)
    if [ "$1" = "--help" ]; then
      show_subcommand_help copy-permalink
    else
      if ! parse_common_options "$@"; then
        echo "Unknown option: $1"
        return 1
      fi

      if [ -z "$filename" ]; then
        echo "Error: --filename is required"
        return 1
      fi

      hx_copy_permalink "$filename" "$line"
    fi
    ;;
  git-files)
    if [ "$1" = "--help" ]; then
      show_subcommand_help git-files
    else
      hx_git_files
    fi
    ;;
  git-changed-files)
    if [ "$1" = "--help" ]; then
      show_subcommand_help git-changed-files
    else
      hx_git_changed_files
    fi
    ;;
  harpoon)
    if [ "$1" = "--help" ]; then
      show_subcommand_help harpoon
    else
      hx_harpoon "$@"
    fi
    ;;
  *)
    echo "Unknown integration command: $command"
    exit 1
    ;;
  esac
}

hx_blame() {
  local filename="$1"
  local line="$2"

  winmux sp "tig blame $filename +${line:-1}"
}

hx_explorer() {
  local filename="$1"
  local basedir=$(dirname "$filename")
  local session_name=$(get_session_name)

  case $HX_MODE in
  tmux)
    hx_explorer_tmux "$filename" "$basedir" "$session_name"
    ;;
  wezterm)
    hx_explorer_wezterm "$filename" "$basedir" "$session_name"
    ;;
  esac
}


# Common function to check if broot is initialized
wait_for_broot() {
  local session_name="$1"
  local max_wait=20  # 2 seconds total (20 * 0.1s)
  local wait_count=0
  local root

  while true; do
    root=$(broot --send "$session_name" --get-root)
    if [ -n "$root" ]; then
      break
    fi
    sleep 0.1
    wait_count=$((wait_count + 1))

    if [ "$wait_count" -ge "$max_wait" ]; then
      echo "Timeout waiting for broot to initialize."
      break
    fi
  done
}

# Common function to send commands to broot
send_broot_commands() {
  local session_name="$1"
  local absolute="$2"
  local filename="$3"
  local dir=$(dirname "$filename")
  local root=$(broot --send "$session_name" --get-root)

  if [ "$root" != "$absolute" ] && [ "$dir" != '.' ]; then
    local relative_path=$(grealpath --relative-to="$root" "$absolute")
    broot --send "$session_name" -c ":focus $relative_path"
  fi

  broot --send "$session_name" -c ":select $(basename "$filename")"
}

# TMUX explorer function
hx_explorer_tmux() {
  local filename="$1"
  local basedir="$2"
  local session_name="$3"
  local env_line="EDITOR='hx-utils open'"
  local current_pane_id="${TMUX_PANE}"
  local broot_pane_id=$(tmux list-panes -F '#{pane_title} #{pane_id}' | grep -E '^broot ' | grep -v "$current_pane_id" | cut -d ' ' -f 2)
  local absolute=$(realpath "$PWD/$basedir")

  if [ -z "$broot_pane_id" ]; then
    tmux split-window -hb -l 23% "$env_line broot --listen $session_name $basedir"
    wait_for_broot "$session_name"
    broot --send "$session_name" -c ":select $(basename "$filename")"
  else
    send_broot_commands "$session_name" "$absolute" "$filename"
    tmux select-pane -t "$broot_pane_id"
  fi
}

# WezTerm explorer function
hx_explorer_wezterm() {
  local filename="$1"
  local basedir="$2"
  local session_name="$3"
  local left_pane_id=$(wezterm cli get-pane-direction left)
  local absolute=$(realpath "$PWD/$basedir")

  if [ -z "$left_pane_id" ]; then
    wezterm cli split-pane --left --percent 23 -- broot --listen $session_name $basedir
    wait_for_broot "$session_name"
    broot --send "$session_name" -c ":select $(basename "$filename")"
  else
    send_broot_commands "$session_name" "$absolute" "$filename"
    wezterm cli activate-pane-direction left
  fi
}
hx_grep() {
  winmux sp "hx-grep"
}

hx_git_files() {
  winmux sp "hx-git-files"
}

hx_git_changed_files() {
  winmux sp "hx-git-changed-files"
}

hx_copy_permalink() {
  local filename="$1"
  local line="$2"

  local url=$(gitlinker run --file "$filename" --start-line "$line")
  if [[ $url =~ ^https?:// ]]; then
    echo "$url" | pbcopy
    echo "Copied to clipboard: $url"
  else
    echo "$url"
  fi
}

hx_browse() {
  local filename="$1"
  local line="$2"

  local url=$(gitlinker run --file "$filename" --start-line "$line")
  if [[ $url =~ ^https?:// ]]; then
    open "$url"
  else
    echo "$url"
  fi
}
