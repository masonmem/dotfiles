# Commands

Everything in `bin/` is on PATH on every machine.

## `install.sh`

First-time setup. Safe to re-run.

```text
~/dotfiles/install.sh personal|work|minimal
```

1. Writes `~/.config/dotfiles/packages` for the profile, **unless it exists**.
2. Copies `templates/gitconfig.local` → `~/.gitconfig.local` (mode 644) and
   `templates/ssh_config` → `~/.ssh/config` (mode 600), **unless they exist**.
   Creates `~/.ssh/sockets` and `~/.nvm`.
3. Runs `dotfiles-sync --backup-conflicts`.

Warns (but continues) if the repo isn't at `~/dotfiles` or Homebrew is missing
on macOS. Profiles: see [Packages and profiles](../concepts/packages.md#profiles).

## `sync-all`

```text
sync-all [all|dotfiles|ai-sync]
```

| Argument | Runs |
|---|---|
| `all` (default) | `dotfiles-sync`, then `~/code/ai-sync/bin/ai-config-sync` |
| `dotfiles` | `dotfiles-sync` only |
| `ai-sync` (or `ai-config`) | ai-sync's sync only; skipped with a note if ai-sync isn't cloned |

## `dotfiles-sync`

```text
dotfiles-sync [--backup-conflicts]
```

Pull → Homebrew → pipx → shell framework → link → prune. Every step is
described in [What sync does](../concepts/sync.md).

| Option | Effect |
|---|---|
| `--backup-conflicts` | before linking, rename any real file in a link's place to `<file>.pre-dotfiles` (`install.sh` uses this) |
| `-h`, `--help` | usage |

Exit status is non-zero if the package list is missing or empty, or if a
package couldn't be linked (a conflict). Pull, brew, pipx and shell-framework
problems are warnings; the sync continues past them.

## `bootstrap-shell`

```text
bootstrap-shell
```

Clones or updates `~/.oh-my-zsh` and its theme/plugins to the commits in
`shell-clones.txt`. Run by `dotfiles-sync`; also safe to run alone. Details:
[Shell framework pins](../concepts/shell-framework.md).

## `qnap-gitstatus-fix`

```text
qnap-gitstatus-fix
```

QNAP only. Patches p10k's `gitstatus.plugin.zsh` so it tolerates Entware zsh's
missing job control, and checks that `~/bin/mkfifo` exists. Idempotent;
`bootstrap-shell` runs it when needed.

## `dexec`

Run a shell or command inside a running dev container.

```text
dexec                        interactive login shell (zsh, else bash, else sh)
dexec <command> [args…]      run a command
dexec -c <container> …       use this container
dexec -l                     list running dev containers
```

Container choice: `$DEXEC_CONTAINER`, else the first container with a
`devcontainer.local_folder` label, else the first running container whose name
contains one of `$DEXEC_FALLBACKS`.

| Variable | Default | Meaning |
|---|---|---|
| `DEXEC_CONTAINER` | — | container name or ID to use |
| `DEXEC_FALLBACKS` | `devenv dev-container` | name patterns to try (substring match) |
| `DEXEC_WORKDIR` | — | working directory inside the container |
| `DEXEC_USER` | the image's user | user inside the container |
| `DEXEC_SHELL` | `zsh` | preferred interactive shell |

A TTY is allocated only when there is one, so `dexec cmd | less` works.

## `configure-vscode-ai`

```text
configure-vscode-ai [--container]
```

Merges these into VS Code's user settings (JSONC is accepted):

- `chat.useAgentSkills: true`
- exclude `**/.worktrees` from the file explorer, file watcher and search

`--container` targets the VS Code server's machine settings
(`~/.vscode-server/data/Machine/settings.json`). Containers run it on every
shell. The file is rewritten only if something changes. If the original had
comments or trailing commas, which the rewrite can't keep, it's first copied to
`settings.json.bak`. It refuses to touch invalid JSON.

## `scripts/devcontainer-tools.sh`

Installs bat, eza, fd, rg, fzf, zoxide, atuin, lazygit, nvim, delta, kubecolor
and tldr (tealdeer) into `/usr/local` from upstream release binaries (x86_64
and arm64). Tools already on PATH are skipped. `TOOL_CACHE` (default
`/var/cache/devcontainer-tools`) caches downloads. The exit status is non-zero
if any tool failed; the others are still installed.

## `dotfiles-docs`

```text
dotfiles-docs                serve this site with live reload at http://127.0.0.1:8000
dotfiles-docs build <dir>    write the static site to <dir>
```

Uses `uvx` with the versions pinned in `docs/requirements.txt`, or an installed
`mkdocs` if there's no `uv`. Nothing is hosted.

## `tests/run`

```text
tests/run [--offline]
```

Runs every check: shellcheck, `zsh -n`, the unit tests, the sync integration
test, and the shell-startup test. `--offline` skips the startup test, which
clones the shell framework from GitHub. Checks whose tools are missing are
skipped with a note. The pre-push hook runs `tests/run --offline` before every
push. See [Contributing](../contributing.md).

## From the `ollama` package

| Command | Purpose |
|---|---|
| `litellm-keys list \| pull \| push \| mint <tool> \| revoke <tool>` | manage per-tool LiteLLM keys. [Details](llm-stack.md#litellm-keys) |
| `~/dotfiles/ollama/bin/install-ollama.sh [VERSION]` | solaris: install or upgrade the Ollama server. [Details](llm-stack.md#the-ollama-server-solaris) |
