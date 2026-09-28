# Lab 5: From Commands to Scripts — Shebangs, Variables and Input

## Introduction

In Lab 4 you triaged a collected directory tree by typing `find`, `file`, `grep` and `wc` commands one at a time. Every one of those commands had to be re-typed (or recalled from history) each time you wanted to run it again, and your `triage-report.txt` was assembled by hand, line by line.

In this lab you will start saving commands into **`.sh` files**: reusable shell scripts. You will learn how a script is structured, how to make it executable, and how to give it variables and simple input. By the end of the lab you will have a script that rebuilds your Lab 4 triage report automatically.

In Lab 6 you will extend what you build here with command substitution, command-line arguments and exit codes.

**Case question for this lab:** can the Lab 4 triage be repeated exactly, by anyone, with a single command?

## Objectives

By the end of this lab, you should be able to:

1. Explain the difference between typing commands interactively and saving them in a script.
2. Write a correct shebang line and explain what it does.
3. Make a script executable and run it.
4. Declare and use variables inside a script, including simple arithmetic.
5. Read input from the user with `read`, including multiple values and hidden input.
6. Recognise and fix the most common beginner mistakes in a new script.

# Part 1: Prepare Your Lab Directory

From this lab onwards, every lab uses the **same working layout**:

- `case/` — a copy of the Lab 4 collection (`lab04-data`). This is your evidence. **Never modify it.**
- `intel/` — the threat-intelligence list and account list from Lab 3 (`iocs.txt`, `users.csv`).

Open your `scripting-for-cybersecurity` Codespace and return to the repository root (the directory that contains `lab03-data` and `lab04-data`):

```bash
cd /workspaces/scripting-for-cybersecurity
```

If your repository has a different name, `cd` to its root instead.

Create the lab directory and copy the data:

```bash
mkdir lab05
cp -r lab04-data lab05/case
mkdir lab05/intel
cp lab03-data/iocs.txt lab03-data/users.csv lab05/intel/
cd lab05
```

Check the result:

```bash
ls
ls case
ls intel
```

You should have:

```text
lab05/
├── case/
│   ├── backups/  configs/  docs/  evidence/  logs/  nested/  scripts/
│   ├── config-new.txt
│   └── config-old.txt
└── intel/
    ├── iocs.txt
    └── users.csv
```

Your own scripts go directly in `lab05/`, next to `case/` and `intel/`.

# Part 2: Interactive Commands vs Scripts

So far, every command you have run has been typed directly at the prompt. That works, but:

- it is **not repeatable** without retyping or digging through history;
- it **cannot easily be shared** with someone else;
- it **cannot take input** in a structured way;
- it **cannot report success or failure** to whatever called it.

A **shell script** is a plain text file containing a sequence of commands, saved so it can be run as a single unit.

**Worked example 1 — your first script.** Create a file called `hello.sh`:

```bash
nano hello.sh
```

Enter:

```bash
#!/bin/bash
echo "Hello, $(whoami). Today is $(date)."
```

Save and exit. `$(whoami)` and `$(date)` are **command substitution**, which you met in Lab 2: they insert the output of a command into the text.

Run it two different ways:

```bash
bash hello.sh
```

```bash
./hello.sh
```

**Worked example 2 — replaying Lab 4 as a script.** A script is not limited to one line. Create `case_overview.sh`, which repeats the first steps of your Lab 4 triage:

```bash
#!/bin/bash
echo "Directories in the collection:"
find case -type d
echo ""
echo "Log files:"
ls case/logs
echo ""
echo "Size of the collection:"
du -sh case
echo "Done."
```

Run it with `bash case_overview.sh`. Every line runs **in order, top to bottom**, exactly as if you had typed each command yourself. This is the core idea behind scripting: a script is a recorded transcript of commands that the shell replays for you.

## Exercise 1

