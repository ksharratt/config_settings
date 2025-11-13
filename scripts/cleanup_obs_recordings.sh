#!/usr/bin/env bash
set -euo pipefail

# Folder where OBS / Game Bar saves captures (Windows path: C:\Users\keith\Videos\Captures)
CAPTURE_DIR="/mnt/c/Users/keith/Videos/Captures"

# Days to keep
DAYS_TO_KEEP=7

# File types to delete (case-insensitive)
# Add/remove extensions as needed
find "$CAPTURE_DIR" \
  -type f \
  \( -iname '*.mp4' -o -iname '*.mkv' -o -iname '*.mov' -o -iname '*.flv' -o -iname '*.avi' \) \
  -mtime +"$DAYS_TO_KEEP" \
  -print -delete
