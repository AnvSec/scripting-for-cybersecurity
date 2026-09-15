I’d annotate it like this rather than just writing “Exercise 5 — Redirection.” The lab is specifically trying to build your understanding of commands, variables, quoting, redirection, pipes, and command substitution, so those are the things worth explaining in the comments.

#!/bin/bash

# ============================================================
# LAB 02 - INTRODUCTION TO THE LINUX COMMAND LINE
#
# These notes explain WHY the commands used in each exercise
# behave the way they do.
#
# Linux commands generally follow this structure:
#
# command [option] [argument]
#
# Example:
# ls -l /workspaces
#
# ls          = command
# -l          = option that changes the command's behaviour
# /workspaces = argument telling the command what to work on
# ============================================================


# ------------------------------------------------------------
# EXERCISE 1 - BASIC COMMANDS
# ------------------------------------------------------------

# Linux has many small commands which each perform one specific
# task. This is part of the Unix/Linux philosophy:
#
# "Small commands can be combined to perform larger tasks."
#
# whoami:
# Asks the operating system which user account is currently
# executing commands in this shell session.
#
# hostname:
# Displays the hostname assigned to the Linux machine.
# A hostname identifies the computer on the system/network.
#
# date:
# Reads and displays the system's current date and time.
#
# pwd:
# Means "Print Working Directory".
# The shell always has a current directory, and pwd displays
# its absolute path.
#
# My commands:


# ------------------------------------------------------------
# EXERCISE 2 - EXPLORING ls
# ------------------------------------------------------------

# ls means "list".
# By itself it lists visible files and directories in the
# current working directory.
#
# Linux commands can accept OPTIONS.
# Options normally begin with a hyphen (-).
#
# -l:
# Produces a "long listing".
# This gives extra information such as permissions, owner,
# file size and modification time.
#
# -a:
# Means "all".
# Linux normally hides files whose names begin with a dot (.).
# Using -a tells ls to include these hidden files.
#
# Example hidden file/directory:
#
# .git
#
# Options can also be combined.
#
# ls -la
#
# is effectively asking ls for both:
# - long/detailed output
# - all files including hidden ones
#
# My commands:

That matches what the lab is teaching about ls and hidden files.

# ------------------------------------------------------------
# EXERCISE 3 - NAVIGATION
# ------------------------------------------------------------

# cd means "Change Directory".
# It changes the shell's current working directory.
#
# Linux uses some special path symbols:
#
# .   = current directory
# ..  = parent directory
# ~   = user's home directory
#
# Therefore:
#
# cd ..
#
# means:
# "change directory to the parent of my current directory."
#
# pwd is useful after moving because it lets us verify
# exactly where we are.
#
# IMPORTANT:
# cd ~ moves to the user's HOME directory.
# In GitHub Codespaces this may be outside the Git repository,
# meaning files created there may not be tracked by Git.
#
# My commands:

The lab specifically warns about ~ because your coursework should remain under the repository.

# ------------------------------------------------------------
# EXERCISE 4 - CREATING A WORKSPACE
# ------------------------------------------------------------

# mkdir means "Make Directory".
# It creates a new directory in the filesystem.
#
# touch can create an empty file.
#
# For example:
#
# touch example.txt
#
# If example.txt does not exist, Linux creates an empty file.
#
# touch can also create several files at once because each
# filename is passed to the command as another argument.
#
# Example:
#
# touch file1.txt file2.txt file3.txt
#
# My commands:

touch is introduced in the lab specifically for creating the files used later.

# ------------------------------------------------------------
# EXERCISE 5 - OUTPUT REDIRECTION
# ------------------------------------------------------------

# Normally the output of a command is printed to the terminal.
#
# Redirection allows us to send that output somewhere else,
# such as into a file.
#
# >
#
# redirects output into a file.
#
# IMPORTANT:
# If the file already contains data, > REPLACES it.
#
# Example:
#
# date > example.txt
#
# This writes the output from date into example.txt.
#
#
# >>
#
# also redirects output into a file, but APPENDS it.
#
# This means existing data is kept and the new output is
# added to the end of the file.
#
# Example:
#
# date >> example.txt
#
# A useful way of remembering this:
#
# >   = write/replace
# >>  = add/append
#
# cat:
# Displays the contents of a text file in the terminal.
#
# My commands:

That distinction between > and >> is one of the main concepts in the exercise.

# ------------------------------------------------------------
# EXERCISE 6 - GETTING HELP
# ------------------------------------------------------------

