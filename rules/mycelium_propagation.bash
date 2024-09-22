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
    srand()  # Initialize random number generator
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
            live_neighbors = 0
            potential_growth = 0
            for (dy = -2; dy <= 2; dy++) {
                for (dx = -2; dx <= 2; dx++) {
                    if (dx == 0 && dy == 0) continue
                    nx = x + dx
                    ny = y + dy
                    if (nx >= 0 && nx < x_dim && ny >= 0 && ny < y_dim) {
                        if (matrix[ny][nx] == 1) {
                            if (abs(dx) <= 1 && abs(dy) <= 1) live_neighbors++
                            potential_growth++
                        }
                    }
                }
            }
            
            if (matrix[y][x] == 1) {
                if (live_neighbors < 2 || live_neighbors > 4) {
                    new_matrix[y][x] = 0  # Die from isolation or overcrowding
                } else {
                    new_matrix[y][x] = 1  # Survive
                }
            } else {
                growth_chance = potential_growth / 25.0  # Max potential_growth is 24
                if (rand() < growth_chance) {
                    new_matrix[y][x] = 1  # New growth
                } else {
                    new_matrix[y][x] = 0  # Stay empty
                }
            }
            
            # Small chance of random mycelium appearing (spores)
            if (new_matrix[y][x] == 0 && rand() < 0.001) {  # 0.1% chance
                new_matrix[y][x] = 1
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

function abs(v) {
    return v < 0 ? -v : v
}
' "$matrix_file"
