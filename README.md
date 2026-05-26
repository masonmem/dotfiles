# dotfiles

macOS dev environment. Apple Silicon, zsh, Homebrew. Managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Intent: two-Mac parity, gitops sync

This repo is the source of truth for **both** Macs on the tailnet:

| Host | Role | Uptime |
|---|---|---|
| **navi** (laptop) | Primary dev machine. Code, edit, push. | Comes and goes. |
| **solaris** (Mac Mini M2 Pro) | Always-on TTY + model host. SSH-into-from-anywhere via Tailscale; runs Ollama, LiteLLM, OWUI, MCP bridges. | 24/7. |

The promise: **identical shell environment on both.** Same zsh config, same Brewfile, same opencode + aider + goose wiring, same secrets layout under `~/.copilot/secrets/`. So `ssh solaris` from a phone (Termius/Blink over Tailscale) drops me into a TTY that feels exactly like navi — same aliases, same models, same agent stack.

**Push from navi → pull on solaris.** Edit on the laptop, commit, push to `masonmem/dotfiles`. Then run `dotfiles-sync` on solaris (or wait for the optional launchd timer — see below) and the change propagates: `git pull --ff-only`, `brew bundle --no-upgrade` for any new tools, `stow -R` to re-link.

Secrets (`~/.copilot/secrets/*`) are **not** in this repo; they're copied out-of-band and mirrored manually when rotated.

---

## Bootstrap a new machine

```bash
# 1. Install Homebrew, then restore all formulae + casks
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew bundle --file=~/dotfiles/Brewfile

# 2. Install Rust (needed for .zshenv cargo env)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# 3. Clone and stow
git clone git@github.com:masonmem/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow --no-folding zsh p10k tmux git nvim lazygit atuin

# 4. Create machine-local files (see "What's NOT stowed" below)
cp ~/.gitconfig.local.example ~/.gitconfig.local   # fill in name/email
mkdir -p ~/.nvm ~/.ssh/sockets
```

> **Why `--no-folding`?** Without it, stow symlinks entire directories (e.g. `~/.config/zsh → dotfiles/zsh/.config/zsh`). With `--no-folding`, stow links individual files, leaving room for local (untracked) files like `90-work.zsh` alongside the stowed ones.

---

## How stow works

Each subdirectory is a **package**. Running `stow <package>` creates symlinks from `~` into that package, mirroring its directory structure. Files live in `~/dotfiles/` — edits are live immediately.

```text
~/dotfiles/zsh/.zshrc  →  stow  →  ~/.zshrc  (symlink)
~/dotfiles/zsh/.config/zsh/20-aliases.zsh  →  ~/.config/zsh/20-aliases.zsh  (symlink)
```

| Operation              | Command                        |
| ---------------------- | ------------------------------ |
| Link a package         | `stow --no-folding <package>`  |
| Unlink a package       | `stow -D <package>`            |
| Re-link after changes  | `stow --no-folding -R <package>` |
| Preview (dry run)      | `stow -n --no-folding <package>` |

---

## Packages

| Package    | What it manages                                    | Stow on all machines? |
| ---------- | -------------------------------------------------- | --------------------- |
| `zsh/`     | `.zshrc`, `.zprofile`, `.zshenv`, `.config/zsh/**` | ✅ Yes                |
| `p10k/`    | `.p10k.zsh`                                        | ✅ Yes                |
| `tmux/`    | `.tmux.conf`                                       | ✅ Yes                |
| `git/`     | `.gitconfig`                                       | ✅ Yes                |
| `nvim/`    | `.config/nvim/init.lua`                            | ✅ Yes                |
| `lazygit/` | `.config/lazygit/config.yml`                       | ✅ Yes                |
| `atuin/`   | `.config/atuin/config.toml`, themes                | ✅ Yes                |
| `ollama/`  | Local Ollama tuning + LiteLLM gateway env (`litellm-keys`, aider/opencode wiring) | Opt-in (see `ollama/README.md`) |
| `ssh/`     | `.ssh/config`                                      | ❌ Template only      |

> **`ssh/` is not stowed** — SSH configs contain machine-specific hosts, keys, and algorithms. Keep `~/.ssh/config` local on each machine. The `ssh/` package is a reference template for bootstrapping new machines (`cp ~/dotfiles/ssh/.ssh/config ~/.ssh/config`, then edit).

---

## What's NOT stowed (and why)

These files live on each machine but are **not tracked in the repo**. They contain machine-specific or sensitive values.

