#!/bin/bash

EVIDENCE_DIR="case/evidence"

echo "Files in $EVIDENCE_DIR:"
ls "$EVIDENCE_DIR"

echo ""

read -p "Which file do you want to identify? " NAME

echo "Detected type : $(file -b "$EVIDENCE_DIR/$NAME")"
echo "Size in bytes : $(wc -c < "$EVIDENCE_DIR/$NAME")"
