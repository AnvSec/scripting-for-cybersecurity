#!/bin/bash

CASE_DIR="case"
LOG_DIR="$CASE_DIR/logs"
EVIDENCE_DIR="$CASE_DIR/evidence"
ANALYST="analyst"
CASE_REF="CASE-2026-014"

echo "Analyst      : $ANALYST"
echo "Case folder  : $CASE_DIR"
echo "Log folder   : $LOG_DIR"
echo "Evidence     : $EVIDENCE_DIR"
echo "Case ref     : $CASE_REF"

echo ""
echo "Contents of $LOG_DIR:"
ls "$LOG_DIR"

echo ""
echo "Backup file for this case would be: ${CASE_DIR}_backup.tar"

echo ""
echo "Case $CASE_REF is being reviewed by $ANALYST using $CASE_DIR."
