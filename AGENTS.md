# AGENTS.md

Instructions for AI coding agents working in this repo.

## Layout

- `home/` mirrors `$HOME` exactly. `home/.config/fish/config.fish` is `~/.config/fish/config.fish`.
- The live files in `$HOME` are symlinks into this repo. Edit the repo copy, or the `$HOME`
  path (same file). Never replace a symlink with a regular file.
- `install.sh` links everything and enables `weekly-cleanup.timer`. It must stay idempotent.

## Adding a file

1. Move it into `home/` at the same relative path.
2. Run `./install.sh`.
3. Add a row to the matching table in `README.md`. Every tracked file is documented there.

## Rules

- **This repo is public.** Before committing, grep the diff for tokens, passwords, API keys,
  hostnames, IPs and usernames. Never add `~/.ssh/config`, `fish_variables`, `.env` files
  or anything under `~/.config/*/credentials*`.
- English for file names, comments, messages and docs.
- Use `$HOME`, never a hard-coded `/home/<user>`.
- In the interactive shell, `find` is aliased to `bfs`. It rejects GNU-only syntax like
  `-newermt "-14 days"`. Scripts must use portable flags (`-mtime -N`).
- The cleanup script deletes data. Any change to it needs a dry run first: print what would
  be removed and check that active projects (recent `target/` mtime), named Docker volumes
  and `~/.cache/solana` are not on the list.

## Checks

```sh
bash -n home/bin/*.sh
for f in home/.config/fish/**/*.fish home/.config/fish/*.fish; do fish -n "$f"; done
systemd-analyze --user verify home/.config/systemd/user/*.service
```
