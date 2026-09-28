#!/bin/bash

PYTHON_FILES=2
SHELL_SCRIPTS=1
LOG_FILES=4
CONFIG_FILES=3
TOTAL_FILES=22

SCRIPTS=$((PYTHON_FILES + SHELL_SCRIPTS))
OTHER=$((TOTAL_FILES - SCRIPTS - LOG_FILES - CONFIG_FILES))
PERCENT_LOGS=$((LOG_FILES * 100 / TOTAL_FILES))
PERCENT_SCRIPTS=$((SCRIPTS * 100 / TOTAL_FILES))

echo "Scripts (Python + shell) : $SCRIPTS"
echo "Logs                     : $LOG_FILES"
echo "Configuration files      : $CONFIG_FILES"
echo "Everything else          : $OTHER"
echo "Logs as % of all files   : $PERCENT_LOGS%"
echo "Scripts as % of all files: $PERCENT_SCRIPTS%"
