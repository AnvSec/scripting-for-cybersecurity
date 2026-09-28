# Lab 6: Command Substitution, Arguments and Exit Codes

## Introduction

In Lab 5 you turned commands into scripts, gave them a shebang, made them executable, used variables, and asked the user for input with `read`.

Real tools are usually run with information supplied up front on the command line, and they report back whether they succeeded. In this lab you will learn how to:

- capture the **output** of a command into a variable (command substitution);
- accept information as **arguments** when the script is run, instead of always asking interactively;
- make a script report **success or failure** with an exit code.

You will finish by building `logstats.sh` — a script that takes any log file as an argument — and use it to compare the collected workstation logs with the full server logs from Lab 3.

**Case question for this lab:** who is attacking over SSH, and is the collected `auth.log` representative of the full server log?

## Objectives

By the end of this lab, you should be able to:

1. Capture the output of a single command, and of a pipeline, into a variable.
2. Access script arguments using `$1`, `$2`, `$#`, `$@` and `$0`.
3. Use `exit` codes to signal success or failure, and check `$?`.
4. Use exit codes from standard tools (`grep`, `diff`) to make decisions.
5. Separate normal output from error messages using standard error (`>&2`).
6. Combine command substitution, arguments and exit codes into a reusable log-statistics script.

# Part 1: Prepare Your Lab Directory

From the repository root:

```bash
mkdir lab06
cp -r lab04-data lab06/case
mkdir lab06/intel
cp lab03-data/iocs.txt lab03-data/users.csv lab06/intel/
cd lab06
```

The three logs you will use most are:

```text
case/logs/auth.log       SSH authentication events (collected from the workstation)
case/logs/access.log     web server requests
case/logs/firewall.log   firewall decisions
```

The **full** server logs from Lab 3 are still available at `../lab03-data/auth.log` and `../lab03-data/access.log`. You will use them in Part 5 to show that one script can analyse any file you give it.

# Part 2: Command Substitution

**Command substitution** captures the *output* of a command and stores it in a variable, using `$(...)`.

Try this interactively first:

```bash
TODAY=$(date +%Y-%m-%d)
echo "Today is $TODAY"
```

Capture a line count:

```bash
LINE_COUNT=$(wc -l < case/logs/auth.log)
echo "auth.log has $LINE_COUNT lines"
```

Note the use of `< case/logs/auth.log` rather than `wc -l case/logs/auth.log`. This feeds the file to `wc`'s input, so the output is just the number, with no filename attached — which matters when you want to store it cleanly in a variable.

Capture the result of a search:

```bash
FAILED_COUNT=$(grep -c "Failed password" case/logs/auth.log)
echo "There were $FAILED_COUNT failed login attempts"
```

**Worked example — capturing a multi-line result.** Command substitution can capture several lines at once:

```bash
#!/bin/bash

AUTH_LOG="case/logs/auth.log"

TOP_ATTACKERS=$(grep "Failed password" "$AUTH_LOG" |
    awk '{for(i=1;i<=NF;i++) if($i=="from") print $(i+1)}' |
    sort | uniq -c | sort -nr | head -n 3)

echo "Top 3 failed-login sources:"
echo "$TOP_ATTACKERS"
```

Save this as `top3.sh` and run it. The `awk` loop prints whatever word follows `from` on each line — the same technique you used in Lab 3.

Notice `echo "$TOP_ATTACKERS"` is **quoted**. Without the quotes, the three lines would be collapsed onto one, because unquoted variables are split into words.

**Worked example — several substitutions in one sentence.**

```bash
#!/bin/bash

LOG="case/logs/auth.log"

echo "$LOG was last modified: $(date -r "$LOG")"
echo "It contains $(wc -l < "$LOG") lines, of which $(grep -c "Failed password" "$LOG") are failed logins and $(grep -c "Accepted password" "$LOG") are successful."
```

Save this as `nested_sub.sh` and run it. Each `$(...)` is evaluated independently and its output dropped into place.

## Exercise 1

