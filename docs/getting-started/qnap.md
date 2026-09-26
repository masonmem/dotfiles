# QNAP / Linux server

For **hyperion** (QNAP TS-464 with Entware) and any Linux box you SSH into. The
`minimal` profile gives you the same shell, prompt and git setup as the Macs.

## Install

=== "QNAP (Entware)"

    ```sh
    /opt/bin/opkg install zsh git bash eza fd fzf jq neovim ripgrep tmux htop nano
    git clone https://github.com/masonmem/dotfiles.git ~/dotfiles
    ~/dotfiles/install.sh minimal
    ```

=== "Debian / Ubuntu"

    ```sh
    sudo apt install zsh git stow fzf ripgrep fd-find bat tmux neovim
    git clone https://github.com/masonmem/dotfiles.git ~/dotfiles
    ~/dotfiles/install.sh minimal
    ```

    Debian names two of these differently (`batcat`, `fdfind`). Link them
    under the usual names so the aliases and fzf find them:
    `mkdir -p ~/bin && ln -s "$(command -v batcat)" ~/bin/bat && ln -s "$(command -v fdfind)" ~/bin/fd`

There is no Homebrew here, so the Brewfile steps are skipped. Entware has no
`stow`, so `dotfiles-sync` uses its built-in linker, which produces exactly the
same symlinks. Add `tmux`, `nvim` etc. to `~/.config/dotfiles/packages` if you
want those configs too.

Every tool integration checks the tool is there first, so anything you didn't
install is skipped quietly. For example, `ls` stays `ls` if `eza` is missing.

## QNAP quirks

### 1. `setopt monitor` fails

Entware's zsh can't enable job control, and powerlevel10k's gitstatus gives up
when `setopt monitor` fails. [`bin/qnap-gitstatus-fix`](../reference/commands.md#qnap-gitstatus-fix)
patches that one line. You never run it by hand: `bootstrap-shell` sets the
patch aside and re-applies it whenever the p10k pin moves.

### 2. `mkfifo` is missing

gitstatusd needs `mkfifo`, which QNAP's busybox lacks. Entware's package can't
install it without root, so put the binary in `~/bin` (already on PATH):

```sh
# on any machine with curl + tar:
curl -sLO http://bin.entware.net/x64-k3.2/coreutils-mkfifo_9.9-2_x64-3.2.ipk
mkdir extract && tar xzf coreutils-mkfifo_9.9-2_x64-3.2.ipk -C extract
tar xzf extract/data.tar.gz -C extract
scp extract/opt/libexec/mkfifo-coreutils hyperion:bin/mkfifo
ssh hyperion 'chmod +x ~/bin/mkfifo'
```

### 3. Login shells must be handed to zsh

QNAP controls the `sh` login flow, so `~/.profile` stays untracked and
machine-local. Recreate it after a rebuild:

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

The Entware and Container Station directories are also on PATH in
`~/.zshenv`, so `ssh hyperion docker ps` works too.

## Host-only aliases

Put them in `~/.config/zsh/90-hyperion.zsh` (untracked). The template has a
hyperion example:

```sh
cp ~/dotfiles/templates/zsh-host.zsh ~/.config/zsh/90-hyperion.zsh
```
