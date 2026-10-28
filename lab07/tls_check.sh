#!/bin/bash
CONF=$1
TLS=$(grep '^tls=' "$CONF" | cut -d= -f2)

if [ -z "$TLS" ]; then
    echo "$CONF: no TLS setting"
elif [ "$TLS" = "true" ]; then
    echo "$CONF: TLS is enabled"
elif [ "$TLS" = "false" ]; then
    echo "$CONF: WARNING - TLS is disabled"
else
    echo "$CONF: unexpected TLS value '$TLS'"
fi
