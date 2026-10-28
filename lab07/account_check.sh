#!/bin/bash
read -r -p "Enter a username: " USERNAME

if [ -z "$USERNAME" ]; then
    echo "Error: no username entered" >&2
    exit 1
elif [ "$USERNAME" = "root" ]; then
    echo "CRITICAL: root should never accept password logins over SSH"
elif [ "$USERNAME" = "admin" ]; then
    echo "Warning: checking a generic admin account"
elif [ "$USERNAME" != "guest" ]; then
    echo "Checking standard account: $USERNAME"
else
    echo "Guest account — should normally be disabled"
fi
