# Add dotfiles bin to PATH (for dexec and custom scripts)
export PATH="$HOME/dotfiles/bin:$PATH"

# Add ~/bin (where stow links per-package scripts like ollama/bin/litellm-keys)
[[ -d "$HOME/bin" ]] && export PATH="$HOME/bin:$PATH"

# GitHub Copilot CLI (downloaded by `gh copilot`)
export PATH="$HOME/.local/share/gh/copilot:$PATH"

# PATH is managed in profile files — no duplication here.
#   ~/.zprofile  : brew shellenv (/opt/homebrew/bin), pipx (~/.local/bin)
#   ~/.zshenv    : cargo (~/.cargo/env → ~/.cargo/bin)
# Deduplicate PATH entries
typeset -U path PATH
