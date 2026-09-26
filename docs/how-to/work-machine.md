# Keep work and personal apart

The work Mac runs the **same shared layer** as the personal Macs and nothing
else from the repo. Work-specific details live only on the work Mac, in
untracked files.

## What the work Mac gets, and doesn't

| | Work Mac |
|---|---|
| Shared config: zsh, prompt, git, tmux, Neovim, lazygit, atuin | ✅ |
| Shared tools (`Brewfile`): git, fzf, eza, kubectl tools, Claude Code, Copilot CLI, Docker Desktop, … | ✅ |
| `personal` package: Copilot telemetry, VPN/media aliases, homelab and media tools, MCP servers | ❌ never linked or installed |
| `ollama` package: local-LLM agents, LiteLLM keys | ❌ never linked or installed |
| Personal GitHub token (`GH_TOKEN`) | ❌ the ai-sync secret isn't there, so nothing is exported |
| Work git identity, work hosts, work aliases | only in untracked files on the work Mac |

This holds because the work Mac's `~/.config/dotfiles/packages` doesn't list
`personal` or `ollama`, and `dotfiles-sync` never guesses a package list.

## Git identity

`~/.gitconfig` (shared) includes `~/.gitconfig.local` **last**, so anything in
the local file wins.

=== "Work Mac: work identity everywhere"

    ```ini title="~/.gitconfig.local"
    [user]
        name = Your Name
        email = you@company.example
    ```

=== "Personal by default, work in ~/work"

    ```ini title="~/.gitconfig.local"
    [user]
        name = Your Name
        email = you@personal.example

    [includeIf "gitdir:~/work/"]
        path = ~/.gitconfig.work
    ```

    ```ini title="~/.gitconfig.work (untracked)"
    [user]
        email = you@company.example
    [commit]
        gpgsign = true
    ```

    `includeIf "gitdir:~/work/"` applies to every repo under `~/work/`.

Check which identity a repo uses:

```bash
git config --show-origin user.email
```

!!! danger "Not `git config --global`"
    `~/.gitconfig` is the tracked, shared file. `git config --global
    user.email …` writes your work email into the repo, and from there onto
    every machine and the public GitHub repo. Use
    `git config --file ~/.gitconfig.local …` instead.

## Other work-only settings

| What | Where (on the work Mac) |
|---|---|
| kube contexts, work aliases, `DEXEC_FALLBACKS` | `~/.config/zsh/90-<host>.zsh` |
| work SSH hosts, bastions | `~/.ssh/config` |
| proxy / corporate CA env vars | `~/.config/zsh/90-<host>.zsh` |
| AI agent config | `~/code/ai-sync/install.sh --work` (ai-sync's work-safe layer) |

## Adding something new: the work test

Before putting anything in a **shared** place (root `Brewfile`, `zsh`, `git`),
ask: *is this fine on the work machine and in a public repo?* If not, it goes
in `personal/` (or `ollama/`), or in an untracked file. See
[the layers](../concepts/layers.md).
