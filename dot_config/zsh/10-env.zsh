# Environment variables
# Use nvim if installed, fall back to vim
export EDITOR="${commands[nvim]:+nvim}${commands[nvim]:-vim}"
export VISUAL="$EDITOR"

# XDG base directories
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

# bat theme (used by bat alias and fzf preview)
export BAT_THEME="Dracula"

# NVM directory (actual load is lazy in 70-nvm.zsh)
export NVM_DIR="$HOME/.nvm"

# Less / pager
export LESS="-R --use-color"
