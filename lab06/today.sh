#!/bin/bash

TODAY=$(date +%Y-%m-%d)
echo "Today is $TODAY"

echo "Next phase"

LINE_COUNT=$(wc -l < case/logs/auth.log)
echo "auth.log has $LINE_COUNT lines"