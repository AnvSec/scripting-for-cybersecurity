#!/bin/bash

WEB_LINES=$(wc -l < case/logs/access.log)
echo "access.log has $WEB_LINES lines."

BLOCK_COUNT=$(grep -c "BLOCK" case/logs/firewall.log)
echo "The firewall recorded $BLOCK_COUNT BLOCK decisions."

TOP_IP=$(grep "Failed password" case/logs/auth.log |
    awk '{for(i=1;i<=NF;i++) if($i=="from") print $(i+1)}' |
    sort | uniq -c | sort -nr | head -n 1 | awk '{print $2}')
echo "The most common failed-login source IP is $TOP_IP."