| File                   | Purpose                                       | Create manually          |
| ---------------------- | --------------------------------------------- | ------------------------ |
| `~/.gitconfig.local`   | `[user]` name/email, machine-specific URLs    | Yes — `[include]` loads it |
| `~/.gitignore_global`  | Global git ignores (DS_Store, .env, etc.)     | Yes                      |
| `~/.ssh/config`        | SSH hosts, keys, algorithms                   | Yes (copy from `ssh/` template) |
| `~/.config/zsh/90-*.zsh` | Machine-specific shell config (k8s, paths) | Optional                 |
| `~/.nvm/`             | Node versions managed by nvm                   | `mkdir -p ~/.nvm`        |

The `.zshrc` auto-sources all `~/.config/zsh/*.zsh` files — add a numbered file (e.g. `90-work.zsh`) for machine-specific config without touching the repo.

---

## What each file does

| File                               | Purpose                                                             |
| ---------------------------------- | ------------------------------------------------------------------- |
| `Brewfile`                         | Curated list of brew formulae + casks (shared across machines)      |
| `scripts/devcontainer-tools.sh`    | Installs CLI tools inside Linux dev containers                      |
| `~/.zshrc`                         | Shell entry point — loads oh-my-zsh + sources `~/.config/zsh/*.zsh` |
| `~/.zshenv`                        | Cargo env (runs for every shell, including scripts)                 |
| `~/.zprofile`                      | Homebrew shellenv + pipx PATH (login shells)                        |
| `~/.config/zsh/00-path.zsh`        | PATH deduplication                                                  |
| `~/.config/zsh/05-devcontainer.zsh`| Auto-installs tools on first container shell launch                 |
| `~/.config/zsh/10-env.zsh`         | EDITOR, XDG dirs, BAT_THEME, NVM_DIR                                |
| `~/.config/zsh/20-aliases.zsh`     | Modern CLI aliases: bat, eza, kubecolor, lazygit                    |
| `~/.config/zsh/30-completions.zsh` | kubectl completion cache + kubecolor compdef                        |
| `~/.config/zsh/40-tools.zsh`       | fzf (Ctrl-T/Alt-C), atuin (Ctrl-R), zoxide (replaces `cd`)          |
| `~/.config/zsh/70-nvm.zsh`         | Lazy NVM — loads Node only when first invoked                       |
| `~/.gitconfig`                     | delta pager, aliases, `[include] ~/.gitconfig.local`                |
| `~/.config/nvim/init.lua`          | Neovim — lazy.nvim, treesitter, telescope, catppuccin               |
| `~/.config/lazygit/config.yml`     | lazygit — delta diffs, catppuccin theme, nvim integration           |
| `~/.p10k.zsh`                      | Powerlevel10k prompt config                                         |
| `~/.tmux.conf`                     | tmux — prefix Ctrl-B, mouse, vim nav, catppuccin status bar         |

---

## Shell structure

`.zshrc` is a thin loader. The real config lives in numbered files under `~/.config/zsh/`. Source order matters, hence the numeric prefixes. Add a new file and it gets picked up automatically on next shell start.

**Devcontainer support:** `.zshrc` detects the `DEVCONTAINER=1` env var and adjusts plugins accordingly (skips macOS-only plugins). The `05-devcontainer.zsh` file bootstraps CLI tools on first shell open inside a container.

Key tooling:

- **atuin** owns `Ctrl-R` (history search). fzf handles `Ctrl-T` (file picker) and `Alt-C` (dir picker).
- **zoxide** replaces `cd` transparently (`--cmd cd`). Use `zi` for the interactive picker.
- **nvm** is lazy-loaded — `node`, `npm`, `npx`, `yarn`, `pnpm` trigger the load on first call.
- **kubecolor** is aliased to `kubectl`; completions delegate to the real `kubectl` binary.
- **delta** is the git pager for both CLI (`git diff`) and lazygit. Shared syntax theme (Catppuccin).

---

## Keeping machines in sync

### Pulling dotfile changes

Both machines point to the same repo. On either machine:

```bash
cd ~/dotfiles && git pull
stow --no-folding -R zsh p10k tmux git nvim lazygit atuin
```

Stow `-R` (restow) removes old symlinks and creates new ones — handles added/removed files.

### Brewfile workflow

The Brewfile is a curated manifest of top-level packages (not a dump of everything installed). To keep it in sync:

