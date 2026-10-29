#!/bin/bash
for FILE in case/evidence/*; do
    [ -f "$FILE" ] || continue
    HASH=$(md5sum "$FILE" | awk '{print $1}')
    if grep -qxF "$HASH" intel/iocs.txt; then
        echo "KNOWN BAD: $FILE ($HASH)"
    else
        echo "clean    : $FILE"
    fi
done
