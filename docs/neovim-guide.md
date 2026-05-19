# Neovim

Neovim is a modernized fork of Vim — everything you know from `vi` transfers directly. The difference is that Neovim is actively maintained, has a Lua config system, a built-in LSP client, and a rich plugin ecosystem that makes it genuinely pleasant for day-to-day coding.

Your existing muscle memory (`:w`, `:wq`, `:q!`, `/pattern`, `dd`, `yy`, `p`) works exactly the same.

---

## Config

`~/.config/nvim/init.lua` — managed via chezmoi.

The config is plain Lua. It sets sensible defaults and bootstraps [lazy.nvim](https://github.com/folke/lazy.nvim) as the plugin manager. Plugins install automatically on first launch.

**Installed plugins:**
| Plugin | What it does |
|--------|-------------|
| `catppuccin` | Colorscheme — matches tmux and bat |
| `nvim-treesitter` | Better syntax highlighting for all your languages |
| `telescope.nvim` | Fuzzy file/text finder (uses `fd` + `ripgrep`) |
| `lualine.nvim` | Nice status line at the bottom |
| `which-key.nvim` | Shows available keybindings when you pause after `<leader>` |
| `nvim-autopairs` | Auto-closes `(`, `[`, `"`, etc. |
| `Comment.nvim` | Toggle comments with `gcc` (line) or `gc` (visual) |

---

## Your vi commands still work

```
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

## New keybindings (your config)

**Leader key is `Space`.**  Press Space and pause — which-key will show you what's available.

### Files
| Key | Action |
|-----|--------|
| `<leader>ff` | Find files (fuzzy, respects .gitignore) |
| `<leader>fg` | Live grep across project |
| `<leader>fb` | Switch between open buffers |
| `<leader>fr` | Recent files |
| `<leader>e`  | File explorer (built-in netrw) |
| `<leader>w`  | Save |
| `<leader>q`  | Quit |

### Windows (splits)
| Key | Action |
|-----|--------|
| `:vsp` | Vertical split |
| `:sp`  | Horizontal split |
| `Ctrl-h/j/k/l` | Navigate between splits (vim-style, same as tmux) |

### Editing
| Key | Action |
|-----|--------|
| `gcc` | Toggle comment on current line |
| `gc` (visual) | Toggle comment on selection |
| `J` (visual) | Move selected lines down |
| `K` (visual) | Move selected lines up |
| `<` / `>` (visual) | Indent/dedent and stay in visual mode |
| `Esc` | Clear search highlight |

---

## Modal editing — the mental model

If you're used to `vi` but found it confusing, here's the short version:

- **Normal mode** — navigating, not typing. This is where you start. Press `Esc` to get back here.
- **Insert mode** — typing text. Enter with `i` (before cursor) or `a` (after).
- **Visual mode** — selecting text. `v` for character, `V` for line, `Ctrl-v` for block.
- **Command mode** — running commands. Enter with `:`.

The power is that Normal mode keys are verbs + nouns: `d3j` = "delete 3 lines down". `ci"` = "change inside quotes". You build these up over time.

---

## Useful Normal mode motions (beyond basic vi)

```
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

`<leader>ff` is your new way to open files — type a fuzzy fragment, arrow keys or `Ctrl-j/k` to move, Enter to open.

`<leader>fg` searches file *contents* — great for finding where a function is used across a project.

---

## Next steps when you're ready

- **LSP** (`nvim-lspconfig` + `mason.nvim`) — language servers for autocompletion, go-to-definition, inline errors. The biggest quality-of-life upgrade for coding.
- **`nvim-cmp`** — completion menu that LSP feeds into.
- These aren't in the current config intentionally — get comfortable with what's here first.

Run `:Lazy` inside nvim to manage plugins. Run `:TSUpdate` to update Treesitter parsers.

---

## Config location

`~/.config/nvim/init.lua` — managed via chezmoi. After editing: `chezmoi re-add ~/.config/nvim/init.lua`.
