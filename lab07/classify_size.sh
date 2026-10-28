#!/bin/bash
SMALL_LIMIT=10
MEDIUM_LIMIT=70

if [ $# -ne 1 ]; then
    echo "Usage: $0 <file>" >&2
    exit 1
fi

FILE=$1
LINES=$(wc -l < "$FILE")

if [ "$LINES" -eq 0 ]; then
    echo "$FILE is EMPTY"
elif [ "$LINES" -lt "$SMALL_LIMIT" ]; then
    echo "$FILE is SMALL ($LINES lines)"
elif [ "$LINES" -lt "$MEDIUM_LIMIT" ]; then
    echo "$FILE is MEDIUM ($LINES lines)"
else
    echo "$FILE is LARGE ($LINES lines)"
fi
