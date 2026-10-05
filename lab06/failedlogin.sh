#!/bin/bash
AUTH_LOG="case/logs/auth.log"
FAILED_LOGIN=$(grep "Failed password" "$AUTH_LOG" |
awk '{for(i=1;i<=NF;i++) if($i=="from") print $(i+1)}' |
sort | uniq -c | sort -nr | head -n 1)
echo "Most common failed login attempt:"
echo "$FAILED_LOGIN"