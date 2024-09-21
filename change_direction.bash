#!/usr/bin/env bash

# Check if a direction argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <direction>"
    echo "Allowed directions: up, down, left, right"
    exit 1
fi

# Convert input to lowercase for case-insensitive comparison
new_direction=$(echo "$1" | tr '[:upper:]' '[:lower:]')

# Check if direction.txt exists and read current direction
if [ -f direction.txt ]; then
    current_direction=$(cat direction.txt)
else
    current_direction=""
fi

# Function to check if directions are opposites
are_opposite() {
    case "$1" in
        up) [ "$2" = "down" ] && return 0 ;;
        down) [ "$2" = "up" ] && return 0 ;;
        left) [ "$2" = "right" ] && return 0 ;;
        right) [ "$2" = "left" ] && return 0 ;;
    esac
    return 1
}

# Check if the provided direction is valid and not opposite to current
case $new_direction in
    up|down|left|right)
        if are_opposite "$current_direction" "$new_direction"; then
            echo "Error: Cannot change to opposite direction ($new_direction)."
            exit 1
        else
            echo $new_direction > direction.txt
            echo "Direction changed to: $new_direction"
        fi
        ;;
    *)
        echo "Error: Invalid direction. Use up, down, left, or right."
        exit 1
        ;;
esac
