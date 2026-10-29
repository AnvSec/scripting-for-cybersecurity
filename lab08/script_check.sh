#!/bin/bash
if [ "$#" -ne 1 ]; then echo "Usage: $0 <file>" >&2; exit 1; fi
FILE=$1
if [ ! -f "$FILE" ]; then
    echo "$FILE: not a regular file" >&2
    exit 2
fi
FIRST_TWO=$(head -c 2 "$FILE")
if [ "$FIRST_TWO" = '#!' ] && [ ! -x "$FILE" ]; then
    echo "$FILE: has an interpreter line ($(head -n 1 "$FILE")) but is NOT executable"
elif [ "$FIRST_TWO" = '#!' ]; then
    echo "$FILE: executable script ($(head -n 1 "$FILE"))"
else
    echo "$FILE: no interpreter line"
fi
