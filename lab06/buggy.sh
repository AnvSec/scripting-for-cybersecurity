#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <filename>" >&2
    exit 1
fi

if [ ! -f "$1" ]; then
    echo "Error: file not found" >&2
    exit 1
fi

echo "File found."
exit 0
