# dotfiles

Config for my Macs (navi, solaris, the work MacBook), the QNAP (hyperion) and
dev containers, managed with [GNU Stow](https://www.gnu.org/software/stow/).

Each top-level folder is a **package** laid out like `$HOME`. `stow zsh`, run
from `~/dotfiles`, symlinks `zsh/.zshrc` to `~/.zshrc`, and so on. Edit a file
on any machine and you're editing the repo; commit and push it, then
`git pull` on the other machines.

| Package | What | Where |
|---|---|---|
| `zsh` `git` `tmux` `nvim` `lazygit` `atuin` `p10k` | shell, prompt, git and editor config | every machine |
| `personal` | personal aliases and env, the `GH_TOKEN` from ai-sync | personal Macs only |
| `ollama` | local-LLM agents (aider, opencode, goose) and LiteLLM keys; see [ollama/README.md](ollama/README.md) | personal Macs only |

Also here:

- `Brewfile`: every Mac. `Brewfile.d/personal.Brewfile`: personal Macs only.
  `Brewfile.d/<host>.Brewfile`: a single machine.
- `bin/`: `dexec` (a shell in a running dev container) and
  `configure-vscode-ai` (VS Code AI settings). On PATH everywhere.
- `scripts/devcontainer-tools.sh`: optional CLI tools for dev containers.
- `docs/`: guides to the tools: [Neovim](docs/neovim.md),
  [lazygit](docs/lazygit.md), [tmux](docs/tmux.md),
  [shell tools](docs/shell-tools.md).
- `.stowrc`: makes `stow` link files one at a time, so files other tools create
  in `~/.config/<tool>/` never land in this repo.

Work stays separate by what you *don't* stow and install: the work Mac never
gets `personal`, `ollama` or the personal Brewfile. Anything specific to one
machine lives in untracked files on that machine (below).

## Set up a Mac

```bash
# Homebrew (https://brew.sh), then this repo
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
git clone https://github.com/masonmem/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Tools
brew bundle --file Brewfile
brew bundle --file Brewfile.d/personal.Brewfile      # personal Macs only
brew bundle --file Brewfile.d/solaris.Brewfile       # if this machine has one

# Link the config (move aside any existing ~/.zshrc etc. first)
stow zsh git tmux nvim lazygit atuin p10k
stow personal ollama                                 # personal Macs only

# oh-my-zsh, then the theme and plugins, each installed the way its README says
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
ZSH_CUSTOM=~/.oh-my-zsh/custom
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git  $ZSH_CUSTOM/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-autosuggestions        $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting    $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions            $ZSH_CUSTOM/plugins/zsh-completions
```

Then create the machine-only files (next section), set your terminal's font to
*MesloLGS Nerd Font*, and open a new terminal.

On personal Macs, also:

```bash
git clone git@github.com:masonmem/ai-sync.git ~/code/ai-sync && ~/code/ai-sync/install.sh
pipx install unifi-mcp-server
pipx install py-natpmp
pipx install git+https://github.com/rgarcia/ynab-mcp-server@cd78abc89e941d7e2d5b28029886dfe3e3c215e2
```

On the work Mac, ai-sync's work-safe layer is `~/code/ai-sync/install.sh --work`.

## Machine-only files (untracked)

| File | For |
|---|---|
| `~/.gitconfig.local` | git identity and anything work-specific. Loaded last, so it wins. |
| `~/.config/zsh/local.zsh` | this machine's aliases, env, `PATH` additions |
| `~/.ssh/config` | SSH hosts |

```ini
# ~/.gitconfig.local — work Mac
[user]
    name = Your Name
    email = you@company.example
```

```ini
# ~/.gitconfig.local — personal Mac, with work repos under ~/work
[user]
    name = Your Name
    email = you@personal.example
[includeIf "gitdir:~/work/"]
    path = ~/.gitconfig.work
```

Don't run `git config --global` or `p10k configure`: `~/.gitconfig` and
`~/.p10k.zsh` are links into this repo, so both write here, and from here to
every machine. Use `git config --file ~/.gitconfig.local …`.

## Keep a machine up to date

```bash
cd ~/dotfiles && git pull
stow -R zsh git tmux nvim lazygit atuin p10k   # only if files were added or removed (-R also drops links to deleted files)
brew bundle --file Brewfile                    # only if a Brewfile changed
zsh-update                                     # theme and plugins; oh-my-zsh also updates itself every two weeks
```

## Make a change

- **Change a config:** edit it (in `~/dotfiles` or through the link), commit,
  push. Other machines get it with `git pull`.
- **Add a config file:** put it in the package at the same path it has under
  `~`, then `stow -R <package>` on each machine.
- **Add a tool:** add it to the right Brewfile. If the shell config uses it,
  check it's there first (`(( $+commands[tool] )) && …`), as `.zshrc` does.
  The same `.zshrc` runs on hyperion and in containers, where most tools are
  missing.
- **Add a package:** make a folder laid out like `~`, then `stow <name>`.
  To keep a file in it from being linked, list it in a `.stow-local-ignore`
  in the package (see `ollama/`).
- **Is it OK on the work Mac, and in a public repo?** If not, it goes in
  `personal`, `ollama` or a machine-only file.

## hyperion (QNAP)

There's no stow on Entware, so link the files by hand:

```bash
git clone https://github.com/masonmem/dotfiles.git ~/dotfiles
ln -sf ~/dotfiles/zsh/.zshrc ~/dotfiles/zsh/.zshenv ~/dotfiles/zsh/.zprofile ~/dotfiles/p10k/.p10k.zsh ~/dotfiles/git/.gitconfig ~
mkdir -p ~/.config/git ~/.config/zsh && ln -sf ~/dotfiles/git/.config/git/ignore ~/.config/git/
```

Install oh-my-zsh and the plugins with the same commands as on a Mac.
Entware's zsh has no job control, which p10k's fast git status needs; `.zshrc`
notices and uses p10k's slower built-in git status instead, so the old
gitstatus patch and `~/bin/mkfifo` aren't needed. `~/.profile` (which hands
QNAP's login shell to zsh) stays machine-only.

## Dev containers

Containers mount the host's files read-only. Add to the project's
`docker-compose.override.yml`:

```yaml
services:
  dev:                                  # your service name
    volumes:
      - ${HOME}/dotfiles:/root/dotfiles:ro
      - ${HOME}/dotfiles/zsh/.zshenv:/root/.zshenv:ro
      - ${HOME}/dotfiles/zsh/.zshrc:/root/.zshrc:ro
      - ${HOME}/dotfiles/p10k/.p10k.zsh:/root/.p10k.zsh:ro
      - ${HOME}/.oh-my-zsh:/root/.oh-my-zsh:ro
      - ${HOME}/dotfiles/git/.gitconfig:/root/.gitconfig:ro
      - ${HOME}/.gitconfig.local:/root/.gitconfig.local:ro
      - ${HOME}/dotfiles/nvim/.config/nvim:/root/.config/nvim:ro
      - ${HOME}/dotfiles/lazygit/.config/lazygit:/root/.config/lazygit:ro
      - devcontainer-tools:/var/cache/devcontainer-tools
    environment:
      - DEVCONTAINER=1
volumes:
  devcontainer-tools:                   # keeps downloaded tools between rebuilds
```

The container needs `zsh` and `git`. Everything else is optional: aliases and
integrations whose tool is missing are skipped, and git falls back from delta
to `less`. To install the CLI tools (bat, eza, fd, rg, fzf, zoxide, atuin,
lazygit, nvim, delta, kubecolor, tldr) and the VS Code AI settings, run this
from the host once per container:

```bash
dexec sh -c '/root/dotfiles/scripts/devcontainer-tools.sh; /root/dotfiles/bin/configure-vscode-ai --container'
```

Inside containers `ls` stays the native `ls` (a cached eza once segfaulted
there); `ll` and `la` use it too.
