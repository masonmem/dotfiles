# Neovim

Neovim is a modernized fork of Vim — all standard `vi` commands work. The difference is that Neovim is actively maintained, has a Lua config system, a built-in LSP client, and a rich plugin ecosystem that makes it genuinely pleasant for day-to-day coding.

Standard Vim commands (`:w`, `:wq`, `:q!`, `/pattern`, `dd`, `yy`, `p`) work unchanged.

---

## Config

`~/.config/nvim/init.lua` — managed via stow (`~/dotfiles/nvim/`).

The config is plain Lua. It sets sensible defaults and bootstraps [lazy.nvim](https://github.com/folke/lazy.nvim) as the plugin manager. Plugins install automatically on first launch.

**Installed plugins:**

| Plugin            | What it does                                                |
| ----------------- | ----------------------------------------------------------- |
| `catppuccin`      | Colorscheme — matches tmux and bat                          |
| `nvim-treesitter` | Installs Treesitter parsers; Neovim highlights with them. Needs Neovim 0.12+ and `tree-sitter` CLI (in the Brewfile); skipped on older Neovim |
| `telescope.nvim`  | Fuzzy file/text finder (uses `fd` + `ripgrep`)              |
| `lualine.nvim`    | Nice status line at the bottom                              |
| `which-key.nvim`  | Shows available keybindings when you pause after `<leader>` |
| `nvim-autopairs`  | Auto-closes `(`, `[`, `"`, etc.                             |

Commenting (`gcc`, `gc`) is built into Neovim 0.10+, so no plugin is needed.

---

## Standard vi/Vim commands

```text
:w          save
:wq / ZZ    save and quit
:q!         quit without saving
/pattern    search forward
?pattern    search backward
n / N       next / previous match
dd          delete line
yy          yank (copy) line
p           paste below
u           undo
Ctrl-r      redo
```

---

## Custom keybindings

**Leader key is `Space`.** Press Space and pause — which-key will show you what's available.

### Files

| Key          | Action                                  |
| ------------ | --------------------------------------- |
| `<leader>ff` | Find files (fuzzy, respects .gitignore) |
| `<leader>fg` | Live grep across project                |
| `<leader>fb` | Switch between open buffers             |
| `<leader>fr` | Recent files                            |
| `<leader>e`  | File explorer (built-in netrw)          |
| `<leader>w`  | Save                                    |
| `<leader>q`  | Quit                                    |

### Windows (splits)

| Key            | Action                                            |
| -------------- | ------------------------------------------------- |
| `:vsp`         | Vertical split                                    |
| `:sp`          | Horizontal split                                  |
| `Ctrl-h/j/k/l` | Navigate between splits (vim-style, same as tmux) |

### Editing

| Key                | Action                                |
| ------------------ | ------------------------------------- |
| `gcc`              | Toggle comment on current line        |
| `gc` (visual)      | Toggle comment on selection           |
| `J` (visual)       | Move selected lines down              |
| `K` (visual)       | Move selected lines up                |
| `<` / `>` (visual) | Indent/dedent and stay in visual mode |
| `Esc`              | Clear search highlight                |

---

## Modal editing — the mental model

Neovim has four main modes:

- **Normal mode** — navigating, not typing. This is where you start. Press `Esc` to get back here.
- **Insert mode** — typing text. Enter with `i` (before cursor) or `a` (after).
- **Visual mode** — selecting text. `v` for character, `V` for line, `Ctrl-v` for block.
- **Command mode** — running commands. Enter with `:`.

The power is in composable commands: **verb + noun**, where the verb is what to do and the noun is what to act on.

**Verbs (operators):**

| Key | Action                              |
| --- | ----------------------------------- |
| `d` | delete                              |
| `c` | change (delete + enter Insert mode) |
| `y` | yank (copy)                         |

**Nouns (motions and text objects):**

| Key  | Refers to                        |
| ---- | -------------------------------- |
| `w`  | next word                        |
| `j`  | line below                       |
| `i"` | inside the nearest `"..."` pair  |
| `a(` | around `(...)`, including parens |

**Putting it together:**

```text
dw    → delete word
d3j   → delete 3 lines down
ci"   → change inside quotes  (cuts the text between " ", drops you into Insert)
yap   → yank a paragraph
```

Repeat the verb to act on the whole line: `dd` deletes the current line, `yy` yanks it.

There's no need to memorize combinations — a handful of verbs and nouns mix freely to form new commands.

---

## Useful Normal mode motions

```text
w / b       next / previous word
e           end of word
0 / $       start / end of line
gg / G      top / bottom of file
Ctrl-d      scroll half-page down
Ctrl-u      scroll half-page up
%           jump to matching bracket
*           search for word under cursor
ci(         change inside parentheses
ca"         change around quotes (includes the quotes)
=G          auto-indent from cursor to end of file
```

---

## Telescope workflow

`<leader>ff` opens files with fuzzy search — type a fragment, use arrow keys or `Ctrl-j/k` to navigate, Enter to open.

`<leader>fg` searches file _contents_ — useful for finding where a function is defined or used across a project.

---

## Further configuration

- **LSP** (`nvim-lspconfig` + `mason.nvim`) — language servers for autocompletion, go-to-definition, inline errors.
- **`nvim-cmp`** — completion menu that LSP feeds into.
- These aren't included in the current config — add them when needed.

Run `:Lazy` inside nvim to manage plugins. Run `:TSUpdate` to update Treesitter parsers. Plugin versions are recorded in `~/.config/nvim/lazy-lock.json` on each machine (not tracked).

---

## Config location

`~/.config/nvim/init.lua` — managed via stow (`~/dotfiles/nvim/`). Edits are live immediately since it's a symlink.
