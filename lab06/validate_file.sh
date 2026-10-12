#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <filename>" >&2
    exit 1
fi

if [ ! -f "$1" ]; then
    echo "Error: '$1' does not exist or is not a regular file" >&2
    exit 2
fi

if [ ! -r "$1" ]; then
    echo "Error: '$1' exists but cannot be read" >&2
    exit 3
fi

if [ ! -s "$1" ]; then
    echo "Error: '$1' is empty" >&2
    exit 4
fi

LINES=$(wc -l < "$1") || exit 3
echo "'$1' looks fine - $LINES lines"
exit 0
