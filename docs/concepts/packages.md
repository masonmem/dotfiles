# Packages and profiles

## What a package is

A **package** is any top-level folder of the repo, apart from these, which are
never linked:

`bin/` · `docs/` · `scripts/` · `templates/` · `tests/` · `Brewfile.d/` · `site/` ·
anything starting with `.` (such as `.github/`)

Inside a package, files are laid out as they should appear in `$HOME`. A
package can also carry three things that are **not** linked:

| File in the package | Used by | Purpose |
|---|---|---|
| `Brewfile` | `dotfiles-sync` | Homebrew formulae/casks this package needs, installed only on machines that enable it |
| `pipx-tools.txt` | `dotfiles-sync` | Python CLIs this package needs ([format](../reference/brewfiles.md#pipx-lists)) |
| `.stow-local-ignore` | stow and `dotfiles-sync` | lists the paths in the package not to link |

## The packages

| Package | What it links | Brings |
|---|---|---|
| `zsh` | `.zshenv` `.zprofile` `.zshrc`, `.config/zsh/*.zsh` | — |
| `p10k` | `.p10k.zsh` (prompt) | — |
| `git` | `.gitconfig`, `.config/git/ignore` | — |
| `tmux` | `.tmux.conf` | — |
| `nvim` | `.config/nvim/init.lua` | — |
| `lazygit` | `.config/lazygit/config.yml` | — |
| `atuin` | `.config/atuin/` (config + theme) | — |
| `personal` | `.config/zsh/50-personal.zsh` | `Brewfile` (homelab, media), `pipx-tools.txt` (MCP servers, NAT-PMP) |
| `ollama` | aider / opencode / goose configs, `16-llm-gateway.zsh`, wrappers, `~/bin/litellm-keys` | `Brewfile` (aider, opencode, goose) |

The shared tools (git, fzf, eza, nvim, …) are in the root `Brewfile`, installed
on every Mac whatever its packages. See [the layers](layers.md).

## Profiles

A profile is a starting package list that `install.sh` writes to
`~/.config/dotfiles/packages`:

```bash title="install.sh"
--8<-- "install.sh:profiles"
```

After that the file is yours; edit it any time and run `sync-all`:

```text title="~/.config/dotfiles/packages"
# Stow packages for this host (personal profile). Untracked; …
zsh
p10k
tmux
git
nvim
lazygit
atuin
personal
ollama
```

!!! info "No list, no sync"
    Without this file, `dotfiles-sync` stops with an error instead of guessing.
    A guessed default is how a work machine would end up with personal
    packages.

Each sync prints `packages: …`, plus `not enabled on this host: …` for any
package that exists but isn't listed, so a new package never goes unnoticed.

## Ignore rules

`.stow-local-ignore` uses stow's syntax. One Perl-style regex per line:

- a pattern **without** `/` matches a file or folder **name** anywhere
  (`\.DS_Store`);
- a pattern **with** `/` matches the path from the package root (`^/Brewfile`,
  `^/launchagents`).

A package **without** the file gets stow's defaults (README\*, LICENSE\*, `.git`,
editor backups, …). A package **with** one gets only what it lists, so list
everything:

```text title="ollama/.stow-local-ignore"
--8<-- "ollama/.stow-local-ignore"
```

`dotfiles-sync` applies exactly the same rules in its built-in linker, and the
tests check that both produce identical links.