# Linux has built-in documentation because nobody is expected
# to remember every command and every option.
#
# Many commands support:
#
# command --help
#
# Example:
#
# ls --help
#
# This displays a summary of the command and its options.
#
#
# man:
# Means "manual".
#
# Example:
#
# man ls
#
# opens the manual page for ls.
#
# Useful controls inside man:
#
# Arrow keys = scroll
# Space      = next page
# /word      = search for a word
# q          = quit
#
# The important skill here isn't memorising every ls or mkdir
# option. It is knowing how to find the option you need.
#
# My answers/commands:

That is exactly the intended lesson—the lab says finding help is more important than memorising every option.

# ------------------------------------------------------------
# EXERCISE 7 - SHELL VARIABLES
# ------------------------------------------------------------

# A shell variable stores a value temporarily so that it can
# be reused later.
#
# General format:
#
# variable=value
#
# Example:
#
# course="Cybersecurity"
#
# IMPORTANT:
# There must be NO spaces around the = symbol.
#
# Correct:
# name="Alex"
#
# Incorrect:
# name = "Alex"
#
# Bash interprets spaces as separators between commands and
# arguments, so adding spaces changes the meaning completely.
#
# To retrieve the value stored in a variable we use $.
#
# Example:
#
# echo "$course"
#
# $course means:
# "substitute the value stored in the variable course here."
#
# My variables/command:

The no-spaces rule around = is explicitly highlighted in the lab.

# ------------------------------------------------------------
# EXERCISE 8 - ENVIRONMENT VARIABLES
# ------------------------------------------------------------

# Environment variables are variables already provided by the
# operating system/shell environment.
#
# Examples include:
#
# USER  = current user
# HOME  = user's home directory
# SHELL = configured shell
# PATH  = directories searched for executable programs
#
# env:
# Displays environment variables available to the current
# process/shell.
#
#
# PATH is particularly important.
#
# When we type:
#
# ls
#
# we do not normally type the full path to the ls program.
#
# Instead, Linux searches through the directories stored
# inside the PATH environment variable until it finds the
# executable.
#
# My commands:

The lab then connects $PATH directly to why you can type ls instead of its full path.

# ------------------------------------------------------------
# EXERCISE 9 - FINDING COMMANDS
# ------------------------------------------------------------

# which:
# Shows the executable that the shell will use for a command.
#
# Example:
#
# which ls
#
# might display:
#
# /usr/bin/ls
#
# This links back to PATH.
#
# Linux searched PATH, found the ls executable and "which"
# allows us to see where that executable is located.
#
# My commands:
# ------------------------------------------------------------
# EXERCISE 10 - QUOTING
# ------------------------------------------------------------

# Quoting changes how Bash interprets text.
#
#
# DOUBLE QUOTES " "
#
# Double quotes allow variable expansion.
#
# Example:
#
# animal="fox"
# echo "The $animal is running"
#
# Bash sees $animal and replaces it with the value stored
# inside the variable.
#
#
# SINGLE QUOTES ' '
#
# Single quotes normally make Bash treat the contents
# literally.
#
# Example:
#
# echo 'The $animal is running'
#
# Here $animal is not expanded.
# Bash prints the actual characters "$animal".
#
#
# Easy rule:
#
# " " = variables still work
# ' ' = treat the text literally
#
# My prediction/results:

The difference between single and double quotes is one of the core concepts in Exercise 10.

# ------------------------------------------------------------
# EXERCISE 11 - COMMAND SUBSTITUTION
# ------------------------------------------------------------

# Command substitution allows the OUTPUT of a command to be
# used as a value.
#
# Syntax:
#
# $(command)
#
# Example:
#
# username=$(whoami)
#
# Bash performs these steps:
#
# 1. Run whoami
# 2. Capture its output
# 3. Store that output inside username
#
# We can then use:
#
# echo "$username"
#
# This is useful because we do not have to manually type
# information that the operating system already knows.
#
# My commands:

That $(command) behavior is explicitly defined in the lab as “run the command and substitute its output here.”

# ------------------------------------------------------------
# EXERCISE 12 - COMMAND-LINE EDITING
# ------------------------------------------------------------

