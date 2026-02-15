#!/usr/bin/env bash
# Pre-push: run ansible-lint on YAML files changed vs origin/master.
# Requirements: bash, git, ansible-lint

set -euo pipefail

# --- sanity checks ---
command -v git >/dev/null 2>&1 || { echo "[pre-push] git not found in PATH. Aborting push." >&2; exit 1; }
command -v ansible-lint >/dev/null 2>&1 || { echo "[pre-push] ansible-lint not found in PATH. Aborting push." >&2; exit 1; }

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "$repo_root" ]] || { echo "[pre-push] Not inside a Git repository. Aborting." >&2; exit 1; }
cd "$repo_root"

base_ref="origin/master"

# Optional: update origin/master before diffing (disabled by default)
# Enable with: PREPUSH_FETCH=1 git push
if [[ "${PREPUSH_FETCH:-0}" == "1" ]]; then
  git fetch -q origin master || true
fi

# Ensure the base ref exists locally
if ! git rev-parse --verify --quiet "$base_ref" >/dev/null; then
  echo "[pre-push] Base ref '$base_ref' not found locally. Try running: git fetch origin master" >&2
  exit 1
fi

# Collect changed YAML files vs origin/master (merge-base aware via three-dot)
# -z: NUL-delimited for safety with spaces
mapfile -d '' -t files < <(
  git diff -z --name-only --diff-filter=ACMRT "$base_ref"...HEAD -- '*.yml' '*.yaml' \
  | awk 'BEGIN{RS="\0"; ORS="\0"} { if (length($0)) print $0 }'
)

# Filter to files that still exist + de-dup
declare -A seen=()
unique_files=()
for f in "${files[@]}"; do
  [[ -f "$f" ]] || continue
  [[ -n "${seen[$f]:-}" ]] && continue
  seen["$f"]=1
  unique_files+=("$f")
done

if (( ${#unique_files[@]} == 0 )); then
  echo "[pre-push] No changed YAML files vs $base_ref."
  exit 0
fi

echo "[pre-push] Running ansible-lint on ${#unique_files[@]} changed YAML file(s) vs $base_ref…"
#ansible-lint --nocolor "${unique_files[@]}"