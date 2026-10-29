#!/bin/bash
if [ "$#" -ne 0 ]; then
    echo "Usage: $0 (no arguments)" >&2
    exit 1
fi
FILES=0
FLAGGED=0
TOTAL_IOC_MATCHES=0
for FILE in case/evidence/* case/scripts/* case/logs/*; do
    [ -f "$FILE" ] || continue
    FILES=$((FILES + 1))
    SIZE=$(wc -c < "$FILE")
    TYPE=$(file -b "$FILE")
    SHA256=$(sha256sum "$FILE" | awk '{print $1}')
    echo "=== $FILE ==="
    echo "Size: $SIZE bytes"
    echo "Type: $TYPE"
    if [[ "${TYPE,,}" == *text* ]]; then
        echo "Lines: $(wc -l < "$FILE")"
    fi
    echo "SHA-256: $SHA256"

    EXPECT=""
    case "$FILE" in
        *.png) EXPECT='PNG' ;;
        *.zip) EXPECT='Zip' ;;
        *.txt|*.md|*.log) EXPECT='text' ;;
        *.sh) EXPECT='shell script' ;;
        *.py) EXPECT='Python' ;;
        *.bin)
            if [ ! -s "$FILE" ]; then EXPECT='empty'; else EXPECT='data'; fi ;;
        *.dat) EXPECT='data' ;;
    esac
    if [ -z "$EXPECT" ]; then
        echo "?? Extension has no expected type"
    elif [[ "${TYPE,,}" != *"${EXPECT,,}"* ]]; then
        echo "!! MISMATCH: expected $EXPECT; detected $TYPE"
        FLAGGED=$((FLAGGED + 1))
    else
        echo 'OK Extension matches detected type'
    fi

    if [[ "$FILE" == *.log ]]; then
        DISTINCT=0
        # -F treats indicators literally; -w prevents partial-IP matches.
        # -c counts each physical log line only once, even if it contains multiple IOCs.
        MATCH_LINES=$(grep -cwF -f intel/iocs.txt "$FILE" || true)
        for INDICATOR in $(cat intel/iocs.txt); do
            if grep -qwF "$INDICATOR" "$FILE"; then
                DISTINCT=$((DISTINCT + 1))
            fi
        done
        echo "IOC distinct indicators: $DISTINCT"
        echo "IOC indicator-line matches: $MATCH_LINES"
        TOTAL_IOC_MATCHES=$((TOTAL_IOC_MATCHES + MATCH_LINES))
    fi
    echo
done
echo "Files surveyed: $FILES"
echo "Files flagged (!!): $FLAGGED"
echo "Total IOC indicator-line matches: $TOTAL_IOC_MATCHES"
