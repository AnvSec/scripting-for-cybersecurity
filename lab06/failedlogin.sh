#!/bin/bash

AUTH_LOG="case/logs/auth.log"
TOP_IP=$(grep "Failed password" "$AUTH_LOG" |
    awk '{for(i=1;i<=NF;i++) if($i=="from") print $(i+1)}' |
    sort | uniq -c | sort -nr | head -n 1 | awk '{print $2}')
echo "The most common failed-login source IP is $TOP_IP."