1. Store the number of lines in `case/logs/access.log` in a variable called `WEB_LINES` and print it.
2. Store the number of `BLOCK` decisions in `case/logs/firewall.log` in a variable and print a sentence containing it.
3. Store the single most common failed-login source IP in a variable and print a sentence containing it. (Hint: change `head -n 3` to `head -n 1`, then pipe into `awk '{print $2}'` to drop the count.)
4. Explain, in your own words, the difference between `wc -l case/logs/auth.log` and `wc -l < case/logs/auth.log`.
5. Run `top3.sh`, then remove the quotes around `"$TOP_ATTACKERS"`. Describe exactly what changes in the output.
6. Write a single `echo` that prints how many requests in `access.log` came from the `sqlmap` tool, and what percentage of all requests that is, using `$(( ))` inside the sentence.

# Part 3: Script Arguments

Scripts can accept input from the command line at the moment they are run.

Create `args_demo.sh`:

```bash
#!/bin/bash

echo "Script name    : $0"
echo "First argument : $1"
echo "Second argument: $2"
echo "All arguments  : $@"
echo "Argument count : $#"
```

Make it executable and run it with different numbers of arguments:

```bash
chmod +x args_demo.sh
./args_demo.sh case/logs/auth.log
./args_demo.sh case/logs/auth.log case/logs/access.log
./args_demo.sh
```

| Variable        | Meaning                          |
| --------------- | -------------------------------- |
| `$0`            | The name of the script itself    |
| `$1`, `$2`, ... | The first, second, ... arguments |
| `$#`            | The number of arguments supplied |
| `$@`            | All arguments, as separate words |

**Worked example — wildcards are expanded before your script runs.** Try:

```bash
./args_demo.sh case/logs/*.log
```

`$#` reports `3`. Your script never sees the `*` — the shell expands `case/logs/*.log` into three filenames first, then passes them as three arguments. This is why wildcards work with every command, including your own scripts.

**Worked example — arguments with spaces.** Arguments containing spaces must be quoted when the script is called:

```bash
#!/bin/bash

echo "You gave me: $1"
echo "Argument count: $#"
```

Save as `one_arg.sh` and run it two ways:

```bash
./one_arg.sh Failed password
./one_arg.sh "Failed password"
```

The first call passes **two** arguments (`Failed` and `password`), so `$#` is `2`. The second passes **one**. The same rule applies inside a script: always write `"$1"`, `"$LOGFILE"` and so on.

**Worked example — a search tool that takes two arguments.**

```bash
#!/bin/bash

LOGFILE=$1
KEYWORD=$2

echo "Searching for '$KEYWORD' in $LOGFILE..."
grep "$KEYWORD" "$LOGFILE"
```

Save as `search.sh` and try:

```bash
./search.sh case/logs/auth.log "Failed password for root"
./search.sh case/logs/access.log sqlmap
./search.sh case/logs/firewall.log BLOCK
```

## Exercise 2

1. Run `args_demo.sh` with three arguments. What does `$3` show? What does `$#` show?
2. Run it with no arguments. What do `$1` and `$#` show?
3. Why might a script need to check `$#` before using `$1`?
4. Run `./args_demo.sh case/*` and explain the value of `$#`. 
5. Run `search.sh` with the keyword `Accepted password` both with and without quotes, and record how the behaviour differs.
6. Use `search.sh` to find every line in any of the three logs that mentions `203.0.113.200`. How many of the three files did you have to search, and in which did it appear?

# Part 4: Exit Codes

Every command, and every script, returns an **exit code** when it finishes: `0` for success, and any non-zero value for some kind of failure.

Check the exit code of the last command with `$?`:

```bash
grep "eve" intel/users.csv
echo "Exit code: $?"

grep "mallory" intel/users.csv
echo "Exit code: $?"
```

A script sets its own exit code with `exit`:

```bash
#!/bin/bash

if [ -f case/logs/auth.log ]; then
    echo "Found auth.log"
    exit 0
else
    echo "auth.log not found"
    exit 1
fi
```

Save this as `check_file.sh`, make it executable, run it, then check the result:

```bash
./check_file.sh
echo "Exit code: $?"
```

- `[ -f filename ]` tests whether a regular file exists. 
- `exit 0` signals success. Any other number signals a particular kind of failure.
- If a script has no explicit `exit`, it finishes with the exit code of its last command.

**Worked example — several failure reasons, several exit codes.** Create `validate_file.sh`:

