#!/usr/bin/env bash

# Function to print usage information
usage() {
    echo "Usage: $0 <command> [options]"
    echo "Commands:"
    echo "  create    Create a new 3D matrix with all z values set to 0"
    echo "    Options for create:"
    echo "      -x <value>    Number of columns (required)"
    echo "      -y <value>    Number of rows (required)"
    echo "      -d <directory>    Specify the directory (required)"
    echo "  life      Randomly set one z value to 1 in the existing matrix"
    echo "  cycle     Apply a rule to propagate life in the matrix"
    echo "    Options for cycle:"
    echo "      -r <rule_script>    Specify the rule script (required)"
    echo "      -d <directory>    Specify the directory (required)"
    echo "  wipe      Set all z values to 0 in the existing matrix"
    echo "Options for life, wipe:"
    echo "  -d <directory>    Specify the directory (required)"
    exit 1
}

# Function to create the 3D matrix with all z values set to 0
create_matrix() {
    local dir="$1"
    local x_dim="$2"
    local y_dim="$3"
    mkdir -p "$dir"
    local file="$dir/matrix.txt"
    > "$file"  # Clear the file if it exists
    for ((y=0; y<y_dim; y++)); do
        for ((x=0; x<x_dim; x++)); do
            echo -n "($x,$y,0) " >> "$file"
        done
        echo >> "$file"
    done
    echo "Dimensions: $x_dim x $y_dim" > "$dir/dimensions.txt"
    echo "3D Matrix with dimensions ${x_dim}x${y_dim} and all z values set to 0 created in $file"
}

# Function to randomly set one z value to 1
add_life() {
    local dir="$1"
    local file="$dir/matrix.txt"
    local dim_file="$dir/dimensions.txt"
    if [ ! -f "$file" ] || [ ! -f "$dim_file" ]; then
        echo "Error: matrix.txt or dimensions.txt not found in $dir"
        exit 1
    fi
    
    # Read dimensions
    local x_dim y_dim
    read x_dim y_dim <<< $(grep "Dimensions:" "$dim_file" | awk '{print $2, $4}')
    
    # Get a random position
    local random_x=$((RANDOM % x_dim))
    local random_y=$((RANDOM % y_dim))
    
    # Use awk to replace the z value at the random position with 1
    awk -v x="$random_x" -v y="$random_y" '
    BEGIN { FS = OFS = " " }
    NR == y + 1 {
        for (i = 1; i <= NF; i++) {
            if (i == x + 1) {
                sub(/,0\)/, ",1)", $i)
            }
            printf "%s%s", $i, (i == NF ? "\n" : OFS)
        }
    }
    NR != y + 1 { print $0 }
    ' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
    
    echo "Randomly set z value to 1 at position ($random_x,$random_y) in $file"
}

# Function to cycle the matrix using an external rule script
cycle_matrix() {
    local dir="$1"
    local rule_script="$2"
    local file="$dir/matrix.txt"
    local dim_file="$dir/dimensions.txt"
    if [ ! -f "$file" ] || [ ! -f "$dim_file" ]; then
        echo "Error: matrix.txt or dimensions.txt not found in $dir"
        exit 1
    fi
    if [ ! -f "$rule_script" ]; then
        echo "Error: Rule script $rule_script not found"
        exit 1
    fi

    # Read dimensions
    local x_dim y_dim
    read x_dim y_dim <<< $(grep "Dimensions:" "$dim_file" | awk '{print $2, $4}')

    # Apply the rule script
    bash "$rule_script" "$file" "$x_dim" "$y_dim" > "${file}.tmp" && mv "${file}.tmp" "$file"

    echo "Matrix cycled using $rule_script in $file"
}

# Function to wipe the matrix (set all z values to 0)
wipe_matrix() {
    local dir="$1"
    local file="$dir/matrix.txt"
    if [ ! -f "$file" ]; then
        echo "Error: matrix.txt not found in $dir"
        exit 1
    fi

    awk '{
        for (i=1; i<=NF; i++) {
            sub(/,[01]\)/, ",0)", $i)
        }
        print $0
    }' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"

    echo "All z values in $file have been set to 0"
}

# Main script logic
if [ "$#" -lt 2 ]; then
    usage
fi

command="$1"
shift

case "$command" in
    create)
        while [[ "$#" -gt 0 ]]; do
            case $1 in
                -x) x_dim="$2"; shift ;;
                -y) y_dim="$2"; shift ;;
                -d) directory="$2"; shift ;;
                *) echo "Unknown parameter: $1"; usage ;;
            esac
            shift
        done
        if [ -z "$x_dim" ] || [ -z "$y_dim" ] || [ -z "$directory" ]; then
            echo "Error: -x, -y, and -d are required for create command"
            usage
        fi
        create_matrix "$directory" "$x_dim" "$y_dim"
        ;;
    cycle)
        while [[ "$#" -gt 0 ]]; do
            case $1 in
                -r) rule_script="$2"; shift ;;
                -d) directory="$2"; shift ;;
                *) echo "Unknown parameter: $1"; usage ;;
            esac
            shift
        done
        if [ -z "$rule_script" ] || [ -z "$directory" ]; then
            echo "Error: -r and -d are required for cycle command"
            usage
        fi
        cycle_matrix "$directory" "$rule_script"
        ;;
    life|wipe)
        while [[ "$#" -gt 0 ]]; do
            case $1 in
                -d) directory="$2"; shift ;;
                *) echo "Unknown parameter: $1"; usage ;;
            esac
            shift
        done
        if [ -z "$directory" ]; then
            echo "Error: -d is required"
            usage
        fi
        case "$command" in
            life) add_life "$directory" ;;
            wipe) wipe_matrix "$directory" ;;
        esac
        ;;
    *)
        echo "Unknown command: $command"
        usage
        ;;
esac
