# Suppress the instant-prompt warning fired when compinit prints noise
# (e.g. `_brew_services: no such file or directory` during a brew tap
# refresh race). It's harmless, self-heals on next `brew update`, and the
# warning is louder than the underlying issue. Set before sourcing the
# instant-prompt block so the option is in effect on this startup too.
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# Silence transient brew-race "no such file or directory" warnings from
# compinit. /opt/homebrew/share/zsh/site-functions/_brew_services (and
# friends) briefly vanish during `brew upgrade`'s atomic symlink swap;
# if compinit walks fpath in that window it prints `compinit:527: no
# such file or directory`. The file is back milliseconds later — next
# shell start is clean. Wrap compinit so only that specific class of
# error is dropped; all other compinit warnings still surface.
autoload -Uz compinit
functions[_orig_compinit]=$functions[compinit]
compinit() {
  _orig_compinit "$@" 2> >(grep -v 'no such file or directory' >&2)
}

# Enable Powerlevel10k instant prompt. Must stay near the top.
# Initialization code requiring console input must go above this block.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ── Completions fpath (before oh-my-zsh, which calls compinit) ─────────────
typeset -U fpath
fpath=(
  "/opt/homebrew/share/zsh/site-functions"   # Homebrew-managed completions
  "$HOME/.config/zsh/completions"            # cached completions (e.g. kubectl)
  $fpath
)

# ── oh-my-zsh ───────────────────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

if [[ -z "${DEVCONTAINER}" ]]; then
  plugins=(
    git
    macos
    kube-ps1
    vscode
    zsh-autosuggestions
    zsh-syntax-highlighting
  )
else
  # Dev containers: skip macOS-only plugin; others work via oh-my-zsh mount
  plugins=(
    git
    kube-ps1
    vscode
    zsh-autosuggestions
    zsh-syntax-highlighting
  )
fi

source "$ZSH/oh-my-zsh.sh"

# ── Modular config ──────────────────────────────────────────────────────────
for f in "$HOME/.config/zsh"/*.zsh(N); do
  source "$f"
done

# ── Prompt ──────────────────────────────────────────────────────────────────
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
