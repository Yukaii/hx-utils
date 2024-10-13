#!/usr/bin/env bash

# Function to get current git branch
get_git_branch() {
  git rev-parse --abbrev-ref HEAD 2>/dev/null
}

# Function to hash the combination of PWD and git branch
hash_combination() {
  echo -n "$PWD $(get_git_branch)" | sha256sum | awk '{ print $1 }'
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

# Function to open nth item from harpoon
harpoon_open() {
  local index=$1
  local file=$(sed "${index}q;d" "$HARPOON_FILE")
  if [ -n "$file" ]; then
    hx-utils open "$file"
  else
    echo "Invalid index."
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
    *)
      echo "Usage: harpoon {add|list|remove|open <index>}"
      ;;
  esac
}