#!/bin/bash

# No argument keeps the original lab example working.
if [ $# -gt 1 ]; then
    echo "Usage: $0 [logfile]" >&2
    exit 1
fi
AUTH_LOG=${1:-case/logs/auth.log}

if [ ! -f "$AUTH_LOG" ]; then
    echo "Error: file '$AUTH_LOG' not found or not a regular file" >&2
    exit 2
fi
if [ ! -r "$AUTH_LOG" ]; then
    echo "Error: '$AUTH_LOG' cannot be read" >&2
    exit 3
fi

export LC_ALL=C
set -o pipefail
# awk filters the failed events and prints the word after "from".
TOP_ATTACKERS=$(awk '/Failed password/ {
    for(i=1;i<NF;i++) if($i=="from") {print $(i+1); break}
}' < "$AUTH_LOG" | sort | uniq -c | sort -k1,1nr -k2,2 | awk 'NR<=3') || exit 3

echo "Top 3 failed-login sources:"
if [ -n "$TOP_ATTACKERS" ]; then
    echo "$TOP_ATTACKERS"
else
    echo "None (no failed-login sources found)."
fi
exit 0
