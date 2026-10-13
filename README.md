# dotfiles

Config personal de la Lenovo. `home/` replica `$HOME`; `./install.sh` crea los symlinks.

- `bin/limpieza-semanal.sh` + `limpieza-semanal.{service,timer}`: domingo 11:00 borra `target/` sin compilar en 14 días, cachés uv/npm/yarn/brew y basura de Docker (no toca volúmenes con nombre ni `~/.cache/solana`). Log: `journalctl --user -u limpieza-semanal`.