```bash
#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Error: no filename supplied" >&2
    exit 1
fi

if [ ! -f "$1" ]; then
    echo "Error: '$1' does not exist" >&2
    exit 2
fi

if [ ! -r "$1" ]; then
    echo "Error: '$1' exists but cannot be read" >&2
    exit 3
fi

if [ ! -s "$1" ]; then
    echo "Error: '$1' is empty" >&2
    exit 4
fi

echo "'$1' looks fine — $(wc -l < "$1") lines"
exit 0
```

Test every path:

```bash
./validate_file.sh ; echo "Exit code: $?"
./validate_file.sh case/logs/missing.log ; echo "Exit code: $?"
./validate_file.sh case/evidence/empty.bin ; echo "Exit code: $?"
./validate_file.sh case/logs/auth.log ; echo "Exit code: $?"
```

`[ ! -s "$1" ]` is true when the file is empty. `empty.bin` is the empty file.

**Standard output and standard error.** Notice every error message ends in `>&2`. That sends the message to **standard error** instead of **standard output**. Try:

```bash
./validate_file.sh case/logs/missing.log > result.txt
cat result.txt
```

The error still appears on your screen, and `result.txt` is empty. Redirecting with `>` only captures standard output, so errors stay visible to the person running the script, and never end up mixed into a report file. Use `>&2` for every error message from now on. (This also answers Lab 5, Exercise 6.2: `read -p` writes its prompt to standard error.)

**Worked example — exit codes from `diff`.** Standard tools use exit codes too. `diff` exits with `0` if two files are identical, `1` if they differ, and `2` if something went wrong (such as a missing file). `-q` makes it quiet:

```bash
diff -q case/config-old.txt case/config-new.txt ; echo "Exit code: $?"
diff -q case/config-old.txt case/config-old.txt ; echo "Exit code: $?"
diff -q case/config-old.txt case/nothing.txt ; echo "Exit code: $?"
```

Create `config_drift.sh`, which reports configuration drift between two files and passes `diff`'s exit code on to its caller:

```bash
#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: $0 <baseline_config> <current_config>" >&2
    exit 2
fi

diff -u "$1" "$2"
STATUS=$?

echo ""
echo "diff exit code: $STATUS (0 = identical, 1 = drift, 2 = error)"
exit $STATUS
```

Run it on the two configurations you compared in Lab 4, then on a backup versus a live configuration:

```bash
./config_drift.sh case/config-old.txt case/config-new.txt
./config_drift.sh case/backups/config.old case/configs/app.conf
```

`STATUS=$?` must come **immediately** after `diff`. Any command in between (even an `echo`) would replace `$?` with its own exit code.

**Worked example — chaining with `&&` and `||`.**

```bash
./validate_file.sh case/logs/auth.log && echo "Proceeding with analysis..."
./validate_file.sh case/logs/missing.log || echo "Stopping — validation failed."
```

`&&` runs the next command only if the first **succeeded** (exit code `0`). `||` runs the next command only if the first **failed**.

## Exercise 3

1. Run `check_file.sh` from inside the `case` directory (`cd case; ../check_file.sh; cd ..`). What exit code do you get, and why?
2. Why is it useful for a script to return different exit codes rather than just printing an error message?
3. Run `validate_file.sh` all four ways shown above and record each exit code.
4. Run `./validate_file.sh case/logs/missing.log 2> errors.txt` and then `cat errors.txt`. What does `2>` do?
5. Run `config_drift.sh` on `case/backups/config.old` and `case/configs/app.conf`. List every setting that differs. Which change would a security reviewer care about most, and why?
6. Write a one-line chain using `config_drift.sh` and `&&`/`||` that prints `NO DRIFT` or `DRIFT DETECTED` (and hides the `diff` output with `> /dev/null`). Test it on identical and different files.

# Part 5: Build Your First Useful Script — `logstats.sh`

Now combine shebangs, variables, arguments, command substitution and exit codes into one script.

**Goal:** a script that takes a log filename as `$1` and prints basic statistics about it.

Create `logstats.sh`:

```bash
#!/bin/bash

# logstats.sh - print basic statistics for a log file
# Usage: ./logstats.sh <logfile>

if [ $# -ne 1 ]; then
    echo "Usage: $0 <logfile>" >&2
    exit 1
fi

LOGFILE=$1

if [ ! -f "$LOGFILE" ]; then
    echo "Error: file '$LOGFILE' not found" >&2
    exit 2
fi

LINE_COUNT=$(wc -l < "$LOGFILE")
WORD_COUNT=$(wc -w < "$LOGFILE")
CHAR_COUNT=$(wc -c < "$LOGFILE")
FIRST_LINE=$(head -n 1 "$LOGFILE")
LAST_LINE=$(tail -n 1 "$LOGFILE")

echo "Log file        : $LOGFILE"
echo "Total lines     : $LINE_COUNT"
echo "Total words     : $WORD_COUNT"
echo "Total characters: $CHAR_COUNT"
echo "First line      : $FIRST_LINE"
echo "Last line       : $LAST_LINE"

exit 0
```

