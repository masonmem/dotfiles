# ~/.zshenv — read by EVERY zsh (interactive, login, `ssh host cmd`, scripts,
# launchd jobs, agent subprocesses). Keep it to environment only: no output,
# no aliases, nothing slow.
#
# This is the single place PATH is defined. .zprofile re-sources this file for
# login shells because macOS /etc/zprofile (path_helper) runs after .zshenv
# and pushes the system directories back in front of ours.

typeset -U path PATH        # dedupe; re-prepending an entry moves it to the front
path=(
  $HOME/bin                                  # this machine's scripts; ollama's litellm-keys
  $HOME/dotfiles/bin                         # dexec, configure-vscode-ai
  ${AI_CONFIG:-$HOME/code/ai-sync}/bin       # ai-sync commands (secrets-push, MCP wrappers, …)
  $HOME/.cargo/bin                           # rustup, when installed
  /opt/homebrew/bin /opt/homebrew/sbin       # Homebrew (Apple Silicon)
  /opt/bin /opt/sbin /opt/usr/bin /opt/usr/sbin    # Entware (QNAP)
  /share/CACHEDEV3_DATA/.qpkg/container-station/bin  # QNAP Container Station docker
  $path
  $HOME/.local/bin                           # pipx / uv tools (after system dirs, as before)
)
path=($^path(N-/))          # drop directories that don't exist on this host

# XDG base dirs (the defaults, made explicit). On macOS some tools — lazygit
# among them — only read ~/.config when XDG_CONFIG_HOME is set.
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

# zoxide warns when it isn't the last chpwd hook; plugin order makes that
# brittle and the warning is benign.
export _ZO_DOCTOR=0
