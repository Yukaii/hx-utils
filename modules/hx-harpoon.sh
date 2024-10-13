#!/usr/bin/env bash

# Function to get current git branch
get_git_branch() {
  git rev-parse --abbrev-ref HEAD 2>/dev/null
}

# Function to generate a simple hash using cksum (POSIX compliant)
hash_combination() {
  echo -n "$PWD $(get_git_branch)" | cksum | awk '{ print $1 }'
}

# Define the harpoon directory and file name based on PWD and git branch hash
HARPOON_DIR="$HOME/.cache/helix/harpoon"
HARPOON_FILE="$HARPOON_DIR/$(hash_combination)"

# Ensure harpoon directory exists
mkdir -p "$HARPOON_DIR"
touch "$HARPOON_FILE"

# Function to get current file
get_current_file() {
  local status_line=$(get_helix_status)
  echo $(echo $status_line | awk '{ print $1 }')
}

# Function to add current file to harpoon
harpoon_add() {
  local current_file=$(get_current_file)
  if [ -z "$current_file" ]; then
    echo "Error: No file to add."
    return 1
  fi

  if grep -q "^$current_file$" "$HARPOON_FILE"; then
    echo "Error: File already exists in harpoon."
    return 1
  fi

  echo "$current_file" >> "$HARPOON_FILE"
  echo "Added $current_file to harpoon."
}

# Function to list all harpoon files
harpoon_list() {
  cat "$HARPOON_FILE" | nl -w2 -s'. '
}

# Function to remove current file from harpoon
harpoon_remove() {
  local current_file=$(get_current_file)
  grep -v "^$current_file$" "$HARPOON_FILE" > "$HARPOON_FILE.tmp" && mv "$HARPOON_FILE.tmp" "$HARPOON_FILE"
  echo "Removed $current_file from harpoon."
}

# Function to open nth item from harpoon, remove entry if file doesn't exist
harpoon_open() {
  local index=$1
  local file=$(sed "${index}q;d" "$HARPOON_FILE")

  if [ -n "$file" ]; then
    if [ -f "$file" ]; then
      hx-utils open -d top "$file"
    else
      echo "File does not exist. Removing entry from harpoon."
      grep -v "^$file$" "$HARPOON_FILE" > "$HARPOON_FILE.tmp" && mv "$HARPOON_FILE.tmp" "$HARPOON_FILE"
    fi
  else
    echo "Invalid index."
  fi
}

# Function to edit HARPOON_FILE with $EDITOR in a winmux popup
harpoon_edit() {
  if [ -n "$EDITOR" ]; then
    winmux popup "$EDITOR" "$HARPOON_FILE"
  else
    echo "Error: No editor defined. Please set the EDITOR environment variable."
  fi
}

# Main function to handle harpoon commands
hx_harpoon() {
  case "$1" in
    add)
      harpoon_add
      ;;
    list)
      harpoon_list
      ;;
    remove)
      harpoon_remove
      ;;
    open)
      harpoon_open "$2"
      ;;
    edit)
      harpoon_edit
      ;;
    *)
      echo "Usage: harpoon {add|list|remove|open <index>|edit}"
      ;;
  esac
}
