#!/usr/bin/env bash

# Function to read current direction
get_current_direction() {
    if [ -f direction.txt ]; then
        cat direction.txt
    else
        echo "right"  # Default direction if file doesn't exist
    fi
}

# Function to change direction
change_direction() {
    local new_dir="$1"
    local current_dir=$(get_current_direction)

    # Check if new direction is opposite to current
    case "$current_dir" in
        up)    [[ "$new_dir" == "down" ]]  && return ;;
        down)  [[ "$new_dir" == "up" ]]    && return ;;
        left)  [[ "$new_dir" == "right" ]] && return ;;
        right) [[ "$new_dir" == "left" ]]  && return ;;
    esac

    echo "$new_dir" > direction.txt
    echo "Direction changed to: $new_dir"
}

# Main control loop
echo "Use arrow keys to change direction. Press 'q' to quit."
while true; do
    read -n 1 -s
    case "$REPLY" in
        A) change_direction "up"    ;;  # Up arrow
        B) change_direction "down"  ;;  # Down arrow
        C) change_direction "right" ;;  # Right arrow
        D) change_direction "left"  ;;  # Left arrow
        q) echo "Quitting..."; exit 0 ;;
        *) : ;;  # Ignore other keys
    esac
done
