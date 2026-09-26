# Shell Tools

The shell environment replaces several standard Unix tools with modern alternatives. They're faster, have better defaults, and integrate with each other. All tool init scripts guard with `command -v` — if a tool isn't installed, it's silently skipped.

---

## Tool map

| Standard command | Replacement   | Why                                          |
| ---------------- | ------------- | -------------------------------------------- |
| `cat`            | **bat**       | Syntax highlighting, line numbers, git gutter |
| `ls`             | **eza**       | Icons, git status, tree view                 |
| `find`           | **fd**        | Faster, saner defaults, respects .gitignore  |
| `grep`           | **ripgrep**   | Faster, respects .gitignore, better UX       |
| `cd`             | **zoxide**    | Learns directories, fuzzy matching           |
| `Ctrl-R` / `↑`   | **atuin**     | Searchable history database, cross-machine sync |
| `Ctrl-T`         | **fzf**       | Fuzzy file/dir picker                        |
| `git diff`       | **delta**     | Syntax-highlighted diffs, line numbers       |

---

## fzf — fuzzy finder

fzf is a general-purpose fuzzy finder. In this config it powers three keyboard shortcuts:

| Shortcut  | What it does                         | Backed by |
| --------- | ------------------------------------ | --------- |
| `Ctrl-T`  | Insert file path into command line   | fd        |
| `Alt-C`   | cd into a directory                  | fd        |
| `Ctrl-R`  | Search history (overridden by atuin) | —         |

The preview pane shows file contents (via bat) for `Ctrl-T` and directory trees (via eza) for `Alt-C`.

```bash
# fzf also works in pipelines
vim $(fzf)                          # open a file picked interactively
git log --oneline | fzf             # pick a commit
kill -9 $(ps aux | fzf | awk '{print $2}')   # kill a process
```

---

## atuin — shell history

atuin replaces the default `Ctrl-R` history search (and the `↑` key) with a full-text searchable database. History is stored in SQLite and can optionally sync across machines.

```bash
Ctrl-R / ↑      # open atuin search (interactive)
atuin search <query>   # CLI search
atuin stats            # usage statistics
```

Settings live in `~/.config/atuin/config.toml`, which lists only what differs from the defaults (`atuin default-config` prints them all):
- **enter_accept** — `true`: Enter runs the command, Tab puts it on the prompt for editing
- **style** — `compact`; theme is Catppuccin Macchiato
- Defaults worth knowing: `search_mode = "fuzzy"`, `filter_mode = "global"` (Ctrl-R inside the TUI cycles filter modes)

---

## zoxide — smarter cd

zoxide replaces `cd` transparently. It learns which directories you visit and ranks them by frequency + recency ("frecency").

```bash
cd foo            # works normally for relative/absolute paths
cd proj           # jumps to highest-ranked directory matching "proj"
cd da so          # matches ~/code/viya-data-sources (multiple terms = AND)
zi                # interactive picker (fzf-powered)
cd -              # go back to previous directory (still works)
```

Under the hood, `cd` calls `__zoxide_z`. The database lives at `~/.local/share/zoxide/db.zo`.

---

## bat — better cat

bat shows file contents with syntax highlighting, line numbers, and git change markers.

```bash
cat file.ts       # aliased to `bat --paging=auto` (pages only when output doesn't fit)
bat file.ts       # explicit call (shows header/line numbers)
command cat file  # the real cat, when you need raw output
```

In pipes bat behaves like plain `cat`. bat is also used as:
- The fzf preview pane (`Ctrl-T` file previews)
- The delta syntax engine (git diffs; same `BAT_THEME`)

Theme: **Catppuccin Macchiato** (set via `BAT_THEME` in `10-env.zsh`).

---

## eza — better ls

eza replaces `ls` with a modern version that understands git status and supports icons. (Inside dev containers `ls` stays native; `ll` / `la` use plain `ls` there.)

```bash
ls                # aliased: eza --group-directories-first
ll                # eza -la --git --icons --group-directories-first
la                # eza -la --icons --group-directories-first
lt                # eza --tree --icons --group-directories-first
```

---

## fd — better find

fd is a fast file finder that respects `.gitignore` by default.

```bash
fd pattern               # find files matching pattern (recursive)
fd -e ts                 # find all .ts files
fd -t d                  # find directories only
fd -H pattern            # include hidden files
fd pattern --exec rm     # find and execute command on each
```

fd also powers fzf's `Ctrl-T` and `Alt-C` commands (set via `FZF_DEFAULT_COMMAND` etc.).

---

## ripgrep (rg) — better grep

ripgrep searches file contents. Fast, respects `.gitignore`, shows context.

```bash
rg pattern               # search all files recursively
rg pattern -t ts         # search only TypeScript files
rg pattern -l            # list matching files only
rg pattern -C 3          # show 3 lines of context
rg -F 'exact string'    # literal search (no regex)
```

---

## delta — better diff

delta makes `git diff`, `git log -p`, and `git show` output readable with syntax highlighting and line numbers. It's configured as the git pager in `.gitconfig`.

```bash
git diff                 # automatically uses delta
git log -p               # diffs in log use delta too
delta file_a file_b      # compare two files directly
```

Key features:
- Line numbers in diffs
- Navigate between files with `n`/`N` (when `navigate = true`)
- Side-by-side mode available (`delta --side-by-side`)
- Used inside lazygit for inline diffs

---

## Keybinding summary

| Shortcut   | Tool    | Action                              |
| ---------- | ------- | ----------------------------------- |
| `Ctrl-R` / `↑` | atuin | Search shell history              |
| `Ctrl-T`   | fzf     | Insert file path                    |
| `Alt-C`    | fzf     | cd into directory                   |
| `zi`       | zoxide  | Interactive directory picker        |
| `n` / `N`  | delta   | Next/prev file in git diff          |

---

## Lazy loading

Several tools have init scripts that run on every shell start. To keep shell startup fast:

- **fzf, atuin, zoxide** — their init output is cached to `~/.cache/zsh/`. The cache auto-regenerates when the binary is updated.
- **kubectl completion** — generated once into `~/.cache/zsh/completions/`, refreshed when kubectl is updated.
- **nvm** — lazy-loaded entirely. Stub functions for `nvm`, `node`, `npm`, `npx`, `yarn`, `pnpm` trigger the full load on first call. This saves ~400ms of startup time.
