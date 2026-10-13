#!/usr/bin/env bash
# Weekly disk cleanup: stale Rust target/ dirs, package caches and Docker leftovers.
# Runs via systemd --user (weekly-cleanup.timer). Log: journalctl --user -u weekly-cleanup
set -u
PROJECTS="${PROJECTS:-$HOME/Proyects}"
DAYS=14   # target/ dirs with no build in the last DAYS days get deleted

echo "before: $(df -h / | awk 'NR==2{print $4}') free"

# Rust: target/ next to a Cargo.toml with no build output newer than DAYS.
# -mtime instead of -newermt: the interactive shell aliases find to bfs, which rejects relative dates.
find "$PROJECTS" -maxdepth 4 -type d -name target -prune 2>/dev/null | while read -r t; do
  [ -f "$t/../Cargo.toml" ] || continue
  [ -n "$(find "$t" -maxdepth 3 -mtime "-$DAYS" -print -quit)" ] && continue
  echo "removing $t ($(du -sh "$t" | cut -f1))"
  rm -rf -- "$t"
done

# Package caches (re-downloaded on demand). ~/.cache/solana is left alone on purpose.
command -v uv   >/dev/null && uv cache prune
command -v npm  >/dev/null && npm cache clean --force
command -v yarn >/dev/null && yarn cache clean
command -v brew >/dev/null && brew cleanup --prune=30

# Docker: images unused by any container for 30+ days, build cache older than 7 days, anonymous volumes.
# `docker volume prune` leaves named volumes alone, so ddev databases are safe.
if docker info >/dev/null 2>&1; then
  docker image prune -af --filter until=720h
  docker builder prune -af --filter until=168h
  docker volume prune -f
fi

echo "after: $(df -h / | awk 'NR==2{print $4}') free"
