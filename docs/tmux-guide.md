# tmux

tmux is a **terminal multiplexer** — it lets you run multiple terminal sessions inside a single window, split your screen into panes, and keep sessions alive when you disconnect. Think of it as a workspace manager for the terminal.

The killer feature: a tmux session keeps running even if you close your terminal or SSH drops. Come back later and `tmux attach` right where you left off.

---

## Core concepts

```
Session
 └── Window 1 (like a browser tab)
      ├── Pane A (left)
      └── Pane B (right)
 └── Window 2
      └── Pane A (full screen)
```

- **Session** — a collection of windows. You can have multiple sessions; great for separating projects.
- **Window** — fills the terminal screen. Switch between windows like tabs.
- **Pane** — a window split into sub-terminals. Run different commands side by side.

---

## Your prefix key

All tmux shortcuts start with the **prefix key**. Your config uses **`Ctrl-A`** (changed from the default `Ctrl-B`).

Written as `<prefix>` below. So `<prefix> |` means: press `Ctrl-A`, release, then press `|`.

---

## Quick start

```bash
tmux                        # start a new session
tmux new -s work            # start a named session
tmux ls                     # list running sessions
tmux attach -t work         # re-attach to "work" session
tmux kill-session -t work   # kill a session
```

Once inside tmux, everything goes through the prefix:

---

## Cheat sheet

### Sessions
| Key / Command | Action |
|---------------|--------|
| `<prefix> $` | Rename current session |
| `<prefix> d` | **Detach** (leaves session running) |
| `<prefix> s` | List & switch sessions (interactive) |
| `tmux attach` | Re-attach to last session |

### Windows (tabs)
| Key | Action |
|-----|--------|
| `<prefix> c` | New window (opens in current dir) |
| `<prefix> ,` | Rename window |
| `<prefix> w` | List & switch windows |
| `<prefix> n` / `p` | Next / previous window |
| `<prefix> 1–9` | Jump to window by number |
| `<prefix> &` | Close window (with confirm) |

### Panes (splits)
| Key | Action |
|-----|--------|
| `<prefix> \|` | Split **vertically** (left/right) |
| `<prefix> -` | Split **horizontally** (top/bottom) |
| `<prefix> h/j/k/l` | Navigate panes (vim-style) |
| `<prefix> H/J/K/L` | Resize pane (hold for repeat) |
| `<prefix> z` | **Zoom** pane to full screen (toggle) |
| `<prefix> x` | Close pane (with confirm) |
| `<prefix> {` / `}` | Swap pane position |
| `<prefix> Space` | Cycle through pane layouts |

### Copy mode (scroll + search)
| Key | Action |
|-----|--------|
| `<prefix> Enter` | Enter copy mode |
| `v` | Start selection (vi visual) |
| `y` | Copy selection → clipboard (`pbcopy`) |
| `q` / `Esc` | Exit copy mode |
| `/` | Search forward |
| `?` | Search backward |
| `n` / `N` | Next / previous match |
| `PgUp` / mouse scroll | Scroll up through history |

### Misc
| Key | Action |
|-----|--------|
| `<prefix> r` | Reload `~/.tmux.conf` |
| `<prefix> ?` | Show all keybindings |
| `<prefix> t` | Show a clock |

---

## Workflow examples

### Dev session with editor + server + logs

```bash
tmux new -s myapp
# Window 1 is your editor
nvim .

# Open a second window for the dev server
<prefix> c
npm run dev

# Split the server window to show logs below
<prefix> -
tail -f logs/app.log

# Go back to editor
<prefix> 1
```

### Multiple projects

```bash
tmux new -s frontend    # one session per project
tmux new -s backend
tmux new -s infra

# Switch between them
tmux attach -t backend
# or from inside tmux:
<prefix> s              # fuzzy-searchable session picker
```

### Keep a long job running after you close your laptop

```bash
tmux new -s build
make release            # start the slow thing

<prefix> d              # detach — session stays alive

# Come back tomorrow
tmux attach -t build    # pick up right where you left off
```

---

## Tips

- **Mouse is on** — you can click panes to focus, drag borders to resize, and scroll with the trackpad.
- **Zoom (`<prefix> z`)** is great for temporarily going full-screen on a pane without destroying the layout.
- Run `tmux list-keys` to see every binding. Run `tmux show-options -g` to see all global options.
- Inside copy mode, your normal vim search keys (`/`, `n`, `N`) work for scrollback search.

---

## Config location

`~/.tmux.conf` — managed via chezmoi. To reload without restarting: `<prefix> r`.
