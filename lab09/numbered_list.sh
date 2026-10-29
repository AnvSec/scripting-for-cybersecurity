#!/bin/bash
INDEX=1
for FILE in case/configs/*.conf case/logs/*.log; do
    [ -f "$FILE" ] || continue
    echo "File #$INDEX: $FILE"
    INDEX=$((INDEX + 1))
done
