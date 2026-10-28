#!/bin/bash

FILE=$1

if [ -s "$FILE" ]; then
    echo "$FILE exists."
    LINES=$(wc -c < "$FILE")
    if [ "$LINES" -eq 0 ]; then
        echo "  ...but it has no lines."
    else
        echo "  ...and has $LINES lines."
    fi
else
    echo "$FILE does not exist — skipping the line count entirely."
fi
