# lazygit

lazygit is a terminal UI for git. Everything you'd do with `git add`, `git commit`, `git diff`, `git rebase` — it's all here, interactive, with delta diffs inline. It makes reviewing changes and crafting commits significantly faster than typing git commands.

Open it from anywhere in a git repo:

```bash
lg          # alias for lazygit
lazygit     # or the full command
```

Press `?` at any time to see all keybindings for the focused panel. Press `Esc` or `q` to go back / close.

---

## Layout

```text
┌─────────────────┬────────────────────────────────────────┐
│  Status (1)     │                                     │
├─────────────────┤           Diff / Preview             │
│  Files (2)      │                                     │
├─────────────────┤   (shows delta diff for whatever     │
│  Branches (3)   │    is selected in the left panels)  │
├─────────────────┤                                      │
│  Commits (4)    │                                     │
├─────────────────┤                                      │
│  Stash (5)      │                                     │
└─────────────────┴────────────────────────────────────────┘
```

Switch panels with the number keys `1–5`, or `Tab` to cycle through them.

---

## Essential keybindings

### Files panel

| Key     | Action                                              |
| ------- | --------------------------------------------------- |
| `Space` | Stage / unstage file                                |
| `a`     | Stage **all** files                                 |
| `c`     | Commit staged changes (opens commit message editor) |
| `A`     | Amend last commit                                   |
| `d`     | View diff for file                                  |
| `e`     | Open file in nvim                                   |
| `i`     | Add to .gitignore                                   |

### Commits panel

| Key     | Action                                              |
| ------- | --------------------------------------------------- |
| `Space` | Checkout commit                                     |
| `g`     | Reset to commit (interactive menu: soft/mixed/hard) |
| `r`     | Reword commit message                               |
| `e`     | Edit commit (interactive rebase)                    |
| `f`     | Fixup — squash into previous commit                 |
| `d`     | Drop commit                                         |
| `C`     | Copy commit SHA                                     |
| `p`     | Pick commit (during rebase)                         |

### Branches panel

| Key     | Action                              |
| ------- | ----------------------------------- |
| `Space` | Checkout branch                     |
| `n`     | New branch                          |
| `M`     | Merge into current branch           |
| `r`     | Rebase current branch onto selected |
| `d`     | Delete branch                       |
| `u`     | Set upstream                        |

### Universal

| Key                  | Action                             |
| -------------------- | ---------------------------------- |
| `P`                  | Push                               |
| `p` (not in commits) | Pull                               |
| `R`                  | Refresh                            |
| `z`                  | Undo last git operation            |
| `Ctrl-z`             | Redo                               |
| `?`                  | Show keybindings for current panel |
| `q`                  | Quit                               |

---

## Common workflows

### Stage specific lines (not the whole file)

1. Files panel → select file → `Enter` to expand
2. Navigate to individual hunks
3. `Space` to stage/unstage individual hunks
4. `v` to enter line-selection mode, select specific lines, `Space` to stage

### Interactive rebase (clean up before pushing)

1. Commits panel → navigate to a commit below the ones you want to clean
2. `e` to start interactive rebase from there
3. `r` reword, `f` fixup, `d` drop, `e` edit on individual commits
4. `m` to mark as done and continue

### Stashing

1. Files panel → `s` to stash all changes
2. Stash panel → `Space` to pop stash back

### Cherry-pick

1. Go to another branch in Branches panel
2. Commits panel → `C` to copy commit, `V` to paste (cherry-pick) onto current branch

---

## The diff view

The right panel uses **delta** for rendering. You can scroll it with the mouse or `[`/`]`. Press `Enter` on a file in the Files panel to drill into individual hunks.

---

## Config location

`~/.config/lazygit/config.yml` — managed via chezmoi. Reload: just reopen lazygit.
