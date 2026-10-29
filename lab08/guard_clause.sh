#!/bin/bash
if [ "$#" -ne 1 ]; then echo "Usage: $0 <file>" >&2; exit 1; fi
FILE=$1
if [ ! -f "$FILE" ]; then
    echo "Error: $FILE is not a regular file" >&2
    exit 2
elif [ ! -r "$FILE" ]; then
    echo "Error: $FILE is not readable" >&2
    exit 3
elif [ ! -s "$FILE" ]; then
    echo "Error: $FILE is empty" >&2
    exit 4
else
    echo "$FILE is a readable, non-empty file - proceeding."
fi
