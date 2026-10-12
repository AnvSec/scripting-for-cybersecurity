#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <logfile>" >&2
    exit 1
fi
LOGFILE=$1

if [ ! -f "$LOGFILE" ]; then
    echo "Error: file '$LOGFILE' not found or not a regular file" >&2
    exit 2
fi
if [ ! -r "$LOGFILE" ]; then
    echo "Error: '$LOGFILE' cannot be read" >&2
    exit 3
fi

export LC_ALL=C
set -o pipefail
FAILED=$(grep -c -- "Failed password" "$LOGFILE")
STATUS=$?
if [ "$STATUS" -gt 1 ]; then
    exit 3
fi

# Find top3.sh beside this script, even when called from another directory.
SCRIPT_DIR=$(dirname -- "$0") || exit 3
TOP_THREE=$(bash "$SCRIPT_DIR/top3.sh" "$LOGFILE") || exit 3
TOP_IP=$(printf '%s\n' "$TOP_THREE" | awk 'NR==2 && $1 ~ /^[0-9]+$/ {print $2}') || exit 3

# "invalid user NAME" has two extra words before the actual username.
TOP_USERS=$(awk '/Failed password/ {
    for(i=1;i<=NF-3;i++) {
        if($i=="Failed" && $(i+1)=="password" && $(i+2)=="for") {
            if($(i+3)=="invalid" && $(i+4)=="user") print $(i+5)
            else print $(i+3)
            break
        }
    }
}' < "$LOGFILE" | sort | uniq -c | sort -k1,1nr -k2,2 | awk 'NR<=3') || exit 3

echo "Log file: $LOGFILE"
echo "Failed password events: $FAILED"
echo "Most common failed-login source: ${TOP_IP:-None}"
echo "$TOP_THREE"
echo "Top 3 targeted usernames:"
if [ -n "$TOP_USERS" ]; then
    echo "$TOP_USERS"
else
    echo "None (no failed-login usernames found)."
fi
if [ "$FAILED" -eq 0 ]; then
    echo "No SSH failed-password events found; this does not rule out other activity."
fi
exit 0
