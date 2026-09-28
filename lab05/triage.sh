#!/bin/bash

CASE_DIR="case"
REPORT="triage-report-auto.txt"

read -p "Enter your analyst name: " ANALYST
read -p "Enter the case reference: " CASE_REF

PYTHON_FILES=$(find "$CASE_DIR" -type f -name "*.py" | wc -l)
SHELL_SCRIPTS=$(find "$CASE_DIR" -type f -name "*.sh" | wc -l)

{
    echo "TRIAGE REPORT"
    echo "============="
    echo "Analyst: $ANALYST"
    echo "Case Reference: $CASE_REF"
    echo "Date: $(date)"
    echo ""

    echo "Total Files: $(find "$CASE_DIR" -type f | wc -l)"
    echo "Total Directories: $(find "$CASE_DIR" -type d | wc -l)"
    echo "Python Files: $PYTHON_FILES"
    echo "Shell Scripts: $SHELL_SCRIPTS"
    echo "Log Files: $(find "$CASE_DIR" -type f -name "*.log" | wc -l)"
    echo "Configuration Files: $(find "$CASE_DIR" -type f \( -name "*.conf" -o -name "*.cfg" \) | wc -l)"
    echo "Empty Files: $(find "$CASE_DIR" -type f -empty | wc -l)"
    echo "Archives: $(find "$CASE_DIR" -type f \( -name "*.tar" -o -name "*.tar.gz" -o -name "*.tgz" -o -name "*.zip" -o -name "*.gz" \) | wc -l)"
    echo ""

    echo "Files containing admin:"
    grep -rl "admin" "$CASE_DIR"
    echo ""

    echo "Evidence file types:"
    file "$CASE_DIR"/evidence/*
    echo ""

    TOTAL_SCRIPTS=$((PYTHON_FILES + SHELL_SCRIPTS))
    echo "Scripts (Python + shell): $TOTAL_SCRIPTS"
} > "$REPORT"

echo ""
echo "Triage complete."
echo "Report saved to: $REPORT"
