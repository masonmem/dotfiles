# Tool integrations
# Init scripts are cached to files — avoids subprocess spawning on every shell start.
# Cache auto-regenerates if the binary is newer than the cache.

_zsh_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
mkdir -p "$_zsh_cache"

# fzf — Ctrl-T (file picker) and Alt-C (dir picker); Ctrl-R set here but overridden by atuin
if command -v fzf >/dev/null 2>&1; then
  _fzf_cache="$_zsh_cache/fzf-init.zsh"
  [[ -f "$_fzf_cache" && "$_fzf_cache" -nt "$(command -v fzf)" ]] || fzf --zsh >| "$_fzf_cache"
  source "$_fzf_cache"
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --info=inline --color=bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796 --color=fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6 --color=marker:#b7bdf8,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796 --color=selected-bg:#494d64,border:#363a4f,label:#cad3f5'
  # Dirs first, then files — mirrors Finder's "folders on top" behavior
  export FZF_DEFAULT_COMMAND='{ fd --type d --color=never; fd --type f --color=never; } 2>/dev/null'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=plain {} 2>/dev/null | head -100'"
  export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -50'"
fi

# atuin — enhanced history search; takes over Ctrl-R
if command -v atuin >/dev/null 2>&1; then
  _atuin_cache="$_zsh_cache/atuin-init.zsh"
  [[ -f "$_atuin_cache" && "$_atuin_cache" -nt "$(command -v atuin)" ]] || atuin init zsh >| "$_atuin_cache"
  source "$_atuin_cache"
fi

# zoxide — smart cd replacement (--cmd cd makes `cd` use zoxide transparently)
# `cd -` and normal path navigation work as expected; `zi` opens interactive picker
if command -v zoxide >/dev/null 2>&1; then
  _zoxide_cache="$_zsh_cache/zoxide-init.zsh"
  [[ -f "$_zoxide_cache" && "$_zoxide_cache" -nt "$(command -v zoxide)" ]] || zoxide init zsh --cmd cd >| "$_zoxide_cache"
  source "$_zoxide_cache"
fi

unset _zsh_cache _fzf_cache _atuin_cache _zoxide_cache
