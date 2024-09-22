#!/usr/bin/env bash

# Function to print usage information
usage() {
    echo "Usage: $0 update -d <directory>"
    echo "Commands:"
    echo "  update    Read matrix.txt and update render.txt with z values"
    echo "Options:"
    echo "  -d, --directory    Specify the directory containing the matrix.txt file (required)"
    exit 1
}

# Function to update the render file
update_render() {
    local dir="$1"
    local matrix_file="$dir/matrix.txt"
    local render_file="$dir/render.txt"
    
    if [ ! -f "$matrix_file" ]; then
        echo "Error: matrix.txt not found in $dir"
        exit 1
    fi

    # Create a temporary file for the new render
    temp_file=$(mktemp)

    # ANSI color codes
    RED='\033[0;31m'
    NC='\033[0m' # No Color

    while IFS= read -r line; do
        echo "$line" | awk '{
            for (i=1; i<=NF; i++) {
                split($i, a, ",")
                gsub(/[()]/, "", a[3])
                if (a[3] == 1) {
                    printf "'"$RED"'1'"$NC"' "
                } else {
                    printf "0 "
                }
            }
            printf "\n"
        }' >> "$temp_file"
    done < "$matrix_file"

    # Check if render.txt exists and if it's different from the new render
    if [ ! -f "$render_file" ] || ! cmp -s "$temp_file" "$render_file"; then
        mv "$temp_file" "$render_file"
        echo "render.txt has been created/updated in $dir"
    else
        rm "$temp_file"
        echo "No changes detected in the matrix. render.txt remains unchanged."
    fi
}

# Main script logic
if [ "$#" -lt 3 ]; then
    usage
fi

command="$1"
shift

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -d|--directory) directory="$2"; shift ;;
        *) echo "Unknown parameter: $1"; usage ;;
    esac
    shift
done

if [ -z "$directory" ]; then
    echo "Error: Directory not specified"
    usage
fi

case "$command" in
    update)
        update_render "$directory"
        ;;
    *)
        echo "Unknown command: $command"
        usage
        ;;
esac
