# Add dotfiles bin to PATH (for dexec and custom scripts)
export PATH="$HOME/dotfiles/bin:$PATH"

# Add ~/bin (where stow links per-package scripts like ollama/bin/litellm-keys)
[[ -d "$HOME/bin" ]] && export PATH="$HOME/bin:$PATH"

# GitHub Copilot CLI (downloaded by `gh copilot`)
export PATH="$HOME/.local/share/gh/copilot:$PATH"

# Entware (QNAP / OpenWrt-style hosts) — add the four locations that
# Entware packages land in. Mac hosts won't have these dirs, so the
# guards make this a no-op there.
for _d in /opt/bin /opt/sbin /opt/usr/bin /opt/usr/sbin; do
  [[ -d "$_d" ]] && export PATH="$_d:$PATH"
done
unset _d

# QNAP container-station docker
[[ -d /share/CACHEDEV3_DATA/.qpkg/container-station/bin ]] \
  && export PATH="/share/CACHEDEV3_DATA/.qpkg/container-station/bin:$PATH"

# PATH is managed in profile files — no duplication here.
#   ~/.zprofile  : brew shellenv (/opt/homebrew/bin), pipx (~/.local/bin)
#   ~/.zshenv    : cargo (~/.cargo/env → ~/.cargo/bin)
# Deduplicate PATH entries
typeset -U path PATH
