#!/bin/bash
COUNT=$1

if [ "$COUNT" -ge 10 ]; then
    echo "At least 10"
elif [ "$COUNT" -ge 0 ]; then
    echo "Non-negative"
else
    echo "Negative"
fi
