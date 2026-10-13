#!/usr/bin/env bash
# Enlaza cada archivo de home/ a su lugar en $HOME (respaldo .bak si ya existía uno real).
set -eu
cd "$(dirname "$0")/home"
find . -type f -o -type l | while read -r f; do
  dst="$HOME/${f#./}"
  mkdir -p "$(dirname "$dst")"
  [ -e "$dst" ] && [ ! -L "$dst" ] && mv "$dst" "$dst.bak"
  ln -sfn "$PWD/${f#./}" "$dst" && echo "→ $dst"
done
systemctl --user daemon-reload
systemctl --user enable --now limpieza-semanal.timer