1. What happens when you run `bash hello.sh`?
2. What happens when you try `./hello.sh` without changing permissions first?
3. What error message did you get, and what do you think it means?
4. Add a command to `case_overview.sh` that prints the number of regular files in `case` (you used `find ... | wc -l` for this in Lab 4). Re-run it and confirm the new line appears in the correct position.
5. Swap the "Log files" and "Size" sections and re-run. Confirm the output order changes to match — a script runs strictly top to bottom.

# Part 3: The Shebang Line

The first line of `hello.sh`:

```bash
#!/bin/bash
```

is called the **shebang**. It tells the operating system which interpreter should run the rest of the file.

- `#!/bin/bash` — run this file using the Bash shell.
- `#!/usr/bin/env bash` — find `bash` using the user's `PATH` instead of assuming it is at `/bin/bash`. This is more portable across systems.
- `#!/usr/bin/python3` — the same idea, for a Python script.
- `#!/bin/sh` — run using the more limited, POSIX-only `sh` shell. It does not support everything Bash does.

The shebang **must be the very first line** of the file, with no blank line above it, and must start with `#!`.

**Worked example — the shebang is evidence, too.** In Lab 4 you ran `file` against the collected scripts. Run it again:

```bash
file case/scripts/*
head -n 1 case/scripts/check.sh
head -n 1 case/scripts/scan.py
```

`file` reports `check.sh` as a *Bourne-Again shell script*, but reports `scan.py` as plain *ASCII text*. The difference is the shebang: `check.sh` starts with `#!/bin/bash`, so `file` knows which interpreter it is written for. `scan.py` has no shebang, so `file` cannot tell it is Python — only the `.py` extension suggests it, and extensions can lie.

**Worked example — comparing interpreters.** Create two files with the same content but different shebangs:

```bash
echo '#!/bin/bash
echo "Testing lowercase conversion"
VAR="HELLO"
echo "${VAR,,}"' > bash_test.sh

echo '#!/bin/sh
echo "Testing lowercase conversion"
VAR="HELLO"
echo "${VAR,,}"' > sh_test.sh

chmod +x bash_test.sh sh_test.sh
./bash_test.sh
./sh_test.sh
```

`sh_test.sh` should fail with a "Bad substitution" error, because `${VAR,,}` (lowercase conversion) is a Bash feature (added in Bash 4.0), not a feature of the plainer `sh`. Check your Bash version with `echo $BASH_VERSION` if bash_test.sh  reports "bad substitution".

Without a shebang, `./script.sh` may run the file with an unexpected shell. Running it as `bash script.sh` works even without a shebang, because you are telling the shell explicitly which interpreter to use.

## Exercise 2

1. Remove the shebang line from `hello.sh` and try `./hello.sh` again. Can the script still run?
2. Restore the shebang line.
3. Change it to `#!/usr/bin/env bash` and confirm the script still runs.
4. Run `bash_test.sh` and `sh_test.sh`. Record the difference in behaviour and explain it in one sentence.
5. What does `which bash` show on your system? How does that relate to what `#!/bin/bash` assumes?
6. Using the `file` output above, explain in one or two sentences why an analyst should not rely on a file's extension alone to decide what language a script is written in.

# Part 4: Making a Script Executable

Check the current permissions:

```bash
ls -l hello.sh
```

You should see something like:

```text
-rw-r--r-- 1 you you 45 Sep 23 09:00 hello.sh
```

None of the three permission groups (owner, group, other) has the executable bit (`x`) set. That is why `./hello.sh` failed earlier.

Add execute permission:

```bash
chmod +x hello.sh
ls -l hello.sh
```

You should now see `x` in the permissions, e.g. `-rwxr-xr-x`.

Run it:

```bash
./hello.sh
```

**Note the `./` prefix.** Your current directory is not normally on your `PATH`, so Linux will not find `hello.sh` just by typing `hello.sh`. The `./` tells the shell explicitly "run the file in this directory".

**Worked example — permission levels compared.** `chmod` can grant permissions to different groups of people. Try each of these against a spare copy of `hello.sh`:

