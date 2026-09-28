#!/bin/bash

CASE_DIR="case"

read -p "Enter your analyst name: " ANALYST
read -p "Enter the case reference: " CASE_REF
read -p "Enter today's shift (day/night): " SHIFT

echo "======================================"
echo " Security Operations Session"
echo "======================================"
echo " Analyst   : $ANALYST"
echo " Case      : $CASE_REF"
echo " Evidence  : $CASE_DIR"
echo " Shift     : $SHIFT"
echo " Started   : $(date)"
echo " Host      : $(whoami)@$(hostname)"
echo "======================================"
