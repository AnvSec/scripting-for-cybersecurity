#!/bin/bash
REPORT=""
for CONF in case/configs/*.conf case/backups/config.old; do
    [ -f "$CONF" ] || continue
    PORT=$(grep '^port=' "$CONF" | cut -d= -f2)
    DEBUG=$(grep '^debug=' "$CONF" | cut -d= -f2)
    [ -n "$PORT" ] || PORT='(none)'
    [ -n "$DEBUG" ] || DEBUG='(none)'
    REPORT="${REPORT}${CONF}: port ${PORT}; debug ${DEBUG}"$'\n'
done
printf 'Configured ports and debug settings:\n%s' "$REPORT"
