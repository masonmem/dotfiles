# dotfiles

Personal macOS dev environment — Apple Silicon, zsh, Homebrew. Managed with [chezmoi](https://chezmoi.io).

## Bootstrap a new machine

```bash
# Install chezmoi and apply everything in one shot
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply gh:masonmem/dotfiles
```

Then install Homebrew and the formulae you need. A `Brewfile` would live here eventually to automate that too.

---

## What's managed

| File | Purpose |
|------|---------|
| `~/.zshrc` | Shell entry point — loads oh-my-zsh + sources `~/.config/zsh/*.zsh` |
| `~/.zshenv` | Cargo env (runs for every shell, including scripts) |
| `~/.zprofile` | Homebrew shellenv + pipx PATH (login shells) |
| `~/.config/zsh/00-path.zsh` | PATH deduplication |
| `~/.config/zsh/10-env.zsh` | EDITOR, XDG dirs, BAT_THEME, NVM_DIR |
| `~/.config/zsh/20-aliases.zsh` | Modern CLI aliases: bat, eza, kubecolor, lazygit |
| `~/.config/zsh/30-completions.zsh` | kubectl completion cache + kubecolor compdef + iTerm2 integration |
| `~/.config/zsh/40-tools.zsh` | fzf (Ctrl-T/Alt-C), atuin (Ctrl-R), zoxide (replaces `cd`) |
| `~/.config/zsh/70-nvm.zsh` | Lazy NVM — loads Node only when first invoked |
| `~/.gitconfig` | delta pager, aliases, pull.rebase, LFS |
| `~/.p10k.zsh` | Powerlevel10k prompt config |
| `~/.tmux.conf` | tmux config — prefix Ctrl-A, mouse, vim nav, Catppuccin colors |

---

## Shell structure

`.zshrc` is a thin loader. The real config lives in numbered files under `~/.config/zsh/` — source order matters, hence the numeric prefixes. Add a new file and it gets picked up automatically on next shell start.

**Startup time: ~0.3s** (down from ~1.9s — lazy NVM is the main win).

Key tool decisions:
- **atuin** owns `Ctrl-R` (history). fzf handles `Ctrl-T` (files) and `Alt-C` (dirs).
- **zoxide** replaces `cd` transparently (`--cmd cd`). Use `zi` for the interactive picker.
- **nvm** is lazy-loaded — `node`, `npm`, `npx`, `yarn`, `pnpm` trigger the load on first call.
- **kubecolor** is aliased to `kubectl`; completions delegate to the real `kubectl` binary.

---

## tmux

New to tmux? Start here: [docs/tmux-guide.md](docs/tmux-guide.md)

Config highlights: prefix is `Ctrl-A`, mouse is on, pane navigation is vim-style (`h/j/k/l`), `|` and `-` split the screen, copy mode yanks to `pbcopy`.

---

## Updating

After editing a managed file:

```bash
chezmoi re-add ~/.config/zsh/20-aliases.zsh   # sync changes back to the repo
cd ~/.local/share/chezmoi && git add -A && git commit -m "update aliases"
git push
```

Or edit directly in the chezmoi source and apply:

```bash
chezmoi edit ~/.zshrc        # opens in $EDITOR
chezmoi apply                # applies changes
```
