#!/bin/bash

set -eu
# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed. Please install jq first."
    exit 1
fi

# Get connected outputs
mapfile -t connected_outputs < <(swaymsg -t get_outputs -r | jq -r '.[].name')
output_count=${#connected_outputs[@]}

# Exit if less than 2 displays
if [ "$output_count" -lt 2 ]; then
    echo "No external display detected. Exiting."
    exit 0
fi

# Get first output's current mode
first_output=${connected_outputs[0]}
query=".[] | select(.name == \"$first_output\") | \"\(.current_mode.width)x\(.current_mode.height)\""
reference_mode=$(swaymsg -t get_outputs -r | jq -r "$query")

# Set mirror mode for all displays
echo "Setting mirror mode with resolution: $reference_mode"
for output in "${connected_outputs[@]}"; do
    swaymsg output "$output" enable
    swaymsg output "$output" mode "$reference_mode" pos 0 0
done

# Alacritty font size configuration
set_alacritty_font() {
    if alacritty msg config --window-id $ALACRITTY_WINDOW_ID font.size=16.0 2>/dev/null; then
        echo "Alacritty font size updated via IPC"
        return
    else
        echo "Failed to update Alacritty config"
    fi
}

# Change Alacritty font size
if command -v alacritty &> /dev/null; then
    set_alacritty_font
else
    echo "Alacritty not found - skipping font adjustment"
fi

echo "Presentation mode activated"
