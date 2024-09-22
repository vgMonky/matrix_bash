#!/usr/bin/env bash

# Function to print usage information
usage() {
    echo "Usage: $0 <command> [options]"
    echo "Commands:"
    echo "  start     Start automated matrix cycling and rendering with arrow key control"
    echo "    Options for start:"
    echo "      -s <seconds>   Interval between cycles (required)"
    echo "      -d <directory> Specify the directory (required)"
    echo "      -r, --rule <rule_script> Specify the rule script (required)"
    exit 1
}

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

# Function to start the automated process
start_automation() {
    local interval="$1"
    local dir="$2"
    local rule_script="$3"
    local pid_file="$dir/automation.pid"
    local lock_file="$dir/automation.lock"
    local current_rule_file="$dir/current_rule.txt"

    # Check if the process is already running
    if [ -f "$pid_file" ]; then
        echo "Automation process is already running."
        exit 1
    fi

    # Check if the rule script exists
    if [ ! -f "$rule_script" ]; then
        echo "Error: Rule script $rule_script not found."
        exit 1
    fi

    # Initialize current rule file
    echo "$rule_script" > "$current_rule_file"

    # Start the background process for matrix cycling
    (
        while true; do
            # Acquire lock
            exec 200>$lock_file
            flock -n 200 || { echo "Failed to acquire lock. Exiting."; exit 1; }

            # Read the current rule script
            current_rule=$(cat "$current_rule_file")

            # Run cycle with the current rule and update
            ./manage_matrix.bash cycle -r "$current_rule" -d "$dir"
            ./manage_render.bash update -d "$dir"

            # Release lock
            flock -u 200

            sleep "$interval"
        done
    ) &

    # Save the PID of the background process
    echo $! > "$pid_file"
    automation_pid=$!
    echo "Automation started with PID $automation_pid using rule script $rule_script."

    # Trap SIGINT and SIGTERM
    trap 'stop_automation "$dir"; exit 0' SIGINT SIGTERM

    # Start arrow key control with timeout
    echo "Use arrow keys to change direction. Press 'space' or '0' to wipe and add life."
    echo "Press '1' for linear propagation, '2' for simple propagation. Press 'q' to quit."
    while true; do
        if read -t 1 -n 1 -s key; then
            if [[ $key == $'\x20' ]]; then  # Check for space key (ASCII 32)
                key=' '
            fi
            case "$key" in
                A) change_direction "up"    ;;  # Up arrow
                B) change_direction "down"  ;;  # Down arrow
                C) change_direction "right" ;;  # Right arrow
                D) change_direction "left"  ;;  # Left arrow
                ' '|0) # Space key or '0' key
                    echo "Wiping matrix and adding life..."
                    ./manage_matrix.bash wipe -d "$dir"
                    ./manage_matrix.bash life -d "$dir"
                    ;;
                1)
                    echo "Switching to linear propagation..."
                    echo "linear_propagation.bash" > "$current_rule_file"
                    ;;
                2)
                    echo "Switching to simple propagation..."
                    echo "simple_propagation.bash" > "$current_rule_file"
                    ;;
                3)
   		    echo "Switching to wave propagation..."
		    echo "wave_propagation.bash" > "$current_rule_file"
		    ;;
	        4)
		    echo "Switching to balance propagation..."
		    echo "balance_propagation.bash" > "$current_rule_file"
		    ;;
		5)
		    echo "Switching to classic Life propagation..."
		    echo "life_propagation.bash" > "$current_rule_file"
		    ;;
		6)
		    echo "Switching to mycelium propagation..."
		    echo "mycelium_propagation.bash" > "$current_rule_file"
		    ;;    
      	        q)
                    echo "Quitting..."
                    stop_automation "$dir"
                    exit 0
                    ;;
                *) : ;;  # Ignore other keys
            esac
        fi
        # Check if the automation process is still running
        if ! kill -0 $automation_pid 2>/dev/null; then
            echo "Automation process has stopped unexpectedly."
            stop_automation "$dir"
            exit 1
        fi
    done
}

# Function to stop the automated process
stop_automation() {
    local dir="$1"
    local pid_file="$dir/automation.pid"

    if [ -f "$pid_file" ]; then
        pid=$(cat "$pid_file")
        kill $pid 2>/dev/null
        rm -f "$pid_file"
        echo "Automation process (PID: $pid) has been terminated."
    else
        echo "No running automation process found."
    fi
}

# Main script logic
if [ "$#" -lt 1 ]; then
    usage
fi

command="$1"
shift

case "$command" in
    start)
        while [[ "$#" -gt 0 ]]; do
            case $1 in
                -s) interval="$2"; shift ;;
                -d) directory="$2"; shift ;;
                -r|--rule) rule_script="$2"; shift ;;
                *) echo "Unknown parameter: $1"; usage ;;
            esac
            shift
        done
        if [ -z "$interval" ] || [ -z "$directory" ] || [ -z "$rule_script" ]; then
            echo "Error: -s, -d, and -r (or --rule) are required for start command"
            usage
        fi
        start_automation "$interval" "$directory" "$rule_script"
        ;;
    *)
        echo "Unknown command: $command"
        usage
        ;;
esac
