#!/bin/bash
for FILE in case/evidence/*; do
    [ -f "$FILE" ] || continue
    sha256sum "$FILE"
done
