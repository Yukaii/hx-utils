#!/usr/bin/env bash

hx_open() {
    local file="$1"
    local direction="${2:-right}"
    local split="${3:-v}"
    local percent="${4:-80}"

    case $HX_MODE in
        tmux)
            handle_tmux "$direction" "$split" "$percent" "$file"
            ;;
        wezterm)
            local pane_direction=$(get_pane_direction "$direction")
            handle_wezterm "$pane_direction" "$direction" "$split" "$percent" "$file"
            ;;
    esac
}

handle_tmux() {
    local direction="$1"
    local split="$2"
    local percent="$3"
    local fpath="$4"

    local tmux_direction
    case "$direction" in
        right) tmux_direction="right";;
        left) tmux_direction="left";;
        top) tmux_direction="top";;
        bottom) tmux_direction="bottom";;
        *) echo "Error: Invalid direction '$direction'." >&2; return 1;;
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
        echo -e ":open ${fpath}\r" | wezterm cli send-text --pane-id $pane_id --no-paste > /dev/null
    else
        echo "hx ${fpath}" | wezterm cli send-text --pane-id $pane_id --no-paste > /dev/null
    fi

    wezterm cli activate-pane-direction --pane-id $pane_id "$pane_direction"
}
