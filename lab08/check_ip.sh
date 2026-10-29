#!/bin/bash
if [ "$#" -ne 2 ]; then echo "Usage: $0 <logfile> <ip_address>" >&2; exit 1; fi
LOGFILE=$1
IP=$2
if [ ! -f "$LOGFILE" ]; then echo "Error: '$LOGFILE' not found" >&2; exit 2; fi
if grep -qwF -- "$IP" "$LOGFILE"; then
    COUNT=$(grep -cwF -- "$IP" "$LOGFILE")
    echo "FOUND: $IP appears $COUNT time(s) in $LOGFILE"
    exit 0
else
    echo "NOT FOUND: $IP does not appear in $LOGFILE"
    exit 3
fi
