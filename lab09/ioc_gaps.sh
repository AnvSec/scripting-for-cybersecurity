#!/bin/bash
ATTACKERS=$(grep 'Failed password' case/logs/auth.log |
    awk '{for(i=1;i<=NF;i++) if($i=="from") print $(i+1)}' | sort -u)
for IP in $ATTACKERS; do
    COUNT=$(grep -cwF "from $IP " case/logs/auth.log || true)
    if grep -qxF "$IP" intel/iocs.txt; then
        echo "$IP ($COUNT failures): already in IOC list"
    else
        echo "$IP ($COUNT failures): NOT in IOC list — candidate for new indicator"
    fi
done
