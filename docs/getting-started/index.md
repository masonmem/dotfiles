# Getting started

Pick the page for the machine in front of you.

| Machine | Profile | Page |
|---|---|---|
| A personal Mac (navi, solaris, a new one) | `personal` | [New Mac](new-mac.md) |
| The work Mac | `work` | [New Mac](new-mac.md) (use the *work* tab) |
| hyperion, or any Linux box you SSH into | `minimal` | [QNAP / Linux server](qnap.md) |
| A Docker dev container | none | [Dev containers](dev-containers.md) |
| A machine set up before September 2026 | keeps its profile | [Updating an existing machine](existing-machines.md) |

## The three profiles

A **profile** is just a starting list of [packages](../concepts/packages.md)
that `install.sh` writes for the machine. You can edit the list afterwards.

| Profile | Packages | For |
|---|---|---|
| `personal` | zsh p10k tmux git nvim lazygit atuin **personal ollama** | personal Macs |
| `work` | zsh p10k tmux git nvim lazygit atuin | the work Mac: shared config only |
| `minimal` | zsh p10k git | servers, the NAS |

The only difference between `personal` and `work` is the two personal
packages. Everything shared is identical.

## What you need

- **macOS:** [Homebrew](https://brew.sh). Its installer also installs Apple's
  command-line tools (git, a C compiler).
- **Linux / QNAP:** `git`, `bash` and `zsh` from the system package manager.
  `stow` is optional; there is a built-in replacement.
- The repo cloned at **`~/dotfiles`**. The shell config expects that exact path.
