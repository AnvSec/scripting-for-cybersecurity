#!/bin/bash
if [ "$#" -ne 1 ]; then echo "Usage: $0 <path>" >&2; exit 1; fi
TARGET=$1
if [ -f "$TARGET" ] || [ -d "$TARGET" ]; then
    echo "$TARGET is a file or a directory."
else
    echo "$TARGET is neither (or does not exist)."
fi
