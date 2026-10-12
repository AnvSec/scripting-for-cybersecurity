#!/bin/bash

if [ -f case/logs/auth.log ]; then
    echo "Found auth.log"
    exit 0
else
    echo "auth.log not found" >&2
    exit 1
fi
