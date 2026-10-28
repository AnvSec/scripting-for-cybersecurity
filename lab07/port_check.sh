#!/bin/bash
CONF=$1
PORT=$(grep '^port=' "$CONF" | cut -d= -f2)

if [ -z "$PORT" ]; then
    echo "$CONF: no port configured"
elif ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
    echo "$CONF: invalid port '$PORT' - not a number"
elif [ "$PORT" -lt 1024 ]; then
    echo "$CONF: port $PORT is privileged"
else
    echo "$CONF: port $PORT is unprivileged"
fi
