#!/bin/bash

AUTH_LOG="case/logs/auth.log"

TOP_ATTACKERS=$(grep "Failed password" "$AUTH_LOG" |
    awk '{for(i=1;i<=NF;i++) if($i=="from") print $(i+1)}' |
    sort | uniq -c | sort -nr | head -n 3)

echo "Top 3 failed-login sources:"
echo "$TOP_ATTACKERS" #When the quotes are removed the echo outputs in one line instead of a list/bullet point

