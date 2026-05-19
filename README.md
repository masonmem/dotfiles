# dotfiles

My personal macOS dev environment. Apple Silicon, zsh, Homebrew. Managed with [GNU Stow](https://www.gnu.org/software/stow/). Guides are in [docs](docs/).

## Bootstrap a new machine

```bash
# 1. Install Homebrew, then restore all formulae
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew bundle --file=~/dotfiles/Brewfile

# 2. Clone and stow
git clone git@github.com:masonmem/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow zsh p10k tmux git nvim lazygit ssh
```

---

## How stow works

Each subdirectory is a **package**. Running `stow <package>` creates symlinks from `~` into that package, mirroring its directory structure. The actual files live in `~/dotfiles/` — edits there are live immediately, no sync step needed.

```text
~/dotfiles/zsh/.zshrc  →  stow  →  ~/.zshrc  (symlink)
```

To add a new file: put it in the right package directory, run `stow <package>` again.

To unlink a package (e.g. to temporarily test a change): `stow -D <package>`.

---

## Packages

| Package    | What it manages                                    |
| ---------- | -------------------------------------------------- |
| `zsh/`     | `.zshrc`, `.zprofile`, `.zshenv`, `.config/zsh/**` |
| `p10k/`    | `.p10k.zsh`                                        |
| `tmux/`    | `.tmux.conf`                                       |
| `git/`     | `.gitconfig`                                       |
| `nvim/`    | `.config/nvim/init.lua`                            |
| `lazygit/` | `.config/lazygit/config.yml`                       |
| `ssh/`     | `.ssh/config`                                      |

Repo-level files (`Brewfile`, `docs/`, `README.md`) are not stowed. They live only in the repo.

---

## What each file does

| File                               | Purpose                                                             |
| ---------------------------------- | ------------------------------------------------------------------- |
| `Brewfile`                         | Full snapshot of brew formulae + casks                              |
| `~/.zshrc`                         | Shell entry point — loads oh-my-zsh + sources `~/.config/zsh/*.zsh` |
| `~/.zshenv`                        | Cargo env (runs for every shell, including scripts)                 |
| `~/.zprofile`                      | Homebrew shellenv + pipx PATH (login shells)                        |
| `~/.config/zsh/00-path.zsh`        | PATH deduplication                                                  |
| `~/.config/zsh/10-env.zsh`         | EDITOR, XDG dirs, BAT_THEME, NVM_DIR                                |
| `~/.config/zsh/20-aliases.zsh`     | Modern CLI aliases: bat, eza, kubecolor, lazygit, tldr              |
| `~/.config/zsh/30-completions.zsh` | kubectl completion cache + kubecolor compdef + iTerm2 integration   |
| `~/.config/zsh/40-tools.zsh`       | fzf (Ctrl-T/Alt-C), atuin (Ctrl-R), zoxide (replaces `cd`)          |
| `~/.config/zsh/70-nvm.zsh`         | Lazy NVM — loads Node only when first invoked                       |
| `~/.gitconfig`                     | delta pager (line numbers, navigate), aliases, pull.rebase          |
| `~/.config/nvim/init.lua`          | Neovim — lazy.nvim, treesitter, telescope, catppuccin               |
| `~/.config/lazygit/config.yml`     | lazygit — delta diffs, catppuccin theme, nvim integration           |
| `~/.ssh/config`                    | SSH global defaults — keepalive, multiplexing, keychain             |
| `~/.p10k.zsh`                      | Powerlevel10k prompt config                                         |
| `~/.tmux.conf`                     | tmux — prefix Ctrl-B, mouse, vim nav, catppuccin status bar         |

---

## Shell structure

`.zshrc` is a thin loader. The real config lives in numbered files under `~/.config/zsh/`. Source order matters, hence the numeric prefixes. Add a new file and it gets picked up automatically on next shell start.

Key tooling to be aware of:

- **atuin** owns `Ctrl-R` (history). fzf handles `Ctrl-T` (files) and `Alt-C` (dirs).
- **zoxide** replaces `cd` transparently (`--cmd cd`). Use `zi` for the interactive picker.
- **nvm** is lazy-loaded — `node`, `npm`, `npx`, `yarn`, `pnpm` trigger the load on first call.
- **kubecolor** is aliased to `kubectl`; completions delegate to the real `kubectl` binary.
- **tealdeer** provides `tldr` — fast Rust implementation of tldr pages (a manpage replacement). Run `tldr --update` to refresh.

---

## Guides

| Guide                                          | Topic                                               |
| ---------------------------------------------- | --------------------------------------------------- |
| [docs/neovim-guide.md](docs/neovim-guide.md)   | Neovim config, plugins, keybindings, modal editing  |
| [docs/lazygit-guide.md](docs/lazygit-guide.md) | lazygit TUI — staging, commits, rebase, cherry-pick |
| [docs/tmux-guide.md](docs/tmux-guide.md)       | tmux sessions, windows, panes, copy mode            |

---

## Editing dotfiles

Stow uses symlinks, so you can edit files at their real path (`~/.zshrc`) or directly in the repo (`~/dotfiles/zsh/.zshrc`). They're the same file. Then just commit and push:

```bash
cd ~/dotfiles
git add -A
git commit -m "feat: ..."
git push
```
