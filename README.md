# dotfiles

Personal macOS dev environment — Apple Silicon, zsh, Homebrew. Managed with [chezmoi](https://chezmoi.io).

## Bootstrap a new machine

```bash
# 1. Install Homebrew, then restore all formulae
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew bundle --file=Brewfile

# 2. Install chezmoi and apply dotfiles
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply gh:masonmem/dotfiles
```

---

## What's managed

| File | Purpose |
|------|---------|
| `Brewfile` | Full snapshot of brew formulae + casks |
| `~/.zshrc` | Shell entry point — loads oh-my-zsh + sources `~/.config/zsh/*.zsh` |
| `~/.zshenv` | Cargo env (runs for every shell, including scripts) |
| `~/.zprofile` | Homebrew shellenv + pipx PATH (login shells) |
| `~/.config/zsh/00-path.zsh` | PATH deduplication |
| `~/.config/zsh/10-env.zsh` | EDITOR, XDG dirs, BAT_THEME, NVM_DIR |
| `~/.config/zsh/20-aliases.zsh` | Modern CLI aliases: bat, eza, kubecolor, lazygit, tldr |
| `~/.config/zsh/30-completions.zsh` | kubectl completion cache + kubecolor compdef + iTerm2 integration |
| `~/.config/zsh/40-tools.zsh` | fzf (Ctrl-T/Alt-C), atuin (Ctrl-R), zoxide (replaces `cd`) |
| `~/.config/zsh/70-nvm.zsh` | Lazy NVM — loads Node only when first invoked |
| `~/.gitconfig` | delta pager (line numbers, navigate), aliases, pull.rebase |
| `~/.config/nvim/init.lua` | Neovim — lazy.nvim, treesitter, telescope, catppuccin |
| `~/.config/lazygit/config.yml` | lazygit — delta diffs, catppuccin theme, nvim integration |
| `~/.ssh/config` | SSH global defaults — keepalive, multiplexing, keychain |
| `~/.p10k.zsh` | Powerlevel10k prompt config |
| `~/.tmux.conf` | tmux — prefix Ctrl-B, mouse, vim nav, catppuccin status bar |

---

## Shell structure

`.zshrc` is a thin loader. The real config lives in numbered files under `~/.config/zsh/` — source order matters, hence the numeric prefixes. Add a new file and it gets picked up automatically on next shell start.

**Startup time: ~0.3s** (down from ~1.9s — lazy NVM is the main win).

Key tool decisions:
- **atuin** owns `Ctrl-R` (history). fzf handles `Ctrl-T` (files) and `Alt-C` (dirs).
- **zoxide** replaces `cd` transparently (`--cmd cd`). Use `zi` for the interactive picker.
- **nvm** is lazy-loaded — `node`, `npm`, `npx`, `yarn`, `pnpm` trigger the load on first call.
- **kubecolor** is aliased to `kubectl`; completions delegate to the real `kubectl` binary.
- **tealdeer** provides `tldr` — fast Rust implementation of tldr pages. Run `tldr --update` to refresh.

---

## Guides

| Guide | Topic |
|-------|-------|
| [docs/neovim-guide.md](docs/neovim-guide.md) | Neovim config, plugins, keybindings, vi→nvim upgrade path |
| [docs/lazygit-guide.md](docs/lazygit-guide.md) | lazygit TUI — staging, commits, rebase, cherry-pick |
| [docs/tmux-guide.md](docs/tmux-guide.md) | tmux sessions, windows, panes, copy mode |

---

## Updating

After editing a managed file, sync it back and push:

```bash
chezmoi re-add ~/.config/zsh/20-aliases.zsh
cd ~/.local/share/chezmoi && git add -A && git commit -m "feat: ..." && git push
```

Or edit directly in the chezmoi source:

```bash
chezmoi edit ~/.zshrc   # opens in $EDITOR, then:
chezmoi apply           # applies to the real file
```

