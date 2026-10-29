#!/bin/bash
TOTAL=0
for LOGFILE in case/logs/*.log; do
    [ -f "$LOGFILE" ] || continue
    COUNT=$(grep -c 'Failed password' "$LOGFILE" || true)
    echo "$LOGFILE: $COUNT failed logins"
    TOTAL=$((TOTAL + COUNT))
done
echo "TOTAL: $TOTAL"
