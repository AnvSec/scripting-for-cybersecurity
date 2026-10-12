#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <logfile>" >&2
    exit 1
fi

LOGFILE=$1

if [ ! -f "$LOGFILE" ]; then
    echo "Error: file '$LOGFILE' not found or not a regular file" >&2
    exit 2
fi

if [ ! -r "$LOGFILE" ]; then
    echo "Error: '$LOGFILE' cannot be read" >&2
    exit 3
fi

LINE_COUNT=$(wc -l < "$LOGFILE") || exit 3
WORD_COUNT=$(wc -w < "$LOGFILE") || exit 3
BYTE_COUNT=$(wc -c < "$LOGFILE") || exit 3
FIRST_LINE=$(head -n 1 -- "$LOGFILE") || exit 3
LAST_LINE=$(tail -n 1 -- "$LOGFILE") || exit 3
LONGEST_LINE=$(awk 'length > longest {longest=length} END {print longest+0}' < "$LOGFILE") || exit 3
FAILED=$(grep -c -- "Failed password" "$LOGFILE")
STATUS=$?
if [ "$STATUS" -gt 1 ]; then
    exit 3
fi

echo "Log file        : $LOGFILE"
echo "Total lines     : $LINE_COUNT"
echo "Total words     : $WORD_COUNT"
# wc -c counts bytes; this equals characters for these ASCII logs.
echo "Total bytes     : $BYTE_COUNT"
echo "First line      : $FIRST_LINE"
echo "Last line       : $LAST_LINE"
echo "Longest line    : $LONGEST_LINE characters"
echo "Failed logins   : $FAILED"

read -r -p "Enter a keyword to search for (or press Enter to skip): " KEYWORD

if [ -n "$KEYWORD" ]; then
    MATCH_COUNT=$(grep -c -- "$KEYWORD" "$LOGFILE")
    STATUS=$?
    echo "grep exit code: $STATUS"
    if [ "$STATUS" -gt 1 ]; then
        echo "Error: search failed (check the pattern and file)." >&2
        exit 4
    fi
    if [ "$MATCH_COUNT" -eq 0 ]; then
        echo "No matches found."
    else
        echo "Lines containing '$KEYWORD': $MATCH_COUNT"
    fi
fi

exit 0
