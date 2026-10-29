#!/bin/bash
if [ "$#" -ne 1 ]; then echo "Usage: $0 <username>" >&2; exit 1; fi
USERNAME=$1
LOG=case/logs/auth.log
if [ ! -r "$LOG" ]; then echo "Cannot read $LOG" >&2; exit 2; fi
SOURCES=$(grep -F "Accepted password for $USERNAME " "$LOG" |
    awk '{for(i=1;i<=NF;i++) if($i=="from") print $(i+1)}' | sort -u)
if [ -z "$SOURCES" ]; then
    echo "$USERNAME: no successful logins"
else
    COUNT=$(printf '%s\n' "$SOURCES" | wc -l)
    echo "$USERNAME logged in from $COUNT different address(es):"
    echo "$SOURCES"
fi
