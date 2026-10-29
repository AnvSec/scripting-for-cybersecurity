#!/bin/bash
for INDICATOR in $(cat intel/iocs.txt); do
    if grep -qwF "$INDICATOR" case/logs/auth.log; then
        echo "MATCH   : $INDICATOR found in auth.log"
    else
        echo "no match: $INDICATOR"
    fi
done
