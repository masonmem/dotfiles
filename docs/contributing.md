# Contributing and tests

Even for a one-person repo, `sync-all` copies a mistake to every machine within
hours. These checks keep that from happening.

## Run the checks

```bash
tests/run             # everything
tests/run --offline   # skip the shell-startup test (it clones from GitHub)
```

| Check | Catches |
|---|---|
| shellcheck | quoting bugs, unset variables, portability problems in the bash scripts |
| `zsh -n` on every zsh file | syntax errors that would break every new shell |
| `test-configure-vscode-ai.py` | settings merge, backup of commented JSONC |
| `test-dotfiles-sync.py` | Homebrew output stays visible |
| `test-zsh-aliases.zsh` | containers keep native `ls` |
| `test-dotfiles-sync.sh` | `install.sh` + `dotfiles-sync` in a throwaway `$HOME`: profiles, work isolation, conflicts, pulls, deletions, dirty trees, stow/no-stow **parity** |
| `test-shell-startup.sh` | real interactive, login and non-interactive shells start with **no error output** and the right PATH |

It needs `git`, `zsh`, `stow`, `shellcheck` and `python3`.

## CI

`.github/workflows/ci.yml` runs `tests/run` on every push and pull request:

- **Linux** (Ubuntu), the full suite;
- **macOS**, with Apple's `/bin/bash` 3.2 first on PATH and BSD userland, as
  on the real Macs.

`.github/workflows/docs.yml` builds this site with `mkdocs build --strict` on
every push (broken links and missing includes fail the build), and publishes
it to GitHub Pages from `main`.

## Rules for scripts

- **bash 3.2 compatible.** `#!/usr/bin/env bash` finds Apple's bash 3.2 on the
  Macs, because the Brewfile doesn't install a newer one. So: no associative
  arrays, no `mapfile`, no `${var,,}`, and never expand an empty array under
  `set -u`. CI runs 3.2.
- **BSD and GNU tools.** No `sed -i`, `readlink -f`, `stat -c` (without a
  `stat -f` fallback), or `grep -P`.
- **Don't abort on the non-essential.** A failed brew or pipx install, or the
  network being down, should warn and continue.
- **Never overwrite user files.** Refuse and report, or move aside with
  `--backup-conflicts`.
- `set -euo pipefail`, `log`/`warn` helpers, and shellcheck-clean.

## Rules for shell config

- Guard optional tools: `(( $+commands[tool] ))`.
- Print nothing at startup (instant prompt).
- Anything slow: cache it or lazy-load it.
- Secrets: read from files at runtime; never commit them.

## Docs

This site lives in `docs/` with `mkdocs.yml` at the repo root.

```bash
python3 -m venv .venv && . .venv/bin/activate
pip install -r docs/requirements.txt
mkdocs serve            # http://127.0.0.1:8000, live reload
```

- Reference pages embed real files with `--8<-- "path"` (or a named section,
  `--8<-- "file:name"`, between `# --8<-- [start:name]` / `[end:name]` markers),
  so they stay accurate. Prefer that to copying.
- When you add a package, command, alias or file, update the matching page.
  [Repository layout](reference/layout.md) and [Shell](reference/shell.md) are
  the usual ones.
- Diagrams are Mermaid code blocks.

## Commit messages

Conventional-commit style, as in the history: `feat(zsh): …`, `fix(sync): …`,
`chore(brewfile): …`, `docs: …`.
