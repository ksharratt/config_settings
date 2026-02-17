#!/usr/bin/env bash
# pre-commit: warn if current branch is behind origin/master and show diff.
# Does NOT block commits (always exits 0).

set -euo pipefail

REMOTE="origin"
BASE_BRANCH="master"
BASE_REF="refs/remotes/${REMOTE}/${BASE_BRANCH}"

# Don't run in non-git contexts
git rev-parse --git-dir >/dev/null 2>&1 || exit 0

# Skip detached HEAD (optional)
branch="$(git symbolic-ref --quiet --short HEAD 2>/dev/null || true)"
[ -n "$branch" ] || exit 0

# Keep the remote-tracking ref fresh.
# Internal training recommends fetch before diff/pull to see upstream changes first.
git fetch --quiet "$REMOTE" "$BASE_BRANCH" || echo "[pre-commit] WARN: fetch failed; using cached origin/master" >&2

# If we don't have origin/master locally, nothing to compare
if ! git show-ref --verify --quiet "$BASE_REF"; then
  exit 0
fi

base_sha="$(git rev-parse "$BASE_REF")"
head_sha="$(git rev-parse HEAD)"

# If HEAD already contains origin/master, no drift
if git merge-base --is-ancestor "$base_sha" "$head_sha"; then
  echo "[pre-commit] Your branch is up to date with '${REMOTE}/${BASE_BRANCH}'"
  exit 0
fi

common="$(git merge-base "$base_sha" "$head_sha")"

echo "------------------------------------------------------------"
echo "[pre-commit] WARN: '$branch' is behind ${REMOTE}/${BASE_BRANCH}"
echo "  ${REMOTE}/${BASE_BRANCH}: $base_sha"
echo "  $branch (HEAD):         $head_sha"
echo "  merge-base:             $common"
echo

# Commits you are missing from origin/master
echo "[pre-commit] Commits on ${REMOTE}/${BASE_BRANCH} not in '$branch':"
git log --oneline --decorate "${head_sha}..${base_sha}" || true
echo

# File-level differences
echo "[pre-commit] Files changed between ${REMOTE}/${BASE_BRANCH} and '$branch':"
git diff --name-status "${base_sha}..${head_sha}" || true
echo

# Show patch for what you're missing from origin/master (often the most useful)
echo "[pre-commit] Patch you are missing from ${REMOTE}/${BASE_BRANCH} (first 250 lines):"
git diff "${head_sha}..${base_sha}" | sed -n '1,250p' || true
echo

echo "[pre-commit] Suggested next step (choose one):"
echo "[pre-commit]   Merge:  git merge ${REMOTE}/${BASE_BRANCH}"
echo "[pre-commit]   Rebase: git rebase ${REMOTE}/${BASE_BRANCH}"
echo "[pre-commit] ------------------------------------------------------------"

# Never block the commit
exit 0