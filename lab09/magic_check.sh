#!/bin/bash
# Check evidence AND collected scripts, without executing them.
for FILE in case/evidence/* case/scripts/*; do
    [ -f "$FILE" ] || continue
    TYPE=$(file -b "$FILE")
    EXPECT=""
    case "$FILE" in
        *.png) EXPECT='PNG' ;;
        *.zip) EXPECT='Zip' ;;
        *.txt|*.md|*.log) EXPECT='text' ;;
        *.sh) EXPECT='shell script' ;;
        *.py) EXPECT='Python' ;;
        *.bin)
            if [ ! -s "$FILE" ]; then EXPECT='empty'; else EXPECT='data'; fi ;;
        *.dat) EXPECT='data' ;;
    esac
    if [ -z "$EXPECT" ]; then
        echo "?? $FILE — no expectation for this extension; detected: $TYPE"
    elif [[ "${TYPE,,}" == *"${EXPECT,,}"* ]]; then
        echo "OK $FILE — $TYPE"
    else
        echo "!! $FILE — expected $EXPECT, detected: $TYPE"
    fi
done
