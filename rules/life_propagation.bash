#!/usr/bin/env bash

# Check if we have the correct number of arguments
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <matrix_file> <x_dim> <y_dim>"
    exit 1
fi

matrix_file="$1"
x_dim="$2"
y_dim="$3"

awk -v x_dim="$x_dim" -v y_dim="$y_dim" '
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
    for (y = 0; y < y_dim; y++) {
        for (x = 0; x < x_dim; x++) {
            neighbors = 0
            for (dy = -1; dy <= 1; dy++) {
                for (dx = -1; dx <= 1; dx++) {
                    if (dx == 0 && dy == 0) continue
                    nx = x + dx
                    ny = y + dy
                    if (nx >= 0 && nx < x_dim && ny >= 0 && ny < y_dim && matrix[ny][nx] == 1) {
                        neighbors++
                    }
                }
            }
            
            if (matrix[y][x] == 1) {
                if (neighbors == 2 || neighbors == 3) {
                    new_matrix[y][x] = 1  # Survival
                } else {
                    new_matrix[y][x] = 0  # Death
                }
            } else {
                if (neighbors == 3) {
                    new_matrix[y][x] = 1  # Birth
                } else {
                    new_matrix[y][x] = 0  # Stays dead
                }
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
