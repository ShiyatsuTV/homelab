# Bash — shared history across terminals

Configuration to share bash command history across multiple open terminals, instead of each session overwriting the history file on exit.

## What it does
- Appends commands to `~/.bash_history` rather than overwriting it.
- Increases history size.
- Removes duplicates and commands starting with a space.
- After every command, writes the current command to the history file and reloads it, so a command typed in one terminal is immediately visible in the others.

## Setup
Add the following block to `~/.bashrc`:
```bash
# Append commands to history instead of overwriting the file
shopt -s histappend

# History size
HISTSIZE=100000
HISTFILESIZE=200000

# Avoid duplicates and commands starting with a space
HISTCONTROL=ignoreboth:erasedups

# On every command:
# - append the current command to ~/.bash_history
# - reload history from ~/.bash_history
PROMPT_COMMAND="history -a; history -n; $PROMPT_COMMAND"
```

Reload the shell (open a new terminal or `source ~/.bashrc`) to apply.
