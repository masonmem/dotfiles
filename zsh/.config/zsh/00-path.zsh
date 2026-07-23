# Add dotfiles bin to PATH (for dexec and custom scripts)
export PATH="$HOME/dotfiles/bin:$PATH"

# Add ~/bin (where stow links per-package scripts like ollama/bin/litellm-keys)
[[ -d "$HOME/bin" ]] && export PATH="$HOME/bin:$PATH"

# Add the personal AI configuration commands.
# Hosts without ai-sync (hyperion / minimal Linux) skip the entry.
[[ -d "$HOME/code/ai-sync/bin" ]] && export PATH="$HOME/code/ai-sync/bin:$PATH"

# GitHub Copilot CLI (downloaded by `gh copilot`)
export PATH="$HOME/.local/share/gh/copilot:$PATH"

# PATH is managed in profile files — no duplication here.
#   ~/.zprofile  : brew shellenv (/opt/homebrew/bin), pipx (~/.local/bin)
#   ~/.zshenv    : cargo (~/.cargo/env → ~/.cargo/bin),
#                  Entware /opt/{bin,sbin,usr/bin,usr/sbin} on QNAP,
#                  Container Station docker on QNAP
#                  (in .zshenv so non-interactive ssh sessions get them too)
# Deduplicate PATH entries
typeset -U path PATH
