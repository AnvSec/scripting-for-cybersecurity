#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: $0 <baseline_config> <current_config>" >&2
    exit 2
fi

diff -u -- "$1" "$2"
STATUS=$?

if [ "$STATUS" -gt 1 ]; then
    echo "diff exit code: $STATUS (comparison error)" >&2
else
    echo ""
    echo "diff exit code: $STATUS (0 = identical, 1 = drift, 2 = error)"
fi
exit "$STATUS"
