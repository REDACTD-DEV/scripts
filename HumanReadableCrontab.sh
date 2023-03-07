#!/bin/bash

# Define a function to convert a single crontab entry to human-readable format
function convert_crontab_to_schedule {
    local line="$1"
    local parts=($line)
    local minutes="${parts[0]}"
    local hours="${parts[1]}"
    local days_of_month="${parts[2]}"
    local months="${parts[3]}"
    local days_of_week="${parts[4]}"
    local command="${parts[@]:5}"

    local schedule="At $minutes past the $hours hour, on "

    if [[ $days_of_month == "*" ]]; then
        schedule+="every day of "
    else
        schedule+="the $days_of_month day of "
    fi

    if [[ $months == "*" ]]; then
        schedule+="every month"
    else
        schedule+="the month of $months"
    fi

    if [[ $days_of_week != "*" ]]; then
        schedule+=", but only on "
        local days=("Sunday" "Monday" "Tuesday" "Wednesday" "Thursday" "Friday" "Saturday")
        local selected_days=($(echo $days_of_week | tr "," " "))
        selected_days=("${days[@]:0:${#selected_days[@]}}")
        selected_days=("${selected_days[@]//"0"/"Sunday"}")
        schedule+=$(echo "${selected_days[@]}" | sed 's/ /, /g')
    fi

    schedule+=", run the command '$command'"
    echo "$schedule"
}

# Read the crontab file and convert each entry to human-readable format
while read -r line; do
    if [[ $line != \#* ]]; then
        schedule=$(convert_crontab_to_schedule "$line")
        echo "$schedule"
    fi
done < /etc/crontab
