#!/usr/bin/env bash
# Symlink every file under home/ to the same path under $HOME.
# A real file already at the destination is kept as <file>.bak. Safe to re-run.
set -eu
cd "$(dirname "$0")/home"
find . -type f | while read -r f; do
  dst="$HOME/${f#./}"
  mkdir -p "$(dirname "$dst")"
  [ -e "$dst" ] && [ ! -L "$dst" ] && mv "$dst" "$dst.bak"
  ln -sfn "$PWD/${f#./}" "$dst" && echo "→ $dst"
done
systemctl --user daemon-reload
systemctl --user enable --now weekly-cleanup.timer