```bash
cp hello.sh perm_test.sh

chmod 744 perm_test.sh   # owner: read+write+execute; group/other: read only
ls -l perm_test.sh

chmod 700 perm_test.sh   # owner only; nobody else can even read it
ls -l perm_test.sh

chmod +x perm_test.sh    # adds execute for owner, group and other, on top of what is already set
ls -l perm_test.sh
```

The three-digit numeric form (`744`, `700`, ...) sets **all** permission bits at once: the first digit is the owner, the second is the group, the third is everyone else. Each digit is a sum of read (`4`), write (`2`) and execute (`1`). `chmod +x`, by contrast, only **adds** the execute bit and leaves everything else untouched.

**A safety rule for evidence.** Look at the collected scripts:

```bash
ls -l case/scripts
```

None of them is executable. That is a good thing. **Never make collected scripts executable and never run them** — you do not know what they do. Inspect them with `cat`, `head` or `file` instead. 

## Exercise 3

1. What command shows a file's current permissions?
2. Which `chmod` command adds executable permission?
3. Why does `./hello.sh` work but plain `hello.sh` does not?
4. Run `chmod 700 perm_test.sh` and then `cat perm_test.sh` as your own user. Does it work? Would it work for a different user on the system?
5. What numeric `chmod` value gives the owner read, write and execute, and gives the group and everyone else read-only access? Confirm your answer with `ls -l`.
6. Read `case/scripts/check.sh` with `cat`. Based on its content alone, is it likely to be harmful? Why is reading it still the correct first step, rather than running it?

# Part 5: Variables in Scripts

You have already used variables at the interactive prompt. Inside a script, they work the same way — but a script lets you build up several related values and reuse them.

Create `case_vars.sh`:

```bash
#!/bin/bash

CASE_DIR="case"
LOG_DIR="$CASE_DIR/logs"
EVIDENCE_DIR="$CASE_DIR/evidence"
ANALYST="analyst"

echo "Analyst      : $ANALYST"
echo "Case folder  : $CASE_DIR"
echo "Log folder   : $LOG_DIR"
echo "Evidence     : $EVIDENCE_DIR"
echo ""
echo "Contents of $LOG_DIR:"
ls "$LOG_DIR"
echo ""
echo "Backup file for this case would be: ${CASE_DIR}_backup.tar"
```

Make it executable and run it:

```bash
chmod +x case_vars.sh
./case_vars.sh
```

Points to notice:

- **No spaces** around `=` when assigning (`CASE_DIR="case"`, not `CASE_DIR = "case"`).
- Variables are read with a `$` prefix: `$CASE_DIR`.
- One variable can be built from another: `LOG_DIR="$CASE_DIR/logs"`. If the case folder is ever renamed, you only change **one line**.
- `${CASE_DIR}` (curly braces) is needed when the variable name would otherwise run into surrounding text, as in `${CASE_DIR}_backup.tar`. Try removing the braces: Bash then looks for a variable called `CASE_DIR_backup`, which does not exist.
- Always quote variables that hold paths: `ls "$LOG_DIR"`.

**Worked example — arithmetic with your Lab 4 results.** Bash treats variables as text by default, but you can do integer arithmetic with `$(( ))`. Open your Lab 4 `triage-report.txt` (in `../lab04/`) and copy the counts you found into `arithmetic_demo.sh`:

```bash
#!/bin/bash

PYTHON_FILES=2
SHELL_SCRIPTS=1
LOG_FILES=4
CONFIG_FILES=3
TOTAL_FILES=22

SCRIPTS=$((PYTHON_FILES + SHELL_SCRIPTS))
OTHER=$((TOTAL_FILES - SCRIPTS - LOG_FILES - CONFIG_FILES))
PERCENT_LOGS=$((LOG_FILES * 100 / TOTAL_FILES))

echo "Scripts (Python + shell) : $SCRIPTS"
echo "Logs                     : $LOG_FILES"
echo "Configuration files      : $CONFIG_FILES"
echo "Everything else          : $OTHER"
echo "Logs as % of all files   : $PERCENT_LOGS%"
```

