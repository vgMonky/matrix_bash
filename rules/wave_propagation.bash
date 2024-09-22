#!/usr/bin/env bash

# Check if we have the correct number of arguments
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <matrix_file> <x_dim> <y_dim>"
    exit 1
fi

matrix_file="$1"
x_dim="$2"
y_dim="$3"
direction_file="direction.txt"

# Read direction from file
if [ -f "$direction_file" ]; then
    direction=$(cat "$direction_file")
else
    echo "Error: direction.txt not found. Please create it with 'up', 'down', 'left', or 'right'."
    exit 1
fi

awk -v x_dim="$x_dim" -v y_dim="$y_dim" -v direction="$direction" '
BEGIN {
    FS = OFS = " "
}
{
    for (i = 1; i <= NF; i++) {
        split($i, a, ",")
        gsub(/[()]/, "", a[3])
        matrix[NR-1][i-1] = a[3]
    }
}
END {
    # Create a wave effect based on the current direction
    for (y = 0; y < y_dim; y++) {
        for (x = 0; x < x_dim; x++) {
            alive_neighbors = 0
            if (direction == "up" || direction == "down") {
                if (y > 0) alive_neighbors += matrix[y-1][x]
                if (y < y_dim-1) alive_neighbors += matrix[y+1][x]
            } else {
                if (x > 0) alive_neighbors += matrix[y][x-1]
                if (x < x_dim-1) alive_neighbors += matrix[y][x+1]
            }
            
            if (alive_neighbors == 1) {
                new_matrix[y][x] = 1
            } else {
                new_matrix[y][x] = 0
            }
        }
    }

    # Output the new matrix
    for (y = 0; y < y_dim; y++) {
        for (x = 0; x < x_dim; x++) {
            printf "(%d,%d,%d)%s", x, y, new_matrix[y][x], (x == x_dim - 1 ? "\n" : " ")
        }
    }
}
' "$matrix_file"
