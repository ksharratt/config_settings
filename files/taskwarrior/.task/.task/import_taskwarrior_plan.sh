#!/usr/bin/env bash
# Import Taskwarrior commands from a text file, safely.
# - Skips blank lines and lines starting with '#'
# - Logs every action to a timestamped logfile
# - Stops on first failure by default (use -c to continue on errors)
# - Dry-run with -n to preview without executing

set -Eeuo pipefail

usage() {
  echo "Usage: $0 [-n] [-c] plan.txt
  -n   dry run (do not execute commands)
  -c   continue on errors (default is stop on first error)
Examples:
  $0 -n rehab_plan.txt          # preview
  $0 rehab_plan.txt             # run and stop on first error
  $0 -c rehab_plan.txt          # run and skip failures"
  exit 1
}

DRY_RUN=0
CONTINUE=0
while getopts ":nc" opt; do
  case $opt in
    n) DRY_RUN=1 ;;
    c) CONTINUE=1 ;;
    *) usage ;;
  esac
done
shift $((OPTIND-1))

PLAN_FILE="${1:-}"
[[ -z "$PLAN_FILE" ]] && usage
[[ ! -f "$PLAN_FILE" ]] && { echo "No such file: $PLAN_FILE" >&2; exit 2; }

LOG="task_import_$(date +%Y%m%d_%H%M%S).log"
echo "Importing from: $PLAN_FILE" | tee -a "$LOG"
echo "Log file:       $LOG" | tee -a "$LOG"
(( DRY_RUN )) && echo "Mode: DRY-RUN (no commands executed)" | tee -a "$LOG"
(( CONTINUE )) && echo "Mode: CONTINUE on errors" | tee -a "$LOG"

LINE_NO=0
# Read all lines, including the last line if it lacks a trailing newline.
while IFS= read -r line || [ -n "$line" ]; do
  LINE_NO=$((LINE_NO+1))

  # Trim leading/trailing whitespace
  trimmed="$(printf '%s' "$line" | sed -e 's/^[[:space:]]\+//' -e 's/[[:space:]]\+$//')"

  # Skip blank lines and full-line comments
  [[ -z "$trimmed" || "${trimmed:0:1}" == "#" ]] && continue

  # Strip inline comments starting with '#' (outside quotes is hard; we just split at first '#')
  cmd="$(printf '%s' "$trimmed" | awk 'BEGIN{FS="#"} {print $1}')"
  # Re-trim after stripping inline comment
  cmd="$(printf '%s' "$cmd" | sed -e 's/[[:space:]]\+$//')"

  # Validate that the line starts with "task "
  if ! [[ "$cmd" =~ ^task[[:space:]]+ ]]; then
    echo "SKIP  Line $LINE_NO: does not start with 'task ' → $cmd" | tee -a "$LOG"
    continue
  fi

  if (( DRY_RUN )); then
    echo "DRY   Line $LINE_NO: $cmd" | tee -a "$LOG"
    continue
  fi

  echo "RUN   Line $LINE_NO: $cmd" | tee -a "$LOG"

  # Execute. We use eval to preserve quoted args as written in the file.
  # Only do this with a trusted file (yours). Output appended to the log.
  if ! eval "$cmd" >>"$LOG" 2>&1; then
    echo "FAIL  Line $LINE_NO: command exited non-zero. See $LOG for details." | tee -a "$LOG"
    if (( CONTINUE )); then
      continue
    else
      exit 3
    fi
  fi
done < "$PLAN_FILE"

echo "DONE  All eligible lines processed." | tee -a "$LOG"

