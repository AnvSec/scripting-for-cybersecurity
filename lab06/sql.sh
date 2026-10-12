#!/bin/bash

echo "sqlmap requests: $(grep -c 'sqlmap' case/logs/access.log), which is $(( $(grep -c 'sqlmap' case/logs/access.log) * 100 / $(wc -l < case/logs/access.log) ))% of all requests."
