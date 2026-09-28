#!/bin/bash

read -p "Enter a username: " USERNAME
read -s -p "Enter a password: " PASSWORD

echo ""
echo "Credentials captured for $USERNAME (password length: ${#PASSWORD})"
