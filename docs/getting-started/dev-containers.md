# Dev containers

Containers don't get anything installed into their home directory. They
**mount the host's files read-only**, and on the first shell they install the
CLI tools from upstream release binaries.

## 1. Mount the host's config

Add this to the project's `docker-compose.override.yml`:

```yaml
services:
  dev:                                  # your service name
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
      - devcontainer-tools:/var/cache/devcontainer-tools
    environment:
      - DEVCONTAINER=1
      - SHELL=/bin/zsh
      - TERM=xterm-256color
      - LANG=C.UTF-8
      - LC_ALL=C.UTF-8

volumes:
  devcontainer-tools:                   # keeps downloaded tools between rebuilds
```

!!! warning "Mount `~/dotfiles` at the same path"
    Directories like `~/.config/zsh` hold *relative symlinks* into
    `~/dotfiles`. Without the first mount they dangle inside the container and
    the shell config silently doesn't load.

## 2. Open a shell

On the first shell, `05-devcontainer.zsh`:

1. runs [`scripts/devcontainer-tools.sh`](../reference/commands.md#scriptsdevcontainer-toolssh),
   which installs bat, eza, fd, rg, fzf, zoxide, atuin, lazygit, nvim, delta,
   kubecolor and tldr (x86_64 or arm64) into `/usr/local`;
2. if `~/code/ai-sync` exists in the container, applies its work-safe layer
   (`install.sh --work --container`);
3. runs `configure-vscode-ai --container` for VS Code's server settings.

A marker file stops step 1 and step 2 from running again.

From the host, `dexec` opens a shell in the running dev container, or runs a
command there:

```bash
dexec                 # interactive shell (zsh, else bash, else sh)
dexec make test       # run a command
dexec -l              # list dev containers
```

## Differences inside containers

- `ls` stays the **native** `ls`. `ll` and `la` use it too. A host-built or
  cached `eza` has segfaulted in containers before; call `eza` directly if you
  want it.
- The macOS oh-my-zsh plugin isn't loaded (it's Linux).
- Nothing is synced; the container sees whatever the host has.
