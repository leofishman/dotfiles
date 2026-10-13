#!/usr/bin/env bash
# Limpieza semanal: target/ de Rust sin uso, cachés de paquetes y basura de Docker.
# Corre vía systemd --user (limpieza-semanal.timer). Log: journalctl --user -u limpieza-semanal
set -u
DIAS=14   # target/ sin compilar hace más de DIAS días se borra

echo "antes: $(df -h / | awk 'NR==2{print $4}') libres"

# Rust: target/ de proyectos con Cargo.toml sin ninguna compilación reciente
find "$HOME/Proyects" -maxdepth 4 -type d -name target -prune 2>/dev/null | while read -r t; do
  [ -f "$t/../Cargo.toml" ] || continue
  [ -n "$(find "$t" -maxdepth 3 -mtime "-$DIAS" -print -quit)" ] && continue
  echo "borro $t ($(du -sh "$t" | cut -f1))"
  rm -rf -- "$t"
done

# Cachés de paquetes (se re-descargan). ~/.cache/solana queda fuera a propósito.
command -v uv   >/dev/null && uv cache prune
command -v npm  >/dev/null && npm cache clean --force
command -v yarn >/dev/null && yarn cache clean
command -v brew >/dev/null && brew cleanup --prune=30

# Docker: imágenes sin contenedor de +30 días, build cache de +7 días, volúmenes anónimos.
# docker volume prune NO toca volúmenes con nombre (las bases de ddev quedan a salvo).
if docker info >/dev/null 2>&1; then
  docker image prune -af --filter until=720h
  docker builder prune -af --filter until=168h
  docker volume prune -f
fi

echo "después: $(df -h / | awk 'NR==2{print $4}') libres"
