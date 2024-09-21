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
    if (direction == "up") {
        for (x = 0; x < x_dim; x++) {
            if (matrix[0][x] == 1) new_matrix[y_dim-1][x] = 1;
            else new_matrix[y_dim-1][x] = 0;
        }
        for (y = y_dim - 2; y >= 0; y--) {
            for (x = 0; x < x_dim; x++) {
                if (matrix[y+1][x] == 1) new_matrix[y][x] = 1;
                else if (matrix[y][x] == 1) new_matrix[y][x] = 0;
                else new_matrix[y][x] = 0;
            }
        }
    } else if (direction == "down") {
        for (x = 0; x < x_dim; x++) {
            if (matrix[y_dim-1][x] == 1) new_matrix[0][x] = 1;
            else new_matrix[0][x] = 0;
        }
        for (y = 1; y < y_dim; y++) {
            for (x = 0; x < x_dim; x++) {
                if (matrix[y-1][x] == 1) new_matrix[y][x] = 1;
                else if (matrix[y][x] == 1) new_matrix[y][x] = 0;
                else new_matrix[y][x] = 0;
            }
        }
    } else if (direction == "left") {
        for (y = 0; y < y_dim; y++) {
            if (matrix[y][0] == 1) new_matrix[y][x_dim-1] = 1;
            else new_matrix[y][x_dim-1] = 0;
        }
        for (x = x_dim - 2; x >= 0; x--) {
            for (y = 0; y < y_dim; y++) {
                if (matrix[y][x+1] == 1) new_matrix[y][x] = 1;
                else if (matrix[y][x] == 1) new_matrix[y][x] = 0;
                else new_matrix[y][x] = 0;
            }
        }
    } else if (direction == "right") {
        for (y = 0; y < y_dim; y++) {
            if (matrix[y][x_dim-1] == 1) new_matrix[y][0] = 1;
            else new_matrix[y][0] = 0;
        }
        for (x = 1; x < x_dim; x++) {
            for (y = 0; y < y_dim; y++) {
                if (matrix[y][x-1] == 1) new_matrix[y][x] = 1;
                else if (matrix[y][x] == 1) new_matrix[y][x] = 0;
                else new_matrix[y][x] = 0;
            }
        }
    } else {
        print "Error: Invalid direction. Use up, down, left, or right." > "/dev/stderr"
        exit 1
    }

    for (y = 0; y < y_dim; y++) {
        for (x = 0; x < x_dim; x++) {
            printf "(%d,%d,%d)%s", x, y, new_matrix[y][x], (x == x_dim - 1 ? "\n" : " ")
        }
    }
}
' "$matrix_file"
