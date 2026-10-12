#!/bin/bash

LOG="case/logs/auth.log"

echo "$LOG was last modified: $(date -r "$LOG")"
echo "It contains $(wc -l < "$LOG") lines, of which $(grep -c "Failed password" "$LOG") are failed logins and $(grep -c "Accepted password" "$LOG") are successful"
