#!/bin/bash
CONF=$1
DEBUG=$(grep '^debug=' "$CONF" | cut -d= -f2)
DEBUG="${DEBUG,,}"

if [ -z "$DEBUG" ]; then
    echo "$CONF: no debug setting"
elif [ "$DEBUG" = "true" ] || [ "$DEBUG" = "yes" ]; then
    echo "$CONF: WARNING - debug mode is ON"
elif [ "$DEBUG" = "false" ]; then
    echo "$CONF: debug mode is off"
else
    echo "$CONF: unexpected debug value '$DEBUG'"
fi
