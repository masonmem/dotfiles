# ~/.zshrc — interactive shells. A thin loader: oh-my-zsh + powerlevel10k,
# then every ~/.config/zsh/*.zsh in name order (90-<host>.zsh last).

# Optional, untracked per-host overrides that must run BEFORE oh-my-zsh and
# p10k initialise — e.g. POWERLEVEL9K_DISABLE_GITSTATUS=true on a host whose
# libc is too old for gitstatusd, or ZSH_THEME="" to skip p10k entirely.
[[ -r "$HOME/.zshrc.early.local" ]] && source "$HOME/.zshrc.early.local"

# compinit briefly prints "no such file or directory" if a shell starts while
# `brew upgrade` is swapping /opt/homebrew/share/zsh/site-functions symlinks.
# It self-heals on the next shell; drop only that message, keep other errors.
autoload -Uz +X compinit
functions[_orig_compinit]=$functions[compinit]
compinit() {
  _orig_compinit "$@" 2> >(grep -v 'no such file or directory' >&2)
}

# Powerlevel10k instant prompt. Must stay near the top; anything that may need
# console input goes above this block.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ── Completion search path (must be set before oh-my-zsh runs compinit) ─────
typeset -U fpath
fpath=(
  "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completions"   # generated (kubectl; see 30-completions.zsh)
  /opt/homebrew/share/zsh/site-functions
  $fpath
)
fpath=($^fpath(N-/))

# ── oh-my-zsh ───────────────────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="${ZSH_THEME-powerlevel10k/powerlevel10k}"   # ~/.zshrc.early.local may override
plugins=(git vscode zsh-autosuggestions zsh-syntax-highlighting)
[[ "$OSTYPE" == darwin* ]] && plugins+=(macos)
source "$ZSH/oh-my-zsh.sh"

# ── Modular config ──────────────────────────────────────────────────────────
# (N-.) = no error if empty; skip anything that isn't (a link to) a regular file.
for f in "$HOME/.config/zsh"/*.zsh(N-.); do
  source "$f"
done
unset f

# ── Prompt ──────────────────────────────────────────────────────────────────
[[ "$ZSH_THEME" == powerlevel10k/* && -r ~/.p10k.zsh ]] && source ~/.p10k.zsh
