# Tool integrations.

# GitHub work goes through the authenticated `gh` CLI, so Copilot's built-in
# GitHub MCP server is a duplicate; disable it for normal sessions. Set
# COPILOT_ENABLE_GITHUB_MCP=1 for a one-off session that needs it.
copilot() {
  (
    umask 077
    case "${1:-}" in
      completion|help|login|mcp|plugin|plugins|skill|update|version)
        command copilot "$@"
        ;;
      *)
        if [[ "${COPILOT_ENABLE_GITHUB_MCP:-0}" == 1 ]]; then
          command copilot "$@"
        else
          command copilot --disable-mcp-server github-mcp-server "$@"
        fi
        ;;
    esac
  )
}

# fzf / atuin / zoxide print init scripts; cache them instead of spawning the
# tool on every shell start. The cache is rebuilt when the binary is newer,
# and discarded if generation fails (e.g. an fzf too old for --zsh).
_zsh_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
mkdir -p "$_zsh_cache"
_cached_init() {   # <tool> <init command...>
  local cache="$_zsh_cache/$1-init.zsh"
  if [[ ! -s "$cache" || "$commands[$1]" -nt "$cache" ]]; then
    "${@:2}" >| "$cache" 2>/dev/null || { rm -f "$cache"; return 1; }
  fi
  source "$cache"
}

# fzf — Ctrl-T (file picker) and Alt-C (dir picker). Its Ctrl-R is replaced by atuin below.
if (( $+commands[fzf] )); then
  _cached_init fzf fzf --zsh
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --info=inline --color=bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796 --color=fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6 --color=marker:#b7bdf8,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796 --color=selected-bg:#494d64,border:#363a4f,label:#cad3f5'
  # Dirs first, then files — mirrors Finder's "folders on top".
  export FZF_DEFAULT_COMMAND='{ fd --type d --color=never; fd --type f --color=never; } 2>/dev/null'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=plain {} 2>/dev/null | head -100'"
  export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} 2>/dev/null | head -50'"
fi

# atuin — history search on Ctrl-R and ↑.
(( $+commands[atuin] )) && _cached_init atuin atuin init zsh

# zoxide — `cd` learns directories (`cd proj` jumps); `zi` is the interactive picker.
(( $+commands[zoxide] )) && _cached_init zoxide zoxide init zsh --cmd cd

unfunction _cached_init
unset _zsh_cache
