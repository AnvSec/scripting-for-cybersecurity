#!/bin/bash
for FILE in case/*/*; do
    [ -f "$FILE" ] || continue
    TYPE=$(file -b "$FILE")
    if [[ "$TYPE" == ELF* ]]; then
        echo "EXECUTABLE CONTENT: $FILE ($TYPE)"
    fi
done
