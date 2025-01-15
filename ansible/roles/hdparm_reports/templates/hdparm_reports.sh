#!/bin/bash
set -eo pipefail

# Specify the output JSON file
output_file="{{hdparm_reports_output_file}}"
touch "$output_file"
# Run hdparm command and capture the output
hdparm_output=$(hdparm -C /dev/sda /dev/sdd /dev/sde /dev/sdf)

timestamp=$(date +%s)

# Parse the hdparm output and create JSON
json_output="{\"timestamp\":$timestamp,"

while read -r line; do
    if [[ $line =~ ^/dev/ ]]; then
        drive=$(echo "$line" | awk '{print $1}')
        read -r next_line
        state=$(echo "$next_line" | awk '{print $4}')
        json_output+="\"$drive\":{\"power_state\":\"$state\"},"
    fi
done <<< "$hdparm_output"

# Remove the trailing comma and close the JSON object
json_output="${json_output%,}}"
json_output+="}"

line_count=$(wc -l < "$output_file")
if (( line_count > 50000 )); then
    mv "$output_file" "$output_file.old"
    touch "$output_file"
fi

# Write the JSON to the specified output file
echo "$json_output" > "$output_file"
chmod a+r "$output_file"
echo "JSON output written to $output_file"
