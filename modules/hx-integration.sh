#!/usr/bin/env bash

# Get current file information
get_current_file_info() {
    local status_line=$(get_helix_status)
    local filename=$(echo $status_line | awk '{ print $1}')
    local line_number=$(echo $status_line | awk '{ print $2}')
    local basedir=$(dirname "$filename")
    local basename=$(basename "$filename")
    local basename_without_extension="${basename%.*}"
    local extension="${filename##*.}"

    echo "$filename $line_number $basedir $basename $basename_without_extension $extension"
}

hx_integration() {
    local command="$1"
    shift

    case "$command" in
        blame)
            hx_blame
            ;;
        explorer)
            hx_explorer
            ;;
        grep)
            hx_grep
            ;;
        browse)
            hx_browse
            ;;
        git-files)
            hx_git_files
            ;;
        git-changed-files)
            hx_git_changed_files
            ;;
       *)
            echo "Unknown integration command: $command"
            exit 1
            ;;
    esac
}

hx_blame() {
    local file_info=($(get_current_file_info))
    local filename="${file_info[0]}"
    local line_number="${file_info[1]}"

    winmux sp "tig blame $filename +$line_number"
}

hx_explorer() {
    local file_info=($(get_current_file_info))
    local filename="${file_info[0]}"
    local basedir="${file_info[2]}"
    local session_name=$(get_session_name)

    case $HX_MODE in
        tmux)
            hx_explorer_tmux "$basedir" "$session_name"
            ;;
        wezterm)
            hx_explorer_wezterm "$basedir" "$session_name"
            ;;
    esac
}

hx_explorer_tmux() {
    local basedir="$1"
    local session_name="$2"
    local env_line="EDITOR=hx-open"
    local current_pane_id="${TMUX_PANE}"
    local broot_pane_id=$(tmux list-panes -F '#{pane_title} #{pane_id}' | grep -E '^broot ' | grep -v "$current_pane_id" | cut -d ' ' -f 2)

    if [ -z "$broot_pane_id" ]; then
        tmux split-window -hb -l 23% "$env_line broot --listen $session_name"
    else
        broot --send $session_name -c ":focus $PWD/$basedir"
        tmux select-pane -t "$broot_pane_id"
    fi
}

hx_explorer_wezterm() {
    local basedir="$1"
    local session_name="$2"
    local left_pane_id=$(wezterm cli get-pane-direction left)

    if [ -z "${left_pane_id}" ]; then
        wezterm cli split-pane --left --percent 23 -- broot --listen $session_name
    else
        broot --send $session_name -c ":focus $PWD/$basedir"
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

hx_browse() {
    local file_info=($(get_current_file_info))
    local filename="${file_info[0]}"
    local line_number="${file_info[1]}"

    gh browse $filename:$line_number
}