If your Lab 4 numbers differ, use yours and check which is right with `find`.

Notice `$(( ))` is a **different** syntax from `$( )` (command substitution) — the double parentheses tell Bash to evaluate the contents as a maths expression, not run it as a command. Bash arithmetic is **integer only**: `4 * 100 / 22` gives `18`, not `18.18`.

## Exercise 4

1. Add a variable `CASE_REF` (for example `"CASE-2026-014"`) to `case_vars.sh` and print a sentence that uses `CASE_REF`, `ANALYST` and `CASE_DIR` together.
2. What happens if you write `CASE_DIR = "case"` with spaces around the `=`? Try it and record the error.
3. Change `CASE_DIR` to a folder that does not exist, such as `case2`, and run the script. Which lines fail, and which still print? What does this tell you about how Bash handles errors by default?
4. In `arithmetic_demo.sh`, add `PERCENT_SCRIPTS` and print it. Then change the order of operations to `LOG_FILES / TOTAL_FILES * 100`. Why is the answer now `0`?
5. What happens if you try `TOTAL=$((LOG_FILES + "abc"))`? Record the result and explain it.

# Part 6: Reading Input with `read`

Scripts can ask the user for input while running, using `read`.

Create `lookup_user.sh`:

```bash
#!/bin/bash

read -p "Enter a username to look up: " TARGET_USER
echo "Searching the account list for: $TARGET_USER"
grep "$TARGET_USER" intel/users.csv
```

Make it executable and run it, entering `alice`, then `eve`.

- `-p "..."` displays a prompt on the same line as the input.
- Whatever the user types is stored in the variable named after `read` — here, `TARGET_USER`.
- Always quote the variable (`"$TARGET_USER"`) when using it.

**Worked example — asking which evidence file to inspect.** Create `evidence_check.sh`:

```bash
#!/bin/bash

EVIDENCE_DIR="case/evidence"

echo "Files in $EVIDENCE_DIR:"
ls "$EVIDENCE_DIR"
echo ""
read -p "Which file do you want to identify? " NAME

echo "Detected type : $(file -b "$EVIDENCE_DIR/$NAME")"
echo "Size in bytes : $(wc -c < "$EVIDENCE_DIR/$NAME")"
```

Run it for `image.png`, then `suspicious.dat`. `file -b` prints the type without repeating the filename. This is the same check you did by hand in Lab 4, but now anyone can repeat it without remembering the commands.

**Worked example — reading several values at once.** `read` can fill more than one variable from a single line of input, splitting on whitespace:

```bash
#!/bin/bash

read -p "Enter a username and department, separated by a space: " USERNAME DEPT
echo "Username  : $USERNAME"
echo "Department: $DEPT"
```

Save as `read_two.sh` and try it with `eve Security`. If the user types more words than there are variables, the **last** variable absorbs everything left over — try `eve Security Operations Centre` and see what ends up in `$DEPT`.

**Worked example — hidden input.** For anything sensitive, `read -s` stops the input from being echoed to the screen:

```bash
#!/bin/bash

read -s -p "Enter a password to simulate: " PASSWORD
echo ""
echo "Password captured (length: ${#PASSWORD} characters)"
```

Save as `read_hidden.sh` and try it. `${#PASSWORD}` gives the **length** of the variable's contents without ever printing the password itself.

Now look at this:

```bash
cat case/evidence/passwords.txt
```

Someone stored credentials in a plain text file on this workstation. Hiding input on screen (`read -s`) is only one part of handling secrets safely; writing them to disk in plain text undoes all of it. 

## Exercise 5

1. Modify `lookup_user.sh` to also ask for a department, and search for lines that contain the department (use a second `grep` in a pipeline).
2. What happens in `lookup_user.sh` if the user presses Enter without typing anything? Why?
3. Run `evidence_check.sh` and enter a name that does not exist, such as `missing.txt`. What happens? 
4. Run `read_two.sh` with only one word of input. What ends up in `$DEPT`?
5. Write a script that asks for a username (visible) and then a password (hidden), and prints a message like `Credentials captured for alice (password length: 11)`. Never print the password itself.
6. Which two accounts have credentials in `case/evidence/passwords.txt`? Use `lookup_user.sh` to check whether each one is a current account in `intel/users.csv`, and extend `lookup_user.sh` to print  their role and status.

