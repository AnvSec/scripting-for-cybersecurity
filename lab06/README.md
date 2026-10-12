# Lab 6 - checked project

The scripts and available-data exercises are complete. **The full lab is
not ready to submit until the missing source files below are supplied.**

## Use it

Merge the contents of this `lab06` folder into your existing `lab06` folder.
Keep your original, complete `case/` and `intel/` directories: do not replace
or delete them. The archive includes only the evidence files you attached,
copied without changing their contents.

On Linux, open a terminal in `lab06` and run:

```bash
chmod +x *.sh
./logstats.sh case/logs/auth.log
./attacker_report.sh case/logs/auth.log
```

`logstats.sh` asks for one search keyword; press Enter to skip. Its search
uses normal grep regular expressions, as in the lab examples. Run it again
for another keyword. For a literal dotted IP pattern, escape each dot.
The scripts use Bash and standard Linux commands; Windows users should use
their Linux lab environment or WSL rather than PowerShell.

## What was missing or changed

- Added `check_file.sh`, `validate_file.sh`, `config_drift.sh`, `logstats.sh`,
  the fixed `buggy.sh`, and `attacker_report.sh`.
- Added `exercise1.sh` for the missing substitution exercises.
- Extended `top3.sh` to accept an optional filename while preserving its
  original no-argument use. `attacker_report.sh` actually reuses it.
- Changed `failedlogin.sh` to store only the IP as Exercise 1 requests.
- Preserved the other uploaded teaching scripts and `wc_diff.txt`.
- Created the collected and web reports by running the finished script.
- Added `exercise-answers.txt`, `investigation.txt`, actual test results
  and a reusable Python test runner. Python is only needed for the tests;
  it is not required to run the shell scripts.
- `report-server.txt` is a conspicuous missing-source notice, not results.

Attacker rankings count matching failed-password lines. Ties in the new
report scripts are ordered alphabetically under the C locale. The parser
handles both normal usernames and `invalid user NAME` entries. This is an
SSH password-failure report, not a complete detector for every attack type.
The basic earlier teaching scripts still assume the supplied lab inputs;
`search.sh` intentionally retains its original argument behaviour so the
quoted/unquoted exercise remains reproducible.

## Verified

`test-results.txt` records **87 passing checks and 4 skipped checks**.
Tests cover syntax, all supplied logs, independently calculated statistics,
attacker counts, argument errors, missing files, empty logs, no matches,
invalid regexes, paths with spaces, invalid-user parsing, diff exit codes,
and the deliberate debugging mistakes. Evidence hashes stayed unchanged.

The four unreadable-file tests were skipped because this environment runs
as root and could not switch to an unprivileged user. Run the test runner
as your normal Linux lab user to verify these branches too:

```bash
python3 tests/test_lab06.py
```

Synthetic config/login samples exist only in temporary test directories;
they were never used as answers to the actual case investigation.

## Still requires your original files

1. `../lab03-data/auth.log`: required to generate `report-server.txt`, fill
   the server row in `investigation.txt`, compare rankings and list all
   server usernames, including the actual invalid-user line.
2. `../lab03-data/access.log`: referenced by the full-server-log exercise.
3. `case/backups/config.old` and `case/configs/app.conf`: required to list
   actual changed settings and assess the most important security change.
4. `case/config-old.txt` and `case/config-new.txt`: the other diff example.
5. The remaining original `case/` tree, including `case/evidence/empty.bin`:
   needed for the original wildcard count and exact empty-file example.

Do not use the collected auth.log as a replacement for the full server log.
Do not create invented configurations in case/ to fill these gaps.

Once the actual inputs are available, run from lab06:

```bash
./attacker_report.sh ../lab03-data/auth.log > report-server.txt
./logstats.sh ../lab03-data/auth.log
./logstats.sh ../lab03-data/access.log
./config_drift.sh case/config-old.txt case/config-new.txt
./config_drift.sh case/backups/config.old case/configs/app.conf
./validate_file.sh case/evidence/empty.bin
./args_demo.sh case/*
```

Use those real outputs to complete the clearly marked missing sections in
`exercise-answers.txt` and `investigation.txt`.

## Git submission

No repository, Git remote or credentials were supplied, so no commit or
push was made. After completing the remaining evidence-dependent answers,
run these in your existing repository's lab06 directory:

```bash
git add top3.sh nested_sub.sh args_demo.sh one_arg.sh search.sh check_file.sh validate_file.sh config_drift.sh logstats.sh buggy.sh attacker_report.sh report-collected.txt report-server.txt report-web.txt investigation.txt exercise1.sh exercise-answers.txt failedlogin.sh today.sh sql.sh wc_diff.txt
git commit -m "Complete Lab 6"
git push
```

Review `git status` before committing; do not stage changes to case/ or intel/.
