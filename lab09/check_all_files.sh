#!/bin/bash
for FILE in case/logs/auth.log case/logs/access.log case/logs/firewall.log case/logs/missing.log; do
    echo "Checking $FILE..."
    if [ -f "$FILE" ]; then
        echo "  exists, $(wc -l < "$FILE") lines"
    else
        echo "  MISSING"
    fi
done
