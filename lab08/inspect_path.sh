#!/bin/bash
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <path>" >&2
    exit 1
fi
TARGET=$1
if [ ! -e "$TARGET" ]; then
    echo "$TARGET does not exist"
    exit 2
elif [ -d "$TARGET" ]; then
    echo "$TARGET is a directory"
elif [ -f "$TARGET" ]; then
    echo "$TARGET is a regular file"
    if [ ! -r "$TARGET" ]; then
        echo "  WARNING: the file is not readable"
    elif [ -s "$TARGET" ]; then
        echo "  and it is not empty ($(wc -c < "$TARGET") bytes)"
    else
        echo "  but it is empty"
    fi
else
    echo "$TARGET exists but is neither a regular file nor a directory"
fi
