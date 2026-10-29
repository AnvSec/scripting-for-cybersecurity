#!/bin/bash
if [ "$#" -ne 1 ]; then echo "Usage: $0 <ip_address>" >&2; exit 1; fi
./check_ip.sh case/logs/firewall.log "$1" > /dev/null
RESULT=$?
if [ "$RESULT" -eq 0 ]; then
    echo "Decision: $1 is known to the firewall - check what action was taken."
    echo "Firewall record(s):"
    grep -wF -- "$1" case/logs/firewall.log
elif [ "$RESULT" -eq 3 ]; then
    echo "Decision: the firewall never saw $1."
else
    echo "Decision: could not complete the check (exit code $RESULT)."
fi
