#!/usr/bin/env bash
# Dedupe Taskwarrior recurring parents by identical description.
# Keeps newest parent per description; deletes older parents and their children.
# No jq required. Uses `task ... export` + awk/grep/sort/xargs.
#
# Usage:
#   task_dedupe_recurring.sh [-n] [-y] [--] [optional task filters...]
# Examples:
#   ./task_dedupe_recurring.sh -n -- project:exercise.rehab
#   ./task_dedupe_recurring.sh -y -- project:exercise.rehab
#   ./task_dedupe_recurring.sh -y   # all parents in all projects

set -Eeuo pipefail

DRY=0
YES=0
while getopts ":ny" opt; do
  case "$opt" in
    n) DRY=1 ;;
    y) YES=1 ;;
    *) echo "Usage: $0 [-n] [-y] [--] [filters...]" >&2; exit 2 ;;
  esac
done
shift $((OPTIND-1))

FILTERS=("$@")

# Safety: show what we’re acting on.
echo ">>> Filters: ${FILTERS[*]:-(none)}"
echo ">>> Mode:   $([ $DRY -eq 1 ] && echo DRY-RUN || echo LIVE)"
echo ">>> Keep newest parent per identical description; delete older parents + children."
echo

# Export all candidate parents as pretty JSON.
# We’ll parse { ... } blocks to extract: id, uuid, description, entry.
# NOTE: We disable context to avoid hidden filters.
EXPORT_CMD=(task rc.context=none +PARENT "${FILTERS[@]}" export)

# Build a TSV: ID<TAB>UUID<TAB>DESCRIPTION<TAB>ENTRY
PARENTS_TSV=$( "${EXPORT_CMD[@]}" \
  | awk '
    BEGIN { RS="\\{"; FS="\n" }
    NR>1 {
      id=""; uuid=""; desc=""; entry="";
      for (i=1; i<=NF; i++) {
        line=$i
        if (line ~ /"id"[[:space:]]*:/)      { if (match(line, /"id"[[:space:]]*:[[:space:]]*([0-9]+)/, a)) id=a[1] }
        if (line ~ /"uuid"[[:space:]]*:/)    { if (match(line, /"uuid"[[:space:]]*:[[:space:]]*"([^"]+)"/, a)) uuid=a[1] }
        if (line ~ /"description"[[:space:]]*:/) {
          # capture naive quoted description (no escaped quotes handling)
          if (match(line, /"description"[[:space:]]*:[[:space:]]*"([^"]*)"/, a)) desc=a[1]
        }
        if (line ~ /"entry"[[:space:]]*:/)   { if (match(line, /"entry"[[:space:]]*:[[:space:]]*"([^"]+)"/, a)) entry=a[1] }
      }
      if (uuid != "" && desc != "" && entry != "")
        printf "%s\t%s\t%s\t%s\n", id, uuid, desc, entry
    }' )

if [ -z "$PARENTS_TSV" ]; then
  echo "No +PARENT tasks matched the given filters."
  exit 0
fi

# Sort by (description asc, entry desc) so the first row per description is newest.
# Then print all *older* duplicates’ UUIDs (and keep the newest).
DUP_UUIDS=$( printf "%s\n" "$PARENTS_TSV" \
  | sort -t $'\t' -k3,3 -k4,4r \
  | awk -F'\t' '
      BEGIN { prev_desc="" }
      {
        id=$1; uuid=$2; desc=$3; entry=$4
        if (desc == prev_desc) {
          print uuid
        } else {
          prev_desc=desc
        }
      }' )

if [ -z "$DUP_UUIDS" ]; then
  echo "No duplicate parents found (by identical description). Nothing to do."
  exit 0
fi

echo ">>> Duplicate parents to remove (UUIDs):"
printf "  %s\n" $DUP_UUIDS
echo

# Helper to run a task command with optional confirmation suppression.
run_task() {
  if [ $YES -eq 1 ]; then
    task rc.context=none rc.confirmation=off "$@"
  else
    task rc.context=none "$@"
  fi
}

# Iterate over duplicate parent UUIDs:
# 1) delete all +CHILD with parent:<uuid>
# 2) delete the parent itself
while read -r PUUID; do
  [ -z "$PUUID" ] && continue

  echo ">>> Handling parent: $PUUID"
  # Show a quick summary (optional)
  run_task uuid:"$PUUID" limit:1 info | sed 's/^/    /'

  # Find child IDs belonging to this parent
  CHILD_IDS=$( run_task +CHILD parent:"$PUUID" ids || true )
  if [ -n "$CHILD_IDS" ]; then
    echo "    Found child IDs: $CHILD_IDS"
    if [ $DRY -eq 1 ]; then
      echo "    DRY-RUN: would delete children of $PUUID"
    else
      echo "    Deleting children..."
      # shellcheck disable=SC2086
      run_task delete $CHILD_IDS >/dev/null
    fi
  else
    echo "    No children for this parent."
  fi

  # Delete the parent
  if [ $DRY -eq 1 ]; then
    echo "    DRY-RUN: would delete parent $PUUID"
  else
    echo "    Deleting parent $PUUID..."
    run_task uuid:"$PUUID" delete >/dev/null
  fi

  echo
done <<< "$DUP_UUIDS"

echo "Done."

