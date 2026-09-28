#!/bin/bash

read -p "Enter a username to look up: " TARGET_USER
read -p "Enter a department: " DEPARTMENT

echo ""
echo "Searching the account list for: $TARGET_USER"
echo "Department: $DEPARTMENT"
echo ""

grep "$TARGET_USER" intel/users.csv | grep "$DEPARTMENT"
