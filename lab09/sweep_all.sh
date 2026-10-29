#!/bin/bash
for LOGFILE in case/logs/*.log; do
    [ -f "$LOGFILE" ] || continue
    echo "=== $LOGFILE ==="
    for INDICATOR in $(cat intel/iocs.txt); do
        if grep -qwF "$INDICATOR" "$LOGFILE"; then
            COUNT=$(grep -cwF "$INDICATOR" "$LOGFILE")
            echo "  MATCH: $INDICATOR ($COUNT lines)"
        fi
    done
done
