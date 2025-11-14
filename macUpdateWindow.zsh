#!/bin/zsh --no-rcs
# shellcheck shell=bash
set -x

# macUpdateWindow.zsh
# v1.0

dialogApp=/usr/local/bin/dialog

# Get the planned update date and time delivered by DDM
# Line 12 is commented for demo mode
# plannedDateTime=$(defaults read /var/db/softwareupdate/SoftwareUpdateDDMStatePersistence.plist | grep TargetLocalDateTime | awk -F "\"" '/1/ {print $2}' | sed 's/T/, /')
plannedDateTime=$(date -v+15M "+%Y-%m-%dT%H:%M:%S")

# Check if $plannedDateTime is empty
if [[ -z $plannedDateTime ]]; then
    echo "No updates are planned."
    exit 0
fi

# TODO: Planned date and time may be in the past after a user has updated. Check for that and don't alert them about an old deadline

# Get the current date and time in the same style as $plannedDateTime
currentDateTime=$(date "+%Y-%m-%dT%H:%M:%S")

# Convert both date/time values to seconds so we can compare them
plannedTimestamp=$(date -j -f "%Y-%m-%dT%H:%M:%S" "$plannedDateTime" "+%s")
currentTimestamp=$(date -j -f "%Y-%m-%dT%H:%M:%S" "$currentDateTime" "+%s")
plannedDateTimeTimer=$((plannedTimestamp - currentTimestamp))

# Convert the planned update date/time to something easier to read
plannedDateTimeReadable=$(date -r "$plannedTimestamp" "+%I:%M %p")

# If $currentTimestamp is within 1 hour of $plannedTimestamp, display dialog
if [[ plannedDateTimeTimer -lt 3600 ]]; then
    $dialogApp --moveable --ontop --position bottomright --mini --timer $plannedDateTimeTimer --icon "SF=desktopcomputer.trianglebadge.exclamationmark,color=auto" --title none --message "This Mac will be installing updates at $plannedDateTimeReadable" &
    exit 0
fi
