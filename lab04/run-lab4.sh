#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="${1:-$SCRIPT_DIR/lab04-data}"

if [[ ! -d "$DATA_DIR" ]]; then
  echo "Data directory not found: $DATA_DIR" >&2
  exit 1
fi

cd "$DATA_DIR"

exercise_1() {
  echo "## Exercise 1"
  echo "Directories below lab04-data: $(find . -type d | wc -l)"
  echo "Regular files: $(find . -type f | wc -l)"
  echo "Top-level directories:"
  find . -maxdepth 1 -mindepth 1 -type d -printf '%f\n' | sort
  echo
}

exercise_2() {
  echo "## Exercise 2"
  echo "All .py files:"
  ls scripts/*.py 2>/dev/null || true
  echo "All .log files directly inside logs:"
  ls logs/*.log 2>/dev/null || true
  echo "All .conf files:"
  ls configs/*.conf 2>/dev/null || true
  echo "All .txt files directly inside evidence:"
  ls evidence/*.txt 2>/dev/null || true
  echo "All filenames beginning with config in current directory:"
  ls config* 2>/dev/null || true
  echo
}

exercise_3() {
  echo "## Exercise 3"
  echo "Every .py file:"
  find . -type f -name '*.py' | sort
  echo "Every .conf file:"
  find . -type f -name '*.conf' | sort
  echo "Every .old file:"
  find . -type f -name '*.old' | sort
  echo "Every .log file, including nested logs:"
  find . -type f -name '*.log' | sort
  echo "Every file whose name contains config:"
  find . -type f -name '*config*' | sort
  echo
}

exercise_4() {
  echo "## Exercise 4"
  echo "Files inside evidence: $(find evidence -type f | wc -l)"
  echo "Files inside scripts: $(find scripts -type f | wc -l)"
  echo "Files under nested: $(find nested -type f | wc -l)"
  echo
}

exercise_5() {
  echo "## Exercise 5"
  file evidence/image.png evidence/archive.zip evidence/empty.bin evidence/suspicious.dat scripts/scan.py scripts/check.sh
  echo "Most suspicious result: evidence/suspicious.dat is detected as an ELF binary."
  echo
}

exercise_6() {
  echo "## Exercise 6"
  echo "Filename: $(basename "$(pwd)/evidence/suspicious.dat")"
  echo "Parent directory: $(dirname "$(pwd)/evidence/suspicious.dat")"
  echo
}

exercise_7() {
  echo "## Exercise 7"
  diff -u config-old.txt config-new.txt > config-changes.txt || true
  echo "Unified diff saved to config-changes.txt"
  cat config-changes.txt
  echo
}

exercise_8() {
  echo "## Exercise 8"
  for pattern in "admin" "BLOCK" "8080" "Scanning" "password123"; do
    echo "Pattern: $pattern"
    grep -R -n "$pattern" . || true
    echo
  done
}

exercise_9() {
  echo "## Exercise 9"
  echo "Empty files:"
  find . -type f -size 0 | sort
  echo "Count of empty files: $(find . -type f -size 0 | wc -l)"
  echo "Count of non-empty files: $(find . -type f -size +0c | wc -l)"
  echo
}

exercise_10() {
  echo "## Exercise 10"
  echo "Python files: $(find . -type f -name '*.py' | wc -l)"
  echo "Shell scripts: $(find . -type f -name '*.sh' | wc -l)"
  echo "Log files: $(find . -type f -name '*.log' | wc -l)"
  echo "Configuration files: $(find . -type f -name '*.conf' | wc -l)"
  echo "Text files: $(find . -type f -name '*.txt' | wc -l)"
  echo "ZIP archives: $(find . -type f -name '*.zip' | wc -l)"
  echo
}

exercise_11() {
  echo "## Exercise 11"
  echo "file against all files inside evidence:"
  find evidence -type f | xargs file
  echo "wc -l against all .log files:"
  find . -type f -name '*.log' | xargs wc -l
  echo "Contents of all .conf files:"
  find configs -type f -name '*.conf' -print0 | xargs -0 cat
  echo
}

exercise_12() {
  echo "## Exercise 12"
  echo "Configuration files containing port:"
  grep -R -n "port" configs || true
  echo "Logs containing 203.0.113.10:"
  grep -R -n "203.0.113.10" logs || true
  echo "Files anywhere containing admin:"
  grep -R -n "admin" . || true
  echo "Files containing debug:"
  grep -R -n "debug" . || true
  echo
}

exercise_13() {
  echo "## Exercise 13"
  echo "ZIP archive location: $(find . -type f -name '*.zip' | head -n 1)"
  file evidence/archive.zip
  echo "Contents of ZIP archive:"
  unzip -l evidence/archive.zip
  echo
}

exercise_17() {
  echo "## Exercise 17 (Triage challenge)"
  echo "Total files: $(find . -type f | wc -l)"
  echo "Total directories: $(find . -type d | wc -l)"
  echo "All scripts:"
  find . -type f \( -name '*.py' -o -name '*.sh' \) | sort
  echo "All log files:"
  find . -type f -name '*.log' | sort
  echo "All configuration files:"
  find . -type f -name '*.conf' | sort
  echo "All empty files:"
  find . -type f -size 0 | sort
  echo "All archive files:"
  find . -type f \( -name '*.zip' -o -name '*.gz' -o -name '*.tar' \) | sort
  echo "Files containing admin:"
  grep -R -l "admin" . || true
  echo "Files containing passwords:"
  grep -R -l -E "password|passwd|pass" . || true
  echo "Interesting file types:"
  file evidence/* scripts/* | sort
  echo
}

exercise_18() {
  echo "## Exercise 18"
  { 
    echo "File Triage Report"
    echo
    echo "Total Files: $(find . -type f | wc -l)"
    echo "Total Directories: $(find . -type d | wc -l)"
    echo "Python Files: $(find . -type f -name '*.py' | wc -l)"
    echo "Shell Scripts: $(find . -type f -name '*.sh' | wc -l)"
    echo "Log Files: $(find . -type f -name '*.log' | wc -l)"
    echo "Configuration Files: $(find . -type f -name '*.conf' | wc -l)"
    echo "Empty Files: $(find . -type f -size 0 | wc -l)"
    echo "Archives: $(find . -type f \( -name '*.zip' -o -name '*.gz' -o -name '*.tar' \) | wc -l)"
    echo
    echo "Files Containing \"admin\":"
    grep -R -l "admin" . || true
    echo
    echo "Detected File Types in Evidence:"
    file evidence/* | sort
  } > triage-report.txt

  echo "Triage report saved to triage-report.txt"
  cat triage-report.txt
  echo
}

main() {
  echo "Lab 4: Finding Files and Working with Data"
  echo "Data directory: $DATA_DIR"
  echo "=================================================="
  echo

  exercise_1
  exercise_2
  exercise_3
  exercise_4
  exercise_5
  exercise_6
  exercise_7
  exercise_8
  exercise_9
  exercise_10
  exercise_11
  exercise_12
  exercise_13
  exercise_17
  exercise_18

  echo "All exercises complete."
}

main "$@"
