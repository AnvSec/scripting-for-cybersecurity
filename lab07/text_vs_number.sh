#!/bin/bash
A="10"
B="9"

echo "Using = (text comparison):"
if [ "$A" = "$B" ]; then echo "equal"; else echo "not equal"; fi

echo "Using -gt (numeric comparison):"
if [ "$A" -gt "$B" ]; then echo "$A is greater than $B"; fi

echo "Using text ordering:"
if [ "$A" \> "$B" ]; then
    echo "$A sorts after $B"
else
    echo "$A sorts before $B"
fi
