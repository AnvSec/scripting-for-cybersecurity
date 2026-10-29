#!/bin/bash
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <logfile> <IP_or_username>" >&2
    exit 1
fi
LOGFILE=$1
TERM_ARG=$2

if [ ! -e "$LOGFILE" ]; then echo "Error: file does not exist: $LOGFILE" >&2; exit 2; fi
if [ ! -f "$LOGFILE" ]; then echo "Error: not a regular file: $LOGFILE" >&2; exit 3; fi
if [ ! -r "$LOGFILE" ]; then echo "Error: file is unreadable: $LOGFILE" >&2; exit 4; fi
if [ -z "$TERM_ARG" ]; then echo "Error: search term is empty" >&2; exit 5; fi

if echo "$TERM_ARG" | grep -Eq '^[0-9]+(\.[0-9]+){3}$'; then
    COUNT=$(grep -cwF -- "$TERM_ARG" "$LOGFILE")
    FAILS=$(grep -F 'Failed password' "$LOGFILE" | grep -cwF -- "$TERM_ARG")
    echo "IP: $TERM_ARG"
    echo "Matches in $LOGFILE: $COUNT"
    echo "Failed password events: $FAILS"
    if [ "$FAILS" -eq 0 ]; then RISK=NONE
    elif [ "$FAILS" -lt 5 ]; then RISK=LOW
    elif [ "$FAILS" -lt 15 ]; then RISK=MEDIUM
    else RISK=HIGH; fi
    echo "Risk: $RISK"

    if grep -qwF -- "$TERM_ARG" case/logs/firewall.log; then
        echo 'Firewall: matching record(s):'
        grep -wF -- "$TERM_ARG" case/logs/firewall.log
    else
        echo 'Firewall: no matching records'
    fi

    if grep -qxF -- "$TERM_ARG" intel/iocs.txt; then
        echo 'IOC list: YES'
    else
        echo 'IOC list: NO'
    fi
else
    FAILS=$(grep -cF "Failed password for $TERM_ARG " "$LOGFILE")
    ACCEPTS=$(grep -cF "Accepted password for $TERM_ARG " "$LOGFILE")
    echo "Username: $TERM_ARG"
    echo "Failed logins: $FAILS"
    echo "Accepted logins: $ACCEPTS"
    if awk -F, -v username="$TERM_ARG" '$1==username {found=1} END {exit !found}' intel/users.csv; then
        echo 'Account: CURRENT'
    elif grep -qxF -- "$TERM_ARG" case/backups/users.old; then
        echo 'Account: LEGACY'
    else
        echo 'Account: UNKNOWN'
    fi
    COUNT=$((FAILS + ACCEPTS))
fi

if [ "$COUNT" -gt 0 ]; then
    echo 'Result: FOUND'
    exit 0
else
    echo 'Result: NOT FOUND'
    exit 6
fi
