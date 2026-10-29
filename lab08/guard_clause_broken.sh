#!/bin/bash
if [ ! -f "$1" ]; then
  exit 2
  echo "Error: not a regular file"
fi
