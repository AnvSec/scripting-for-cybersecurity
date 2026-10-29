#!/bin/bash
# Inspect client IPs, not the requested URLs or server IPs.
CLIENTS=$(awk 'NF {print $1}' case/logs/access.log | sort -u)
for IP in $CLIENTS; do
    if [[ "$IP" =~ ^10\. || "$IP" =~ ^192\.168\. || "$IP" =~ ^172\.(1[6-9]|2[0-9]|3[01])\. || "$IP" =~ ^127\. || "$IP" =~ ^169\.254\. ]]; then
        CLASS='internal/private'
    else
        CLASS='non-private'
    fi
    COUNT=$(grep -cwF "$IP" case/logs/access.log || true)
    if grep -qxF "$IP" intel/iocs.txt; then
        echo "$IP ($COUNT matching lines): in IOC list [$CLASS]"
    else
        echo "$IP ($COUNT matching lines): NOT in IOC list [$CLASS]"
    fi
done
