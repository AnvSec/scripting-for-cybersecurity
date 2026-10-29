#!/bin/bash
if [ "$#" -ne 1 ]; then echo "Usage: $0 <path>" >&2; exit 1; fi
FILE=$1
echo "Permission report for: $FILE"
[ -e "$FILE" ] && echo "  exists       : yes" || echo "  exists       : no"
[ -f "$FILE" ] && echo "  regular file : yes" || echo "  regular file : no"
[ -d "$FILE" ] && echo "  directory    : yes" || echo "  directory    : no"
[ -r "$FILE" ] && echo "  readable     : yes" || echo "  readable     : no"
[ -w "$FILE" ] && echo "  writable     : yes" || echo "  writable     : no"
[ -x "$FILE" ] && echo "  executable   : yes" || echo "  executable   : no"
[ -s "$FILE" ] && echo "  non-empty    : yes" || echo "  non-empty    : no"
