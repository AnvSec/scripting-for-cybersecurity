#!/bin/bash

read -r -p "Enter a username: " USERNAME

if [ -z "$USERNAME" ]; then
    echo "Error: no username entered" >&2
    exit 1
fi

ROW=$(awk -F, -v user="$USERNAME" '
NR==1 {
    for (i=1; i<=NF; i++) {
        h=tolower($i)
        gsub(/\r|[[:space:]]/, "", h)
        if (h=="role") r=i
        if (h=="status") s=i
    }
}
NR>1 && $1==user {
    role=r ? $r : "unknown"
    status=s ? $s : "unknown"
    gsub(/\r/, "", status)
    print role "|" status
    exit
}' intel/users.csv)

if [ -n "$ROW" ]; then
    SOURCE="CURRENT"
    CODE=0
    IFS='|' read -r ROLE STATUS <<< "$ROW"
    echo "$USERNAME: CURRENT account"
    echo "Role: $ROLE"
    echo "Status: $STATUS"
elif grep -qx "$USERNAME" case/backups/users.old; then
    SOURCE="LEGACY"
    CODE=2
    echo "$USERNAME: LEGACY account"
else
    SOURCE="UNKNOWN"
    CODE=3
    echo "$USERNAME: UNKNOWN account"
fi

FAILED=$(grep -Fc "Failed password for $USERNAME " case/logs/auth.log)
ACCEPTED=$(grep -Fc "Accepted password for $USERNAME " case/logs/auth.log)

echo "Failed logins: $FAILED"
echo "Accepted logins: $ACCEPTED"

./risk_level.sh "$FAILED"

if [ "$SOURCE" = "CURRENT" ]; then
    if [ "${STATUS,,}" = "disabled" ] && [ "$ACCEPTED" -gt 0 ]; then
        echo "WARNING: Disabled account has accepted logins!"
    fi

    if [ "$ACCEPTED" -gt 0 ] && grep -q "^$USERNAME:" case/evidence/passwords.txt; then
        echo "WARNING: Plaintext credentials and successful logins!"
    fi
elif [ "$FAILED" -gt 0 ]; then
    echo "WARNING: Attackers targeted a $SOURCE account!"
fi

exit "$CODE"