Make it executable and run it on every collected log:

```bash
chmod +x logstats.sh
./logstats.sh case/logs/auth.log
./logstats.sh case/logs/access.log
./logstats.sh case/logs/firewall.log
```

Then test the error handling:

```bash
./logstats.sh ; echo "Exit code: $?"
./logstats.sh case/logs/missing.log ; echo "Exit code: $?"
```

**Worked example — the same script on different data.** Because the log file is an argument, the script works on any log without changing a single line. Run it on the full server log from Lab 3:

```bash
./logstats.sh ../lab03-data/auth.log
```

Compare the first and last lines with those of `case/logs/auth.log`. The collected log covers roughly 08:00 to 08:46; the server log runs until after 10:00. The collected copy is only the **first part** of the server log — it was taken before the attack had finished.

**Worked example — extending the statistics.** Add this block just before the `echo "Log file ..."` lines:

```bash
LONGEST_LINE=$(awk '{ print length }' "$LOGFILE" | sort -rn | head -n 1)
FAILED=$(grep -c "Failed password" "$LOGFILE")
```

and these lines with the other `echo` lines:

```bash
echo "Longest line    : $LONGEST_LINE characters"
echo "Failed logins   : $FAILED"
```

Run the script against all three collected logs again. A working script tends to grow one small, tested block at a time.

## Exercise 4

1. Run `logstats.sh` against `intel/users.csv` and `intel/iocs.txt`. Does it still work sensibly? Why or why not?
2. Explain what each of the two `if` blocks near the top of the script is checking, and why they are ordered the way they are.
3. Why does the script use `"$LOGFILE"` (with quotes) throughout?
4. Add the extension block. What does `Failed logins` report for `firewall.log`? Is `0` the correct answer?
5. Use `logstats.sh` to fill in this table in `investigation.txt`:

```text
File                      Lines   Failed logins   First timestamp   Last timestamp
case/logs/auth.log
../lab03-data/auth.log
```

# Part 6: Extend `logstats.sh` with `read`

After the statistics, ask the user for a keyword and report how many lines contain it.

Add this before the final `exit 0`:

```bash
read -p "Enter a keyword to search for (or press Enter to skip): " KEYWORD

if [ -n "$KEYWORD" ]; then
    MATCH_COUNT=$(grep -c "$KEYWORD" "$LOGFILE")
    echo "Lines containing '$KEYWORD': $MATCH_COUNT"
fi
```

- `[ -n "$KEYWORD" ]` tests whether the variable is **non-empty**, so the search is skipped if the user just presses Enter.

Test it:

```bash
./logstats.sh case/logs/auth.log
```

Try keywords such as `Failed`, `Accepted`, `root` and `198.51.100.77`.

Without a loop, a user who wants to search for three keywords has to re-run the whole script three times. 

## Exercise 5

1. Run the updated script against `case/logs/access.log` and search for `sqlmap`.
2. What would happen if you used `[ -z "$KEYWORD" ]` instead of `[ -n "$KEYWORD" ]`? Adjust the script to confirm.
3. Modify the script so it prints the exit code of the `grep -c` command immediately after it runs. What exit code do you get for a keyword with no matches? Why might that surprise you, given that `grep -c` still printed `0`?
4. Modify the prompt handling so that if `MATCH_COUNT` is `0`, it prints `No matches found.` instead.

# Part 7: Common Mistakes and Debugging

