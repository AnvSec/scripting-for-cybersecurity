#!/bin/bash
for INDICATOR in $(cat intel/iocs.txt); do
    SOURCES=0
    WHERE=""
    for LOGFILE in case/logs/*.log; do
        [ -f "$LOGFILE" ] || continue
        if grep -qwF "$INDICATOR" "$LOGFILE"; then
            SOURCES=$((SOURCES + 1))
            WHERE="$WHERE $(basename "$LOGFILE")"
        fi
    done
    echo "$INDICATOR: seen in $SOURCES log(s):$WHERE"
done
