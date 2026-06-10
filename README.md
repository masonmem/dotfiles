# dotfiles

macOS dev environment. Apple Silicon, zsh, Homebrew. Managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Intent

This repo is the source of truth for **every Mac I sign into** — laptop, mini, work machine, whatever. The promise: the same `~/.zshrc`, the same `Brewfile`, the same agent stack (opencode + aider + goose + Claude Code + Copilot CLI), the same aliases on each one. So SSH-ing into any tailnet Mac from a phone (Termius/Blink) drops me into a TTY that feels identical to the laptop I just left.

**Bidirectional flow.** Edit on any Mac → commit → push. On any other Mac, run one command:

```bash
sync-all
```

That pulls the latest, installs any new Homebrew packages added to the [Brewfile](Brewfile), re-stows shell config, and pulls the parallel AI-brain repo (`masonmem/ai-config`) so global skills / MCP / Claude-Code-and-Copilot-CLI instructions stay in sync. Idempotent and direction-agnostic — same command on every host, regardless of where the change originated.

Secrets (`~/.ai-config/secrets/*`) are **not** in this repo (gitignored, plaintext, `chmod 600`). They cross-sync between hosts with `secrets-push <other-host>` — see [the secrets discussion in `masonmem/homelab` § Operator-workstation secrets](https://github.com/masonmem/homelab/blob/main/docs/security.md#operator-workstation-secrets--aiconfigsecrets-safe).

---

## Bootstrap a fresh Mac

```bash
# 1. Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Clone this repo and the AI-brain repo
git clone git@github.com:masonmem/dotfiles.git    ~/dotfiles
git clone git@github.com:masonmem/ai-config.git   ~/.ai-config

# 3. Install everything in the Brewfile (formulae + casks — pinned set)
brew bundle --file=~/dotfiles/Brewfile

# 4. Install pipx-managed Python CLIs (not covered by brew bundle; see pipx-tools.txt)
grep -v '^#' ~/dotfiles/pipx-tools.txt | grep . | xargs -n1 pipx install

# 5. Install Rust toolchain (needed for the .zshenv cargo env)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# 6. Install oh-my-zsh + powerlevel10k + zsh plugins (git clone, idempotent —
#    these are NOT in the Brewfile; the omz custom/ layout is the only mechanism)
bash ~/dotfiles/bin/bootstrap-shell

# 7. Stow the dotfile packages you want (see Packages table below)
cd ~/dotfiles && stow --no-folding zsh p10k tmux git nvim lazygit atuin

# 8. Set up the AI-brain symlinks (Copilot CLI and/or Claude Code)
# Copilot CLI:
mkdir -p ~/.copilot
ln -sfn ~/.ai-config/instructions.md          ~/.copilot/copilot-instructions.md
ln -sfn ~/.ai-config/skills                   ~/.copilot/skills
ln -sfn ~/.ai-config/bin                      ~/.copilot/bin
ln -sfn ~/.ai-config/mcp.json                 ~/.copilot/mcp-config.json
ln -sfn ~/.ai-config/secrets                  ~/.copilot/secrets
ln -sfn ~/.ai-config/copilot/settings.json    ~/.copilot/settings.json
# Claude Code (if installed):
bash ~/.ai-config/bin/bootstrap-claude.sh

# 9. Per-Mac files (templates / examples — none of these are stowed)
cp ~/dotfiles/ssh/.ssh/config ~/.ssh/config       # then edit for this Mac's hosts
${EDITOR:-vi} ~/.gitconfig.local                  # name/email
# Optional: per-host shell overrides
cp ~/dotfiles/zsh/.config/zsh/90-host.zsh.example \
   ~/.config/zsh/90-$(hostname -s).zsh

# 10. Populate machine-local secrets (or sync from another Mac you trust)
mkdir -p ~/.ai-config/secrets   # placeholder; populate per-tool as needed
# From an already-set-up Mac: ssh into this one and run `secrets-push <this-mac>`
```

> **Why `--no-folding`?** Without it, stow symlinks entire directories (`~/.config/zsh → dotfiles/zsh/.config/zsh`). With it, stow links individual files, leaving room for untracked per-host overlays (`90-<hostname>.zsh`) alongside the stowed files.

### Bootstrap on a non-Mac host (QNAP, Linux, etc.)

The shell config is portable — same `.zshrc`, `.zprofile`, `.zshenv`, and `~/.config/zsh/*.zsh` work on any host with zsh. The catch: no Homebrew, so substitute the host's package manager. oh-my-zsh / powerlevel10k come via `bin/bootstrap-shell` (git clone) on every host, Mac or not.

```bash
# Adjust the package install line for your host (apt/apk/opkg/pacman/dnf):
# QNAP via Entware:
/opt/bin/opkg install zsh git bash eza fd fzf jq neovim ripgrep tmux htop nano

# Clone the repo (HTTPS if no SSH key yet; switch to SSH after)
git clone git@github.com:masonmem/dotfiles.git ~/dotfiles

# Install oh-my-zsh + powerlevel10k + the two plugins (same script as the Mac path)
bash ~/dotfiles/bin/bootstrap-shell

# Symlink the tracked files. `stow` works if available; if not (Entware
# doesn't ship it), do the equivalent by hand — the README's "How stow
# works" diagram shows the target layout.
cd ~/dotfiles
command -v stow >/dev/null && stow --no-folding zsh p10k || {
  for src in zsh/.zshrc zsh/.zprofile zsh/.zshenv; do
    ln -sfn "$PWD/$src" "$HOME/$(basename $src)"
  done
  mkdir -p ~/.config/zsh
  for src in zsh/.config/zsh/*.zsh; do
    ln -sfn "$PWD/$src" "$HOME/.config/zsh/$(basename $src)"
  done
  ln -sfn "$PWD/zsh/.config/zsh/completions" ~/.config/zsh/completions
  ln -sfn "$PWD/p10k/.p10k.zsh" ~/.p10k.zsh
}

# (Optional) per-host shell config — copy + edit the template
cp zsh/.config/zsh/90-host.zsh.example ~/.config/zsh/90-$(hostname -s).zsh

# Per-host overrides go in ~/.zshrc.early.local (untracked, sourced
# before oh-my-zsh + p10k init — useful for POWERLEVEL9K_* vars).
```

**QNAP-specific quirks**, in case anyone else runs into them on an embedded zsh build:

1. **`setopt monitor` fails.** Entware's zsh build doesn't allow enabling job control. `gitstatus.plugin.zsh` line 604 (`setopt monitor || return`) aborts p10k's gitstatus init. Patch by replacing `|| return` with `2>/dev/null || true`.
2. **`mkfifo` is missing.** QNAP's busybox doesn't ship a standalone `mkfifo`, but gitstatusd needs it for IPC. Install it manually because Entware's `coreutils-mkfifo` package can't write to `/opt/libexec` without root:
   ```sh
   # On any other Linux/Mac with `ar`+`tar`:
   curl -sLO http://bin.entware.net/x64-k3.2/coreutils-mkfifo_9.9-2_x64-3.2.ipk
   # (the .ipk is just a gzipped tarball-of-tarballs)
   mkdir extract && tar xzf coreutils-mkfifo_9.9-2_x64-3.2.ipk -C extract
   tar xzf extract/data.tar.gz -C extract
   scp extract/opt/libexec/mkfifo-coreutils <qnap>:bin/mkfifo
   ssh <qnap> 'chmod +x ~/bin/mkfifo'
   # ~/bin is already on the dotfiles PATH (via 00-path.zsh).
   ```

Both fixes are bundled into `~/bin/qnap-gitstatus-fix` (idempotent re-patcher) on hyperion — run it after any future `cd ~/.oh-my-zsh/custom/themes/powerlevel10k && git pull` to re-apply the gitstatus patch.

Stowed-config quirks on non-Macs are handled automatically by the dotfiles: `.zprofile`'s `brew shellenv` is guarded behind `[[ -x /opt/homebrew/bin/brew ]]`, `.zshenv`'s cargo source is guarded behind `[[ -r ~/.cargo/env ]]`, and the `macos` oh-my-zsh plugin only loads on Darwin. Entware paths (`/opt/bin`, `/opt/usr/bin`) are added to PATH conditionally — Mac hosts skip them because the dirs don't exist.

---

## Day-to-day sync

```bash
sync-all              # pull dotfiles + ai-config; install new brew packages
sync-all dotfiles     # only one if you want
sync-all ai-config
```

Same command on every Mac. Bails on a dirty working tree in either repo (won't trample local edits).

After rotating a secret on machine A and you want machine B to pick it up:

```bash
# from A:
secrets-push B
```

(Or hostname instead of "B" — `secrets-push` defaults to `solaris` since that's the always-on box, but accepts any SSH host alias.)

---

## How stow works

Each subdirectory is a **package**. `stow <package>` creates symlinks from `~` into that package, mirroring its directory structure. Files live in `~/dotfiles/` — edits to either the symlink target or the repo file are live immediately.

```text
~/dotfiles/zsh/.zshrc                       →  stow  →  ~/.zshrc                       (symlink)
~/dotfiles/zsh/.config/zsh/20-aliases.zsh   →  stow  →  ~/.config/zsh/20-aliases.zsh   (symlink)
```

| Operation              | Command                          |
| ---------------------- | -------------------------------- |
| Link a package         | `stow --no-folding <package>`    |
| Unlink a package       | `stow -D <package>`              |
| Re-link after changes  | `stow --no-folding -R <package>` |
| Preview (dry run)      | `stow -n --no-folding <package>` |

---

## Packages

| Package    | What it manages                                                          | Stow universally?              |
| ---------- | ------------------------------------------------------------------------ | ------------------------------ |
| `zsh/`     | `.zshrc`, `.zprofile`, `.zshenv`, `.config/zsh/**`                       | ✅ Yes                          |
| `p10k/`    | `.p10k.zsh`                                                              | ✅ Yes                          |
| `tmux/`    | `.tmux.conf`                                                             | ✅ Yes                          |
| `git/`     | `.gitconfig`                                                             | ✅ Yes                          |
| `nvim/`    | `.config/nvim/init.lua`                                                  | ✅ Yes                          |
| `lazygit/` | `.config/lazygit/config.yml`                                             | ✅ Yes                          |
| `atuin/`   | `.config/atuin/config.toml`, themes                                      | ✅ Yes                          |
| `ollama/`  | Local Ollama tuning + LiteLLM gateway env, agent wiring (aider/opencode/goose) | **Opt-in.** Don't stow on work machines unless you've cleared local-LLM tooling with your employer. |
| `ssh/`     | `.ssh/config`                                                            | ❌ Template only — copy + edit  |

---

## What's NOT stowed (and why)

Machine-specific or sensitive — kept on each Mac, not in the repo.

| File                                  | Purpose                                          | Bootstrap                                                          |
| ------------------------------------- | ------------------------------------------------ | ------------------------------------------------------------------ |
| `~/.gitconfig.local`                  | `[user]` name/email, host-local URLs, and per-host overrides for stowed config (e.g. set `[core] pager = less -FRX` on hosts that don't have `delta` installed) | Create manually — `[include]` from `~/.gitconfig` loads it (last include wins on duplicate keys) |
| `~/.gitignore_global`                 | Global git ignores (`.DS_Store`, `.env`, etc.)   | Create manually                                                    |
| `~/.ssh/config`                       | SSH hosts, keys, algorithms                      | `cp ~/dotfiles/ssh/.ssh/config ~/.ssh/config` then edit            |
| `~/.config/zsh/90-<hostname>.zsh`     | Per-host shell overrides (`k8s` contexts, etc.)  | Copy `90-host.zsh.example` to `90-<hostname>.zsh`                  |
| `~/.nvm/`                             | Node versions managed by nvm                     | `mkdir -p ~/.nvm`                                                  |

The `.zshrc` auto-sources `~/.config/zsh/*.zsh` in alphabetical order. Numbered files in the 90-* range run last — perfect for overriding earlier aliases or env vars per host.

---

## What each file does

| File                                  | Purpose                                                                                            |
| ------------------------------------- | -------------------------------------------------------------------------------------------------- |
| `Brewfile`                            | Curated list of formulae + casks (shared across machines)                                          |
| `bin/sync-all`                        | One-command pull of dotfiles + ai-config + brew bundle                                             |
| `bin/dotfiles-sync`                   | Pull this repo + brew bundle + re-stow                                                             |
| `bin/secrets-push`                    | Rsync `~/.ai-config/secrets/` to another Mac (chmod 600 enforced)                                  |
| `bin/dexec`                           | Convenience helper for `docker exec`                                                               |
| `scripts/devcontainer-tools.sh`       | Installs CLI tools inside Linux dev containers                                                     |
| `~/.zshrc`                            | Shell entry point — loads oh-my-zsh + sources `~/.config/zsh/*.zsh`                                |
| `~/.zshenv`                           | Cargo env (runs for every shell, including scripts)                                                |
| `~/.zprofile`                         | Homebrew shellenv + pipx PATH (login shells)                                                       |
| `~/.config/zsh/00-path.zsh`           | PATH deduplication                                                                                 |
| `~/.config/zsh/05-devcontainer.zsh`   | Auto-installs tools on first container shell launch                                                |
| `~/.config/zsh/10-env.zsh`            | EDITOR, XDG dirs, BAT_THEME, NVM_DIR                                                               |
| `~/.config/zsh/20-aliases.zsh`        | Modern CLI aliases (bat/eza/kubecolor/lazygit/nvim) — all `command -v`-guarded so missing tools don't shadow real ones |
| `~/.config/zsh/30-completions.zsh`    | kubectl completion cache + kubecolor compdef                                                       |
| `~/.config/zsh/40-tools.zsh`          | fzf (Ctrl-T/Alt-C), atuin (Ctrl-R), zoxide (replaces `cd`)                                         |
| `~/.config/zsh/70-nvm.zsh`            | Lazy NVM — loads Node only when first invoked                                                      |
| `~/.config/zsh/90-host.zsh.example`   | Template for per-host overrides — copy to `90-<hostname>.zsh` (untracked)                          |
| `~/.gitconfig`                        | delta pager, aliases, `[include] ~/.gitconfig.local`                                               |
| `~/.config/nvim/init.lua`             | Neovim — lazy.nvim, treesitter, telescope, catppuccin                                              |
| `~/.config/lazygit/config.yml`        | lazygit — delta diffs, catppuccin theme, nvim integration                                          |
| `~/.p10k.zsh`                         | Powerlevel10k prompt config                                                                        |
| `~/.tmux.conf`                        | tmux — prefix Ctrl-B, mouse, vim nav, catppuccin status bar                                        |

---

## Shell structure

`.zshrc` is a thin loader. The real config lives in numbered files under `~/.config/zsh/`. Source order matters, hence the numeric prefixes. Add a new file and it's picked up automatically on next shell start.

**Per-host overrides:** copy `90-host.zsh.example` to `~/.config/zsh/90-<hostname>.zsh` (untracked) for anything Mac-specific. Sources last, so it can override anything earlier in the chain.

**Devcontainer support:** `.zshrc` detects the `DEVCONTAINER=1` env var and adjusts plugins accordingly (skips macOS-only plugins). The `05-devcontainer.zsh` file bootstraps CLI tools on first shell open inside a container.

**Tooling note:** every alias in `20-aliases.zsh` that depends on an optional binary (`bat`, `eza`, `nvim`, `lazygit`, `kubecolor`, `yt-dlp`) is gated with `command -v` so a host without the tool falls back to the underlying command (`cat`, `ls`, `vi`, etc.) instead of shadowing it with something missing. This makes the same config usable on minimal hosts (Linux dev containers, NAS shells with limited tooling) without per-host carve-outs.

Key tooling:

- **atuin** owns `Ctrl-R` (history search). fzf handles `Ctrl-T` (file picker) and `Alt-C` (dir picker).
- **zoxide** replaces `cd` transparently (`--cmd cd`). Use `zi` for the interactive picker.
- **nvm** is lazy-loaded — `node`, `npm`, `npx`, `yarn`, `pnpm` trigger the load on first call.
- **kubecolor** is aliased to `kubectl`; completions delegate to the real `kubectl` binary.
- **delta** is the git pager for both CLI (`git diff`) and lazygit. Shared syntax theme (Catppuccin).

---

## Brewfile workflow

The Brewfile is a curated manifest of top-level packages (not a dump of everything installed). To keep it in sync:

```bash
# Install everything in the Brewfile (idempotent — skips already-installed)
brew bundle --file=~/dotfiles/Brewfile

# After manually installing something new you want everywhere:
# → Edit ~/dotfiles/Brewfile, add the line, commit & push
# → Other Macs pick it up next time they run `sync-all`

# See what's installed but NOT in the Brewfile (drift):
brew bundle cleanup --file=~/dotfiles/Brewfile

# See what's in the Brewfile but NOT installed (missing):
brew bundle check --file=~/dotfiles/Brewfile --verbose
```

> **Don't use `brew bundle dump`** to overwrite the Brewfile — it captures every transitive dependency and machine-specific noise. Maintain the Brewfile manually as the "what I want everywhere" list.

---

## Devcontainer support

The shell config is designed to work inside Linux dev containers. The setup:

1. **Mount host config into container** — `.zshrc`, `.oh-my-zsh`, `.p10k.zsh`, `~/.config/zsh/`, git config, nvim/lazygit config.
2. **Auto-install CLI tools** — `05-devcontainer.zsh` runs `scripts/devcontainer-tools.sh` on first shell open (installs bat, eza, fd, rg, fzf, zoxide, atuin, lazygit, nvim, delta from pre-built Linux binaries).
3. **Graceful degradation** — all tool init scripts use `command -v` guards; missing tools are silently skipped (same pattern as the alias guards).

Mount these volumes in your `docker-compose.override.yml`:

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

Other Macs pick up the change on their next `sync-all`.

### Optional: cron / launchd auto-sync

`sync-all` runs cleanly under launchd. On a Mac you want to keep up-to-date passively, drop in `~/Library/LaunchAgents/sh.user.sync-all.plist` with `StartInterval` of 600 (10 min) pointing at `/opt/homebrew/bin/sync-all` (or your equivalent path). Mirror the structure used by the `notes-sync` / `komodo-monitor` plists in the homelab repo. Not enabled by default — opt in when you trust the flow.

### Sanity-check parity across two Macs

```sh
# Same dotfiles HEAD?
ssh <other-mac> 'git -C ~/dotfiles rev-parse HEAD'
git -C ~/dotfiles rev-parse HEAD

# Same Brewfile state?
brew bundle check --file=~/dotfiles/Brewfile
ssh <other-mac> '/opt/homebrew/bin/brew bundle check --file=~/dotfiles/Brewfile'
```
