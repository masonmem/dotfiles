# ~/.zshrc — interactive shells: oh-my-zsh + powerlevel10k, aliases, tools.
#
# The same file runs on the Macs, the QNAP and in dev containers, where most
# tools aren't installed. Anything that needs a tool checks for it first, so a
# missing tool means a missing alias, never an error.
#
# Every ~/.config/zsh/*.zsh is loaded at the end: tracked files from the
# optional packages (personal, ollama), and untracked ones you add on a single
# machine (e.g. ~/.config/zsh/local.zsh).

# Powerlevel10k instant prompt. Keep near the top; anything that may need
# console input goes above this block.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ── oh-my-zsh ────────────────────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_CUSTOM="$ZSH/custom"
ZSH_THEME="powerlevel10k/powerlevel10k"
# No terminal (`zsh -i -c` from a script, or VS Code reading the environment):
# nothing is shown, and p10k would start gitstatus and fail. Skip the theme.
[[ -t 0 ]] || ZSH_THEME=""
zstyle ':omz:update' mode auto   # oh-my-zsh updates itself about every two weeks

# Completions: Homebrew's (per Homebrew's docs, before oh-my-zsh runs
# compinit), and the extra set from zsh-completions.
fpath=(
  ${HOMEBREW_PREFIX:-/opt/homebrew}/share/zsh/site-functions(N)
  $ZSH_CUSTOM/plugins/zsh-completions/src(N)
  $fpath
)

# Bundled plugins, each only when its tool is installed (some print an error
# otherwise). The two cloned plugins come last; syntax highlighting must be
# the very last.
ZOXIDE_CMD_OVERRIDE=cd           # zoxide replaces cd: `cd proj` jumps; `cdi` picks
plugins=(git)
[[ $OSTYPE == darwin* ]] && plugins+=(macos)
(( $+commands[code] ))    && plugins+=(vscode)
(( $+commands[kubectl] )) && plugins+=(kubectl)   # completion, `k` and k* aliases
(( $+commands[zoxide] ))  && plugins+=(zoxide)
plugins+=(zsh-autosuggestions zsh-syntax-highlighting)

source "$ZSH/oh-my-zsh.sh"

# oh-my-zsh doesn't update what's cloned into $ZSH_CUSTOM. This pulls the
# theme and plugins, then updates oh-my-zsh itself.
zsh-update() {
  local d
  for d in "$ZSH_CUSTOM"/{themes,plugins}/*/.git(N:h); do
    print -P "%B${d:t}%b"
    git -C "$d" pull --ff-only
  done
  omz update
}

# ── Environment ──────────────────────────────────────────────────────────────
if (( $+commands[nvim] )); then
  export EDITOR=nvim
elif (( $+commands[vim] )); then
  export EDITOR=vim
else
  export EDITOR=vi
fi
export VISUAL="$EDITOR"
export BAT_THEME="Catppuccin Macchiato"   # bat, fzf previews and delta
export LESS="-R --use-color"

# git is set up to page through delta. Where delta isn't installed (containers,
# the QNAP), use plain less instead of failing.
if (( ! $+commands[delta] )); then
  export GIT_PAGER=less
  export GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=interactive.diffFilter GIT_CONFIG_VALUE_0=cat
fi

# ── Aliases ──────────────────────────────────────────────────────────────────
if (( $+commands[nvim] )); then
  alias vi=nvim
  alias vim=nvim
fi
(( $+commands[bat] ))       && alias cat='bat --paging=auto'
(( $+commands[lazygit] ))   && alias lg=lazygit
(( $+commands[kubecolor] )) && alias kubectl=kubecolor && compdef kubecolor=kubectl
(( $+commands[pip3] ))      && alias pip=pip3
(( $+commands[claude] ))    && alias cc=claude   # interactive only; scripts still get the C compiler

# eza for ls, except in containers: a host-built or cached eza has segfaulted
# there before, so containers keep the native ls (eza is still callable).
if [[ -n "${DEVCONTAINER:-}${REMOTE_CONTAINERS:-}" || -e /.dockerenv ]]; then
  alias ll='ls -alh'
  alias la='ls -Ah'
elif (( $+commands[eza] )); then
  alias ls='eza --group-directories-first'
  alias ll='eza -la --git --icons --group-directories-first'
  alias la='eza -la --icons --group-directories-first'
  alias lt='eza --tree --icons --group-directories-first'
fi

# ── Tools ────────────────────────────────────────────────────────────────────
# fzf: Ctrl-T files, Alt-C directories, ** completion. `fzf --zsh` is fzf's own
# setup; distro fzf older than 0.48 (common in containers) lacks it, so skip.
# Its key bindings need a terminal; `zsh -i -c` from scripts or agents has none.
if (( $+commands[fzf] )) && [[ -t 0 ]] && _fzf_init="$(fzf --zsh 2>/dev/null)"; then
  eval "$_fzf_init"
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --info=inline --color=bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796 --color=fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6 --color=marker:#b7bdf8,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796 --color=selected-bg:#494d64,border:#363a4f,label:#cad3f5'
  if (( $+commands[fd] )); then
    # Directories first, then files, like Finder.
    export FZF_DEFAULT_COMMAND='fd --type d --color=never; fd --type f --color=never'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --color=never'
  fi
  (( $+commands[bat] )) && export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=plain {} | head -100'"
  (( $+commands[eza] )) && export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -50'"
fi
unset _fzf_init

# atuin: history search on Ctrl-R and ↑ (replaces fzf's Ctrl-R).
(( $+commands[atuin] )) && eval "$(atuin init zsh)"

# Copilot CLI: GitHub work goes through the `gh` CLI, so its built-in GitHub
# MCP server is a duplicate. COPILOT_ENABLE_GITHUB_MCP=1 keeps it for a session.
# Runs with umask 077 so the files it writes are private.
if (( $+commands[copilot] )); then
  copilot() (
    umask 077
    case "${1:-}" in
      completion|help|login|mcp|plugin|plugins|skill|update|version) command copilot "$@" ;;
      *) if [[ "${COPILOT_ENABLE_GITHUB_MCP:-0}" == 1 ]]; then
           command copilot "$@"
         else
           command copilot --disable-mcp-server github-mcp-server "$@"
         fi ;;
    esac
  )
fi

# nvm (Homebrew's) takes ~0.5s to load, so it loads on first use of node, npm
# and friends. Each stub is self-contained on purpose: coding agents' shell
# snapshots drop functions whose names start with "_", which made a version
# with a shared helper recurse.
if [[ -s /opt/homebrew/opt/nvm/nvm.sh ]]; then
  export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
  for _cmd in nvm node npm npx yarn pnpm; do
    eval "$_cmd() { unfunction nvm node npm npx yarn pnpm; source /opt/homebrew/opt/nvm/nvm.sh; $_cmd \"\$@\"; }"
  done
  unset _cmd
fi

# ── Prompt, then per-package and per-machine files ───────────────────────────
[[ -n "$ZSH_THEME" && -r ~/.p10k.zsh ]] && source ~/.p10k.zsh

for f in ~/.config/zsh/*.zsh(N-.); do   # (N-.): none is fine; skip broken links
  source "$f"
done
unset f