# The shell stores command history and provides shortcuts
# which make working in the terminal faster.
#
# Tab:
# Attempts to automatically complete commands, filenames or
# directory names.
#
# Up Arrow:
# Recalls the previous command.
#
# Ctrl + R:
# Searches backwards through command history.
#
# Ctrl + A:
# Moves the cursor to the beginning of the command line.
#
# Ctrl + E:
# Moves the cursor to the end of the command line.
#
# Ctrl + U:
# Deletes text towards the beginning of the line.
#
# Ctrl + K:
# Deletes text towards the end of the line.
#
# Ctrl + C:
# Stops the currently running command/process.
#
# Ctrl + L:
# Clears the terminal screen.
#
# These are shell controls rather than normal Linux programs,
# so this exercise is mainly practised interactively.

Those shortcut definitions come directly from the lab's command-line editing section.

# ------------------------------------------------------------
# EXERCISE 13 - PIPES AND COUNTING
# ------------------------------------------------------------

# The pipe symbol is:
#
# |
#
# A pipe takes the OUTPUT from the command on its left and
# uses it as the INPUT for the command on its right.
#
# General idea:
#
# command1 | command2
#
# Instead of command1 printing everything directly to the
# terminal, command2 receives that data.
#
#
# wc:
# Means "word count".
#
# wc can count lines, words and characters.
#
# -l tells wc to count lines.
#
# Therefore:
#
# something | wc -l
#
# means:
#
# 1. run "something"
# 2. send its output through the pipe
# 3. count how many lines were produced
#
# My commands/results:

The lab introduces pipes this way before using wc -l to count command output.

# ------------------------------------------------------------
# EXERCISE 14 - grep
# ------------------------------------------------------------

# grep searches text for matching patterns.
#
# Example idea:
#
# command | grep word
#
# The first command produces information.
#
# The pipe sends that information into grep.
#
# grep then keeps only lines containing the requested word.
#
# Example:
#
# env | grep USER
#
# env generates environment variable information.
# grep receives that information and filters it so only lines
# containing USER remain.
#
#
# Several tools can be chained together:
#
# command | grep something | wc -l
#
# This means:
#
# 1. Generate some output
# 2. Keep matching lines
# 3. Count the remaining lines
#
# My commands/results:

That's also the cybersecurity-relevant bit: filtering lots of output down to the lines you care about.

# ------------------------------------------------------------
# EXERCISE 15 - PIPELINE CHALLENGE
# ------------------------------------------------------------

# Pipelines combine several simple Linux commands into one
# larger operation.
#
# Read pipelines LEFT TO RIGHT.
#
# Example structure:
#
# command1 | command2 | command3
#
# command1 produces data.
# command2 processes/filters that data.
# command3 performs another operation on the result.
#
#
# Example concept:
#
# ls /somewhere | grep something | wc -l
#
# Step 1:
# List entries.
#
# Step 2:
# Keep entries containing a particular pattern.
#
# Step 3:
# Count how many matched.
#
# This demonstrates the Linux philosophy of combining small,
# specialised programs instead of requiring one huge command
# to perform every operation.
#
# My commands/results:

The lab explicitly teaches reading pipelines left-to-right in exactly this way.

# ------------------------------------------------------------
# EXERCISE 16 - BUILDING A SIMPLE REPORT
# ------------------------------------------------------------

# Here we combine several concepts from the lab:
#
# VARIABLES
# Store values for later use.
#
# COMMAND SUBSTITUTION
# Obtain those values automatically from Linux using:
#
# $(command)
#
# PIPES
# Send output from one command to another.
#
# VARIABLE EXPANSION
# Insert stored values into text using:
#
# $variable
#
#
# Example pattern:
#
# value=$(some_command)
# echo "Result: $value"
#
# Bash performs this in roughly this order:
#
# 1. Run some_command
# 2. Capture its output
# 3. Store it in value
# 4. Expand $value inside the echo command
# 5. Print the final line
#
# This is the beginning of actual shell scripting:
# gathering information automatically, storing it,
# processing it and presenting the result.
#
# My report commands:

Exercise 16 deliberately combines username, hostname, current directory, and a count obtained from commands rather than manually entered values.

One thing I'd add to your GitHub repo

Don't be afraid of quite a lot of comments at this stage. For coursework like this, something like:

# grep filters text and keeps only lines matching the pattern.
# The pipe passes the output of ls into grep instead of
# printing the unfiltered ls output directly.
ls /usr/bin | grep python

is actually useful.

Later, once you're comfortable with Linux, you'd probably reduce that to:

# Find Python-related executables
ls /usr/bin | grep python

But right now your repo can basically become your Linux cheat sheet + evidence that you understand the exercises, which is way more useful for studying than just having the finished commands.