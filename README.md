# dotfiles

One repo for every machine I use: personal Macs, the work Mac, a QNAP NAS, and
Linux dev containers. Configs are symlinked into `$HOME` with GNU Stow; one
command keeps every machine in sync.

📖 **Documentation: <https://masonmem.github.io/dotfiles/>** (source in
[`docs/`](docs/index.md))

## Quick start

```bash
# 1. Homebrew (macOS) — https://brew.sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. This repo, at ~/dotfiles
git clone https://github.com/masonmem/dotfiles.git ~/dotfiles

# 3. Everything else
~/dotfiles/install.sh personal   # or: work · minimal (servers / QNAP)
```

After that, on any machine:

```bash
sync-all      # pull, install missing tools, relink — the same command everywhere
```

## In one paragraph

Each top-level folder is a **package** laid out like `$HOME`. Each machine
lists the packages it uses in `~/.config/dotfiles/packages`; `install.sh`
writes it from a profile. The `personal` and `ollama` packages hold everything
that must never reach the work machine, including their own Brewfiles.
Machine-specific things (git identity, SSH hosts, per-host aliases) live in
untracked files started from `templates/`. `dotfiles-sync` pulls, installs
what's missing, links, and removes links to deleted files. It never overwrites
your files, upgrades or uninstalls anything.

## Where to look

| | |
|---|---|
| Set up a machine | [Getting started](docs/getting-started/index.md) |
| Make and ship a change | [Everyday workflow](docs/how-to/daily-workflow.md) |
| Where does X go? | [Shared, personal, host, machine](docs/concepts/layers.md) |
| Add a tool, config file, alias, package | [How-to guides](docs/how-to/index.md) |
| Commands, aliases, key bindings | [Reference](docs/reference/index.md) |
| Something broke | [Troubleshooting](docs/troubleshooting.md) |

Run `tests/run` before pushing; CI runs it too, on Linux and on macOS with
Apple's bash 3.2.

## Machines

| Host | Profile |
|---|---|
| navi (laptop) | personal |
| solaris (Mac mini, always on) | personal |
| work MacBook | work |
| hyperion (QNAP) | minimal |
| dev containers | mount the host's files |
