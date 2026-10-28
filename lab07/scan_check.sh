#!/bin/bash
if grep -q "sqlmap" case/logs/access.log; then
    echo "Scanning tool activity detected"
else
    echo "No scanning tool activity"
fi
