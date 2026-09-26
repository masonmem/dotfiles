#!/usr/bin/env bash
# install.sh — first-time setup of this repo on a machine. Safe to re-run.
#
#   ~/dotfiles/install.sh personal   # personal Macs (navi, solaris)
#   ~/dotfiles/install.sh work       # work machine: shared config only
#   ~/dotfiles/install.sh minimal    # servers / QNAP: shell + git only
#
# 1. Writes the package list (~/.config/dotfiles/packages) for the profile,
#    unless one already exists. That file is the per-host switch that decides
#    what gets linked AND which package Brewfiles / pipx lists get installed.
# 2. Copies the untracked per-machine templates (git identity, ssh config)
#    into place if they don't exist yet.
# 3. Runs dotfiles-sync, moving aside any existing files that would block a
#    link (as <file>.pre-dotfiles).
#
# After this, `sync-all` is the only command you need on this machine.
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
MANIFEST="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/packages"

log()  { printf '\033[36m[install]\033[0m %s\n' "$*"; }
warn() { printf '\033[33m[install] WARN:\033[0m %s\n' "$*" >&2; }

# --8<-- [start:profiles]
case "${1:-}" in
  personal) packages="zsh p10k tmux git nvim lazygit atuin personal ollama" ;;
  work)     packages="zsh p10k tmux git nvim lazygit atuin" ;;
  minimal)  packages="zsh p10k git" ;;
  *) sed -n '2,/^set -e/{/^set -e/d;s/^# \{0,1\}//;p;}' "$0" >&2; exit 2 ;;
esac
# --8<-- [end:profiles]

if [[ "$DOTFILES" != "$HOME/dotfiles" ]]; then
  warn "this repo is at $DOTFILES; the shell config expects ~/dotfiles"
fi
command -v git >/dev/null 2>&1 || { warn "git is required"; exit 1; }
if [[ "$(uname -s)" == Darwin ]] && ! command -v brew >/dev/null 2>&1 && [[ ! -x /opt/homebrew/bin/brew ]]; then
  warn "Homebrew is not installed — packages will be skipped. Install it from https://brew.sh and re-run."
fi

# 1. package list
if [[ -e "$MANIFEST" ]]; then
  log "keeping existing $MANIFEST: $(grep -v '^[[:space:]]*#' "$MANIFEST" | tr '\n' ' ')"
else
  mkdir -p "$(dirname "$MANIFEST")"
  {
    echo "# Stow packages for this host ($1 profile). Untracked; see README § Packages and profiles."
    tr ' ' '\n' <<<"$packages"
  } > "$MANIFEST"
  log "wrote $MANIFEST: $packages"
fi

# 2. per-machine files (never tracked)
copy_template() {   # <template> <destination> <mode>
  if [[ -e "$2" ]]; then
    log "keeping existing ${2/#$HOME/~}"
  else
    mkdir -p "$(dirname "$2")"
    cp "$DOTFILES/templates/$1" "$2" && chmod "$3" "$2"
    log "created ${2/#$HOME/~} from templates/$1 — edit it for this machine"
  fi
}
mkdir -p "$HOME/.ssh/sockets"
chmod 700 "$HOME/.ssh" "$HOME/.ssh/sockets"
copy_template gitconfig.local "$HOME/.gitconfig.local" 644
copy_template ssh_config      "$HOME/.ssh/config"      600
mkdir -p "$HOME/.nvm"   # NVM_DIR (10-env.zsh); Homebrew's nvm does not create it

# 3. converge
export DOTFILES
"$DOTFILES/bin/dotfiles-sync" --backup-conflicts

cat <<EOF

Done. Next:
  • Set your git identity in ~/.gitconfig.local, and hosts in ~/.ssh/config.
  • Personal / work AI config: clone masonmem/ai-sync to ~/code/ai-sync and run
    its install.sh (add --work on the work machine).
  • Open a new terminal. From now on, run \`sync-all\` to pick up changes.
EOF
