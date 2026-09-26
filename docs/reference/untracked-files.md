# Untracked files and templates

These files are **per machine** and never committed. Some start from a template
in `templates/`, and the tracked config includes or sources them.

| File | Purpose | Created by | Loaded by |
|---|---|---|---|
| `~/.config/dotfiles/packages` | packages this machine uses | `install.sh` | `dotfiles-sync` |
| `~/.gitconfig.local` | git identity, work settings, host overrides | `install.sh` (template) | `~/.gitconfig`, included **last** |
| `~/.gitconfig.work` *(optional)* | work identity for `includeIf` | you | `~/.gitconfig.local` |
| `~/.ssh/config` | SSH hosts and defaults | `install.sh` (template) | ssh |
| `~/.config/zsh/90-<host>.zsh` | per-host aliases/env, loaded last | you (template) | `.zshrc` |
| `~/.zshrc.early.local` | settings needed before oh-my-zsh / p10k (`ZSH_THEME`, `POWERLEVEL9K_*`) | you | top of `.zshrc` |
| `~/code/ai-sync/secrets/` | tokens (GitHub PAT → `GH_TOKEN`, …) | ai-sync | `12-github-cli.zsh`, ai-sync |
| `~/.copilot/secrets/litellm-*.txt` | LiteLLM keys (personal) | `litellm-keys pull` | `16-llm-gateway.zsh`, opencode |
| `~/.config/nvim/lazy-lock.json` | Neovim plugin versions on this machine | lazy.nvim | lazy.nvim |
| `~/.profile` *(hyperion)* | hands QNAP login shells to zsh | you ([contents](../getting-started/qnap.md#3-login-shells-must-be-handed-to-zsh)) | QNAP's sh |
| `~/bin/mkfifo` *(hyperion)* | gitstatusd dependency | you ([steps](../getting-started/qnap.md#2-mkfifo-is-missing)) | gitstatusd |
| `<file>.pre-dotfiles` | your originals, set aside by `install.sh` | `install.sh` | nobody; delete when happy |

## `templates/gitconfig.local`

```ini title="templates/gitconfig.local"
--8<-- "templates/gitconfig.local"
```

The `[user]` block is commented out on purpose: git refuses to commit until you
set it, instead of committing under a placeholder name.

## `templates/ssh_config`

```text title="templates/ssh_config"
--8<-- "templates/ssh_config"
```

## `templates/zsh-host.zsh`

```zsh title="templates/zsh-host.zsh"
--8<-- "templates/zsh-host.zsh"
```

!!! note "Templates are copied once"
    `install.sh` never overwrites these files. If a template gains something
    useful, copy it into your local file by hand.