```bash
# Install everything in the Brewfile (idempotent — skips already-installed)
brew bundle --file=~/dotfiles/Brewfile

# After manually installing something new you want everywhere:
# → Edit ~/dotfiles/Brewfile, add the line, commit & push

# See what's installed but NOT in the Brewfile (finds drift):
brew bundle cleanup --file=~/dotfiles/Brewfile

# See what's in the Brewfile but NOT installed (finds missing):
brew bundle check --file=~/dotfiles/Brewfile --verbose
```

> **Don't use `brew bundle dump`** to overwrite the Brewfile — it captures every transitive dependency and machine-specific noise. Maintain the Brewfile manually as the "what I want" list.

### Adding a new tool

1. `brew install <tool>` on either machine
2. Add it to `~/dotfiles/Brewfile` with a comment
3. Commit, push
4. On other machine: `git pull && brew bundle --file=~/dotfiles/Brewfile`

---

## Devcontainer support

The shell config is designed to work seamlessly inside Linux dev containers. The setup:

1. **Mount host config into container** — `.zshrc`, `.oh-my-zsh`, `.p10k.zsh`, `~/.config/zsh/`, git config, nvim/lazygit config
2. **Auto-install CLI tools** — `05-devcontainer.zsh` runs `scripts/devcontainer-tools.sh` on first shell open (installs bat, eza, fd, rg, fzf, zoxide, atuin, lazygit, nvim, delta from pre-built Linux binaries)
3. **Graceful degradation** — all tool init scripts use `command -v` guards; if a tool isn't available, it's silently skipped

To set up a project's devcontainer, mount these volumes in your `docker-compose.override.yml`:

```yaml
volumes:
  - ${HOME}/.zshrc:/root/.zshrc:ro
  - ${HOME}/.oh-my-zsh:/root/.oh-my-zsh:ro
  - ${HOME}/.p10k.zsh:/root/.p10k.zsh:ro
  - ${HOME}/.config/zsh:/root/.config/zsh:ro
  - ${HOME}/.gitconfig:/root/.gitconfig:ro
  - ${HOME}/.gitconfig.local:/root/.gitconfig.local:ro
  - ${HOME}/.config/lazygit:/root/.config/lazygit:ro
  - ${HOME}/.config/nvim:/root/.config/nvim:ro
  - ${HOME}/dotfiles/scripts:/opt/dotfiles-scripts:ro
environment:
  - DEVCONTAINER=1
  - SHELL=/bin/zsh
  - TERM=xterm-256color
  - LANG=C.UTF-8
  - LC_ALL=C.UTF-8
```

---

## Guides

| Guide                                                        | Topic                                               |
| ------------------------------------------------------------ | --------------------------------------------------- |
| [docs/neovim-guide.md](docs/neovim-guide.md)                 | Neovim config, plugins, keybindings, modal editing  |
| [docs/lazygit-guide.md](docs/lazygit-guide.md)               | lazygit TUI — staging, commits, rebase, cherry-pick |
| [docs/tmux-guide.md](docs/tmux-guide.md)                     | tmux sessions, windows, panes, copy mode            |
| [docs/shell-tools-guide.md](docs/shell-tools-guide.md)       | fzf, atuin, zoxide, bat, eza, fd, ripgrep           |

---

## Editing dotfiles

Stow uses symlinks — edit files at `~/.zshrc` or `~/dotfiles/zsh/.zshrc` (same file). Then commit:

```bash
cd ~/dotfiles
git add -A
git commit -m "feat: ..."
git push
```

---

## Syncing across machines

After committing on one machine, propagate to the other:

```sh
# On the other machine (or via ssh):
dotfiles-sync
```

What it does (idempotent, refuses to run on a dirty tree):
1. `git pull --ff-only` (never rebase / auto-merge)
2. `brew bundle --no-upgrade` — installs missing formulae from `Brewfile`, does NOT upgrade existing
3. `stow --no-folding -R` each package — safe re-link

### Optional: auto-sync on solaris via launchd

solaris is the always-on box, so it's the natural target for a timer. Drop in `~/Library/LaunchAgents/sh.user.dotfiles-sync.plist` with `StartInterval` of e.g. 600 (10 min) and `ProgramArguments` pointing at `dotfiles-sync`. Mirror the pattern used by `sh.user.notes-sync.plist`. Not enabled by default — opt in when you trust the flow.

### Sanity-check parity

```sh
# diff Brewfile vs installed formulae on either host
brew bundle check --file=~/dotfiles/Brewfile

# confirm same dotfiles HEAD on both
ssh solaris 'git -C ~/dotfiles rev-parse HEAD'
git -C ~/dotfiles rev-parse HEAD
```
