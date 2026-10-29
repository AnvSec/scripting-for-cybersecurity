#!/bin/bash
if [ "$#" -ne 2 ]; then echo "Usage: $0 <logfile> <username>" >&2; exit 1; fi
LOGFILE=$1
USERNAME=$2
if [ ! -f "$LOGFILE" ]; then echo "Error: '$LOGFILE' not found" >&2; exit 2; fi
if ! grep -q "for $USERNAME " "$LOGFILE"; then
    echo "$USERNAME: no activity found"
    exit 3
fi
FAILS=$(grep -c "Failed password for $USERNAME " "$LOGFILE")
ACCEPTS=$(grep -c "Accepted password for $USERNAME " "$LOGFILE")
if [ "$FAILS" -gt 0 ]; then
    echo "$USERNAME: $FAILS failed and $ACCEPTS accepted login(s) - investigate"
else
    echo "$USERNAME: $ACCEPTS successful login(s) only"
fi
if [ "$FAILS" -gt 5 ]; then echo "HIGH RISK"; fi
exit 0