# Part 7: Putting It Together

Create `case_banner.sh`, combining variables and `read`:

```bash
#!/bin/bash

CASE_DIR="case"

read -p "Enter your analyst name: " ANALYST
read -p "Enter the case reference: " CASE_REF
read -p "Enter today's shift (day/night): " SHIFT

echo "======================================"
echo " Security Operations Session"
echo "======================================"
echo " Analyst   : $ANALYST"
echo " Case      : $CASE_REF"
echo " Evidence  : $CASE_DIR"
echo " Shift     : $SHIFT"
echo " Started   : $(date)"
echo " Host      : $(whoami)@$(hostname)"
echo "======================================"
```

Make it executable and run it.

**Worked example — an incident report header.** Create `incident_header.sh`:

```bash
#!/bin/bash

read -p "Enter an incident reference number: " REF
read -p "Enter the reporting analyst: " ANALYST
read -p "Enter a one-line summary: " SUMMARY

SEVERITY="UNCLASSIFIED"

echo "INCIDENT REPORT"
echo "----------------"
echo "Reference : $REF"
echo "Analyst   : $ANALYST"
echo "Summary   : $SUMMARY"
echo "Severity  : $SEVERITY (default — update by hand for now)"
echo "Logged at : $(date)"
```

This script mixes a variable you **assign directly** (`SEVERITY`) with variables you **read from the user** (`REF`, `ANALYST`, `SUMMARY`) — the two variable styles from Parts 5 and 6, used together.

## Exercise 6

1. Run `case_banner.sh` and confirm each value appears correctly in the banner.
2. Redirect the banner into a file: `./case_banner.sh > banner.txt`. What happens to the prompts? (Look carefully — the prompts from `read -p` are not written to `banner.txt`. ) Why?
3. In your own words, explain the difference between a variable you **assign** in a script and one you **read** from the user.
4. Modify `incident_header.sh` so that `SEVERITY` is also read from the user, and remove the "(default ...)" wording.

# Part 8: Common Mistakes and Debugging

As you start writing scripts, you will run into a handful of errors again and again.

| Symptom                                                    | Likely cause                                                                                            | Fix                                                                           |
| ---------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------- |
| `permission denied` when running `./script.sh`             | The file is not executable                                                                              | `chmod +x script.sh`                                                          |
| `command not found` when running `script.sh` (no `./`)     | Your current directory is not on `PATH`                                                                 | Run `./script.sh` instead                                                     |
| `/bin/bash^M: bad interpreter`                             | The file has Windows line endings (often from copy-pasting or uploading a file written on Windows)      | Convert it: `sed -i 's/\r$//' script.sh`                                      |
| `CASE_DIR: command not found` after `CASE_DIR = "case"`    | Spaces around `=`                                                                                       | Remove the spaces: `CASE_DIR="case"`                                          |
| A variable prints as empty                                 | The name was misspelled, or it was never assigned                                                       | Check spelling; `echo` the variable early to confirm it holds what you expect |
| `No such file or directory` for a path you are sure exists | You ran the script from a different directory, so a relative path like `case/logs` does not exist there | Run `pwd`; run the script from `lab05/`                                       |
| Script "hangs" with no prompt returned                     | A `read` is waiting for input                                                                           | Type something and press Enter, or Ctrl+C to cancel                           |

**Worked example — Windows line endings.** The row about `^M` deserves a closer look, because this dataset might contain a file with Windows line endings:

```bash
printf '#!/bin/bash\r\necho "Hello, World!"\r\n' > windows.sh
cat -A windows.sh | head -n 3
#find scan.py in case directory.
cat -A ./case/scripts/scan.py 
```

