#!/usr/bin/env bash

# Function to print usage information
usage() {
    echo "Usage: $0 <command> [options]"
    echo "Commands:"
    echo "  start     Start automated matrix cycling and rendering"
    echo "    Options for start:"
    echo "      -s <seconds>   Interval between cycles (required)"
    echo "      -d <directory> Specify the directory (required)"
    echo "      -r, --rule <rule_script> Specify the rule script (required)"
    echo "  stop      Stop the automated process"
    echo "    Options for stop:"
    echo "      -d <directory> Specify the directory (required)"
    exit 1
}

# Function to start the automated process
start_automation() {
    local interval="$1"
    local dir="$2"
    local rule_script="$3"
    local pid_file="$dir/automation.pid"
    local lock_file="$dir/automation.lock"

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

    # Start the background process
    (
        while true; do
            # Acquire lock
            exec 200>$lock_file
            flock -n 200 || { echo "Failed to acquire lock. Exiting."; exit 1; }

            # Run cycle with the specified rule and update
            ./manage_matrix.bash cycle -r "$rule_script" -d "$dir"
            ./manage_render.bash update -d "$dir"

            # Release lock
            flock -u 200

            sleep "$interval"
        done
    ) &

    # Save the PID of the background process
    echo $! > "$pid_file"
    echo "Automation started with PID $(cat "$pid_file") using rule script $rule_script. Use '$0 stop -d $dir' to terminate."
}

# Function to stop the automated process
stop_automation() {
    local dir="$1"
    local pid_file="$dir/automation.pid"

    if [ -f "$pid_file" ]; then
        pid=$(cat "$pid_file")
        kill "$pid"
        rm "$pid_file"
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
    stop)
        if [ "$#" -ne 2 ] || [ "$1" != "-d" ]; then
            echo "Error: -d <directory> is required for stop command"
            usage
        fi
        stop_automation "$2"
        ;;
    *)
        echo "Unknown command: $command"
        usage
        ;;
esac
