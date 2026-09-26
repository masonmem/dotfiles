# dotfiles

One repo for every machine I use: macOS on Apple Silicon (zsh + Homebrew), plus
a QNAP NAS and Linux dev containers. Configs are symlinked into `$HOME` with
[GNU Stow](https://www.gnu.org/software/stow/).

- **Same everywhere:** shell, prompt, aliases, tmux, git, Neovim, lazygit, atuin,
  and a shared set of CLI tools. SSH into any box and it feels like the laptop.
- **Personal stays personal:** personal-only software and config live in opt-in
  packages that are never linked or installed on the work machine.
- **One command to converge:** change something on any machine, commit, push;
  every other machine picks it up with `sync-all`.

## Quick start: a new machine

```bash
# 1. Homebrew (macOS) — https://brew.sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. This repo. It must live at ~/dotfiles.
git clone https://github.com/masonmem/dotfiles.git ~/dotfiles
#    (Use HTTPS until this machine has an SSH key, then:
#     git -C ~/dotfiles remote set-url origin git@github.com:masonmem/dotfiles.git)

# 3. Everything else
~/dotfiles/install.sh personal   # personal Macs
~/dotfiles/install.sh work       # the work machine: shared config only
~/dotfiles/install.sh minimal    # servers / QNAP: zsh + prompt + git

# 4. Agent config (skills, MCP, instructions) lives in its own repo
git clone git@github.com:masonmem/ai-sync.git ~/code/ai-sync
~/code/ai-sync/install.sh        # work machine: --work
```

`install.sh` writes this host's package list, copies the untracked templates
(`~/.gitconfig.local`, `~/.ssh/config`), and runs `dotfiles-sync`. Existing
files that would block a link are moved to `<file>.pre-dotfiles`. It is safe to
re-run. Afterwards, set your git identity in `~/.gitconfig.local` and open a new
terminal.

## Day to day

```bash
sync-all            # dotfiles + ai-sync
sync-all dotfiles   # just this repo
```

`dotfiles-sync` (the dotfiles half) does, in order:

1. **pull**: fast-forward from GitHub. If you have uncommitted changes, local
   commits that diverged, or no network, it skips the pull with a warning and
   still does the rest. If the pull changed `dotfiles-sync` itself, it re-runs
   the new version.
2. **brew**: `Brewfile`, then each enabled package's `Brewfile`, then
   `Brewfile.d/<host>.Brewfile`. It only installs what's missing and never
   upgrades.
3. **pipx**: each enabled package's `pipx-tools.txt` (missing tools only).
4. **shell framework**: `bootstrap-shell` moves oh-my-zsh, powerlevel10k and
   the plugins to the commits pinned in `shell-clones.txt`.
5. **link**: `stow --no-folding -R` for each enabled package (a built-in
   equivalent where stow isn't installed), then removes symlinks to files that
   were deleted from the repo.

To change something, edit the file (the symlink or `~/dotfiles/...`, it's the
same file), run `tests/run`, commit, push. New, changed, renamed and deleted
files all reach the other machines on their next `sync-all`.

## Packages and profiles

A top-level directory with files laid out as they should appear in `$HOME` is a
**package**. Each host enables a set of packages in
`~/.config/dotfiles/packages` (untracked, one name per line). `install.sh`
writes it from a profile, and you can edit it any time. There is deliberately no
default, so a machine never gets personal packages by accident.

| Package | Contents | personal | work | minimal |
|---|---|:-:|:-:|:-:|
| `zsh` | `.zshenv`, `.zprofile`, `.zshrc`, `.config/zsh/*.zsh` | ✅ | ✅ | ✅ |
| `p10k` | `.p10k.zsh` (prompt) | ✅ | ✅ | ✅ |
| `git` | `.gitconfig`, global ignore | ✅ | ✅ | ✅ |
| `tmux` | `.tmux.conf` | ✅ | ✅ | |
| `nvim` | `.config/nvim/init.lua` | ✅ | ✅ | |
| `lazygit` | `.config/lazygit/config.yml` | ✅ | ✅ | |
| `atuin` | `.config/atuin/` | ✅ | ✅ | |
| `personal` | personal-only shell config (Copilot telemetry, media and VPN aliases); homelab and media tools (`Brewfile`); MCP servers etc. (`pipx-tools.txt`) | ✅ | | |
| `ollama` | local-LLM agent stack: aider / opencode / goose configs, LiteLLM keys, and their `Brewfile`. See [ollama/README.md](ollama/README.md). | ✅ | | |

A package can hold files that are *not* linked. Its `.stow-local-ignore` lists
them: a `Brewfile` or `pipx-tools.txt` for `dotfiles-sync`, a README, or server
files such as `ollama/launchagents/`.

### Where does this go?

| I want… | Put it in |
|---|---|
| a tool on every Mac, including work | `Brewfile` |
| a tool on personal Macs only | `personal/Brewfile` (or `ollama/Brewfile` for the LLM stack) |
| a tool on one host | `Brewfile.d/<host>.Brewfile` (host name lowercased; `dotfiles-sync` prints it) |
| a Python CLI on personal Macs | `personal/pipx-tools.txt` |
| shell config everywhere | `zsh/.config/zsh/NN-name.zsh` |
| shell config on personal Macs only | `personal/.config/zsh/` |
| shell config on one host | `~/.config/zsh/90-<host>.zsh`, untracked (start from `templates/zsh-host.zsh`) |
| git settings everywhere | `git/.gitconfig` |
| git identity, work git settings | `~/.gitconfig.local`, untracked (included last, so it overrides everything) |
| SSH hosts | `~/.ssh/config`, untracked |

### Machines

| Host | Profile | Brewfiles | ai-sync |
|---|---|---|---|
| **navi** (laptop) | personal | shared + personal + ollama + `navi` | full |
| **solaris** (Mac mini, always on) | personal | shared + personal + ollama + `solaris` | full |
| **work MacBook** | work | shared | `--work`, no personal secrets |
| **hyperion** (QNAP) | minimal | none (Entware `opkg`) | none; sops age key only |
| **dev containers** | none; mounts the host's files | `scripts/devcontainer-tools.sh` | `--work --container` |

## Untracked, per-machine files

| File | Purpose | Created by |
|---|---|---|
| `~/.config/dotfiles/packages` | packages enabled on this host | `install.sh` |
| `~/.gitconfig.local` | `[user]` identity, work settings (`includeIf "gitdir:~/work/"`), host overrides | `install.sh`, from `templates/gitconfig.local` |
| `~/.ssh/config` | SSH hosts (`Host *` defaults go last) | `install.sh`, from `templates/ssh_config` |
| `~/.config/zsh/90-<host>.zsh` | per-host aliases/env, sourced last | you, from `templates/zsh-host.zsh` |
| `~/.zshrc.early.local` | settings needed before oh-my-zsh/p10k load (`ZSH_THEME`, `POWERLEVEL9K_*`) | you |
| `~/code/ai-sync/secrets/` | tokens (e.g. the GitHub PAT that `12-github-cli.zsh` exports as `GH_TOKEN`) | ai-sync |

## Shell

Startup order:

| File | Runs for | Does |
|---|---|---|
| `~/.zshenv` | every zsh, including `ssh host cmd`, scripts and launchd | **the** PATH definition (missing dirs dropped, no duplicates), XDG dirs |
| `~/.zprofile` | login shells | re-applies `.zshenv`, because macOS `path_helper` reorders PATH in between |
| `~/.zshrc` | interactive shells | `~/.zshrc.early.local`, p10k instant prompt, oh-my-zsh, then `~/.config/zsh/*.zsh` in name order |

| File | Purpose |
|---|---|
| `05-devcontainer.zsh` | inside containers only: install tools on first shell, apply work-safe ai-sync |
| `10-env.zsh` | `EDITOR` (nvim, falls back to vim/vi), `BAT_THEME`, `LESS`, `NVM_DIR` |
| `12-github-cli.zsh` | `GH_TOKEN` from the ai-sync PAT, if present |
| `20-aliases.zsh` | `cat`→bat, `ls`→eza, `vi`→nvim, `kubectl`→kubecolor, `cc`→claude, `lg`→lazygit; each only if the tool exists (containers keep native `ls`) |
| `30-completions.zsh` | kubectl completion, cached in `~/.cache/zsh/completions` |
| `40-tools.zsh` | `copilot` wrapper (drops the duplicate GitHub MCP), fzf (Ctrl-T, Alt-C), atuin (Ctrl-R, ↑), zoxide (`cd`, `zi`) |
| `70-nvm.zsh` | lazy nvm: loaded on first `nvm`/`node`/`npm`/`npx`/`yarn`/`pnpm` |

Everything degrades gracefully: a missing tool means a skipped alias or
integration, never a broken command. The same files work on macOS, Linux, QNAP
and in containers.

### Shell framework pins

oh-my-zsh, powerlevel10k, zsh-autosuggestions and zsh-syntax-highlighting are git
clones under `~/.oh-my-zsh` (that is where `.zshrc` loads them from), not
Homebrew formulae. [`shell-clones.txt`](shell-clones.txt) pins each to a commit.
`bootstrap-shell` clones anything missing and moves stale clones to the pin. It
does nothing, and touches no network, when a clone is already there. It leaves a
clone with local edits alone, apart from hyperion's QNAP patch, which it sets
aside and re-applies.

To upgrade: check out the new commit in the clone, confirm the prompt still
renders, update the SHA (and tag comment) in `shell-clones.txt`, then commit
and push.

## QNAP (hyperion)

```sh
/opt/bin/opkg install zsh git bash eza fd fzf jq neovim ripgrep tmux htop nano
git clone https://github.com/masonmem/dotfiles.git ~/dotfiles
~/dotfiles/install.sh minimal     # no stow on Entware: uses the built-in linker
```

QNAP quirks:

1. **`setopt monitor` fails** on Entware's zsh, which aborts p10k's gitstatus.
   [`bin/qnap-gitstatus-fix`](bin/qnap-gitstatus-fix) patches that line.
   `bootstrap-shell` runs it automatically whenever the p10k pin moves.
2. **`mkfifo` is missing** from QNAP's busybox, and gitstatusd needs it. Install
   it by hand to `~/bin` (Entware's package can't write `/opt/libexec` without
   root):
   ```sh
   # on any machine with curl + tar:
   curl -sLO http://bin.entware.net/x64-k3.2/coreutils-mkfifo_9.9-2_x64-3.2.ipk
   mkdir extract && tar xzf coreutils-mkfifo_9.9-2_x64-3.2.ipk -C extract
   tar xzf extract/data.tar.gz -C extract
   scp extract/opt/libexec/mkfifo-coreutils hyperion:bin/mkfifo
   ssh hyperion 'chmod +x ~/bin/mkfifo'
   ```
3. **`~/.profile` must hand login shells to zsh.** QNAP owns the sh login flow,
   so this file stays untracked. Recreate it on a rebuild:
   ```sh
   export PATH=$PATH:$(getcfg SHARE_DEF defVolMP -f /etc/config/def_share.info)/.qpkg/Tailscale/
   export PATH=/opt/bin:/opt/sbin:/opt/usr/bin:/opt/usr/sbin:$PATH
   export PATH=$PATH:/share/CACHEDEV3_DATA/.qpkg/container-station/bin
   # `tty -s` works even when busybox sshd doesn't set SSH_TTY.
   if [ -x /opt/bin/zsh ] && [ -z "$ZSH_VERSION" ] && [ -z "$SSH_ORIGINAL_COMMAND" ] && tty -s; then
     export SHELL=/opt/bin/zsh
     exec /opt/bin/zsh -l
   fi
   ```

## Dev containers

Nothing is installed into the container's `$HOME`. It mounts the host's files
instead, read-only. The config directories contain symlinks into `~/dotfiles`,
so mount the repo at the same path:

```yaml
# docker-compose.override.yml
volumes:
  - ${HOME}/dotfiles:/root/dotfiles:ro
  - ${HOME}/.zshenv:/root/.zshenv:ro
  - ${HOME}/.zshrc:/root/.zshrc:ro
  - ${HOME}/.p10k.zsh:/root/.p10k.zsh:ro
  - ${HOME}/.oh-my-zsh:/root/.oh-my-zsh:ro
  - ${HOME}/.config/zsh:/root/.config/zsh:ro
  - ${HOME}/.config/nvim:/root/.config/nvim:ro
  - ${HOME}/.config/lazygit:/root/.config/lazygit:ro
  - ${HOME}/.gitconfig:/root/.gitconfig:ro
  - ${HOME}/.gitconfig.local:/root/.gitconfig.local:ro
  - devcontainer-tools:/var/cache/devcontainer-tools   # named volume: tool cache
environment:
  - DEVCONTAINER=1
  - SHELL=/bin/zsh
  - TERM=xterm-256color
  - LANG=C.UTF-8
  - LC_ALL=C.UTF-8
```

On the first shell, `05-devcontainer.zsh` runs
[`scripts/devcontainer-tools.sh`](scripts/devcontainer-tools.sh). It installs
bat, eza, fd, rg, fzf, zoxide, atuin, lazygit, nvim, delta, kubecolor and tldr
from upstream release binaries. `ls` stays native in containers; `eza` is still
there if you call it directly. `bin/dexec` opens a shell in, or runs a command in,
the running dev container.

## Tests

```bash
tests/run             # shellcheck, zsh syntax, unit tests, sync + startup integration tests
tests/run --offline   # skip the startup test (it clones the shell framework)
```

CI runs the same on every push, on Linux and on macOS with Apple's bash 3.2.
`#!/usr/bin/env bash` finds that bash on the Macs, so scripts must stay
compatible with it.

## Guides

| Guide | Topic |
|---|---|
| [docs/neovim-guide.md](docs/neovim-guide.md) | Neovim config, plugins, keybindings, modal editing |
| [docs/lazygit-guide.md](docs/lazygit-guide.md) | lazygit: staging, commits, rebase, cherry-pick |
| [docs/tmux-guide.md](docs/tmux-guide.md) | tmux sessions, windows, panes, copy mode |
| [docs/shell-tools-guide.md](docs/shell-tools-guide.md) | fzf, atuin, zoxide, bat, eza, fd, ripgrep, delta |

## Handy checks

```bash
brew bundle check --no-upgrade --file=~/dotfiles/Brewfile --verbose   # missing packages
brew bundle cleanup --file=~/dotfiles/Brewfile                        # installed but not listed (dry run)
stow -n -v --no-folding -d ~/dotfiles -t ~ zsh                        # preview what stow would link
git -C ~/dotfiles rev-parse HEAD; ssh solaris 'git -C ~/dotfiles rev-parse HEAD'   # same commit?
```

Keep Brewfiles curated by hand. `brew bundle dump` captures every dependency
and machine-specific noise.

For hands-off syncing, a launchd agent can run `$HOME/dotfiles/bin/sync-all`
on a `StartInterval` (launchd needs the absolute path). It is off by default;
turn it on once you trust the flow.