`cat -A` makes invisible characters visible. Lines in `windows.sh` end with `^M$` (a carriage return, then the end of line), while `scan.py` lines end with just `$`. For a data file this is usually harmless when you only `grep` it, but for a **script** it is fatal: the shebang becomes `#!/bin/bash\r`, and no interpreter with that name exists. 

**Worked example — deliberately breaking a script.**

```bash
cp case_vars.sh broken.sh
chmod -x broken.sh
./broken.sh
```

```bash
chmod +x broken.sh
broken.sh      # note: no ./ this time
```

Seeing these errors deliberately, once, makes them much faster to recognise later.

## Exercise 7

1. Reproduce at least three rows of the table above using spare copies of your scripts, and confirm the error message matches what is described.
2. Deliberately misspell a variable on one line only (e.g. `$LOG_DRI` instead of `$LOG_DIR`). Run the script. What happens, and why does Bash not treat this as an error the way a compiler might?
3. `cd case` and then run `../case_vars.sh`. Explain the result in terms of relative paths.

# Part 9: Investigation Challenge

In Lab 4 you built `triage-report.txt` by hand. Now write a script called `triage.sh` that rebuilds it automatically.

Your script must:

1. Store the case folder in a variable `CASE_DIR` and use that variable everywhere — no hard-coded `case/` paths anywhere else in the script.
2. Store the output filename in a variable `REPORT`, set to `triage-report-auto.txt`.
3. Ask the analyst for their name and a case reference with `read -p`.
4. Write a header to `$REPORT` containing the title, analyst, case reference and date.
5. Append the following, each calculated by a command (use `$(...)` and the Lab 4 commands):

```text
Total Files:
Total Directories:
Python Files:
Shell Scripts:
Log Files:
Configuration Files:
Empty Files:
Archives:
```

6. Append the list of files containing `admin` (`grep -rl`).
7. Append the detected file types of everything in the evidence folder (`file`).
8. Append a final line `Scripts (Python + shell): N`, where `N` is calculated with `$(( ))`. (Hint: store the Python and shell counts in variables first.)

Run it, then compare it with your Lab 4 report:

```bash
./triage.sh
cat triage-report-auto.txt
diff ../lab04/triage-report.txt triage-report-auto.txt
```

In `investigation.txt`, answer:

1. Which numbers in your Lab 4 report (if any) differ from the automated one? Which is correct, and why was the manual one wrong or different?
2. If `lab04-data` were replaced by a new collection tomorrow, what would you change in `triage.sh` to triage it? What would you have had to do with the Lab 4 approach?
3. Name one thing your triage report tells you about `case/evidence/suspicious.dat` that its filename does not.

# Part 10: Concepts and Commands Covered

You should now be comfortable with:

```text
#!/bin/bash           shebang line
chmod +x              making a script executable
chmod 744 / 700       numeric permission shorthand
./script.sh           running a script in the current directory
$VAR  ${VAR}          using a variable
VAR="value"           assigning a variable (no spaces around =)
${#VAR}               the length of a variable's value
$((expr))             integer arithmetic
read -p "..." VAR     reading user input
read -p "..." A B     reading multiple values into multiple variables
read -s -p "..." VAR  reading input without echoing it
file -b               file type without the filename
cat -A                showing invisible characters such as ^M
```

# Part 11: Commit Your Work

Do **not** modify anything in `case/` or `intel/`.

Commit your scripts (`hello.sh`, `case_overview.sh`, `bash_test.sh`, `sh_test.sh`, `case_vars.sh`, `arithmetic_demo.sh`, `lookup_user.sh`, `evidence_check.sh`, `read_two.sh`, `read_hidden.sh`, `case_banner.sh`, `incident_header.sh`, `triage.sh`), plus `triage-report-auto.txt`, `incident-passwords.txt` and `investigation.txt`. Please commit your notes as well.

Suggested commit:

```text
Complete Lab 5
```

Push your changes to GitHub.



# End of Lab 5