| Symptom                                              | Likely cause                                                                              | Fix                                                                                  |
| ---------------------------------------------------- | ----------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| `$#` is higher than expected                         | An unquoted argument containing spaces was split, or a wildcard expanded to several files | Quote the argument: `"Failed password"`; check what the wildcard matches with `echo` |
| Variable holds nothing after `$(...)`                | The command inside `$(...)` failed or printed nothing                                     | Run the command on its own first to check its output                                 |
| `[: -ne: unary operator expected`                    | A variable used in a test was empty or unset                                              | Quote variables in tests; confirm arguments were passed                              |
| Script always takes the "file not found" branch      | Wrong relative path — you are not in the directory you think you are                      | Run `pwd` and `ls -l`; paths in this lab start with `case/`                          |
| Error messages end up inside your report file        | Errors were printed to standard output                                                    | Send error messages to standard error with `>&2`                                     |
| Exit code is always `0`, even after an error message | The script prints an error but never calls `exit` with a non-zero number                  | Add an explicit `exit N` immediately after the error message                         |
| Exit code is not what you expected                   | Another command ran between the one you care about and `$?`                               | Save `$?` into a variable immediately: `STATUS=$?`                                   |

**Worked example — a script that "lies" about failing.**

```bash
#!/bin/bash

if [ ! -f "$1" ]; then
    echo "Error: file not found"
fi

echo "Continuing anyway..."
exit 0
```

Save as `buggy.sh`, run it against a missing file, and check `$?`. Even though it printed an error, the exit code is `0` — a caller using `&&` or `||` would think everything was fine. Fix it by sending the message to `>&2` and adding `exit 1` on the next line.

## Exercise 6

1. Reproduce at least two rows from the table above using deliberately broken copies of your own scripts.
2. Fix `buggy.sh` and confirm `./buggy.sh missing.txt && echo "ok" || echo "failed"` prints `failed`.
3. Look back at `logstats.sh`. Is there any path where an error is printed but the script does not `exit` with a non-zero code? If so, fix it.

# Part 8: Investigation Challenge

Write a script called `attacker_report.sh` that:

1. Takes a log filename as `$1`.
2. Exits with code `1` and a usage message on standard error if no argument is given.
3. Exits with code `2` if the file does not exist.
4. Prints the total number of `Failed password` events (`0` if none).
5. Prints the single IP address responsible for the most failed attempts.
6. Prints the three busiest source IPs, reusing `top3.sh`.
7. Prints the three most-targeted usernames .
8. Exits `0` on success.

Run it three times and save the output:

```bash
./attacker_report.sh case/logs/auth.log > report-collected.txt
./attacker_report.sh ../lab03-data/auth.log > report-server.txt
./attacker_report.sh case/logs/access.log > report-web.txt
```

In `investigation.txt`, record:

1. The top attacker and top three attackers in the **collected** log, and in the **server** log. Is the ranking the same? Would the collected log alone have given you the right answer to "who attacked most?"
2. The **complete** list of targeted usernames in the server log (not just the top three — temporarily remove `head`). Does the word `invalid` appear as a "username"? Find the line responsible with `grep invalid ../lab03-data/auth.log` and explain why your pipeline picked up the wrong word.
3. What `attacker_report.sh` printed for `access.log`. Is the output wrong, or just not meaningful? What would you change?
4. Run `grep BLOCK case/logs/firewall.log`. Two of the top SSH attackers were blocked by the firewall on port 22, yet they still appear in `auth.log`. Suggest two possible explanations.

# Part 9: Concepts and Commands Covered

You should now be comfortable with:

```text
$(command)            command substitution
$(cmd1 | cmd2)        command substitution with a pipeline
$0 $1 $2 $# $@        script name and arguments
exit N                setting an exit code
$?                    the exit code of the last command
STATUS=$?             saving an exit code before it is overwritten
[ -f file ]           testing whether a regular file exists
[ -s file ]           testing whether a file is non-empty
[ -n "$VAR" ]         testing whether a variable is non-empty
echo "..." >&2        writing to standard error
2> file               redirecting standard error
diff -q               comparing files by exit code only
cmd1 && cmd2          run cmd2 only if cmd1 succeeded
cmd1 || cmd2          run cmd2 only if cmd1 failed
```

# Part 10: Commit Your Work

Do **not** modify anything in `case/` or `intel/`.

Commit your scripts (`top3.sh`, `nested_sub.sh`, `args_demo.sh`, `one_arg.sh`, `search.sh`, `check_file.sh`, `validate_file.sh`, `config_drift.sh`, `logstats.sh`, `buggy.sh`, `attacker_report.sh`), your three `report-*.txt` files and `investigation.txt`.

Suggested commit:

```text
Complete Lab 6
```

Push your changes to GitHub.



# End of Lab 6
