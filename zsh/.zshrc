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
# `autoload -Uz +X` loads the function body without executing it, so we
# can clone it into a renamed copy before replacing the original.
autoload -Uz +X compinit
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
  "$HOME/.config/zsh/completions"            # cached completions (e.g. kubectl)
  $fpath
)
# Homebrew-managed completions (Mac only)
[[ -d /opt/homebrew/share/zsh/site-functions ]] && fpath=(/opt/homebrew/share/zsh/site-functions $fpath)

# ── oh-my-zsh ───────────────────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins universal on every host; the `macos` plugin only loads on Darwin
# (so the same .zshrc works on Linux/QNAP without errors). DEVCONTAINER=1
# also skips macos to support that case.
plugins=(
  git
  kube-ps1
  vscode
  zsh-autosuggestions
  zsh-syntax-highlighting
)
if [[ "$OSTYPE" == darwin* && -z "${DEVCONTAINER}" ]]; then
  plugins+=(macos)
fi

source "$ZSH/oh-my-zsh.sh"

# ── Modular config ──────────────────────────────────────────────────────────
for f in "$HOME/.config/zsh"/*.zsh(N); do
  source "$f"
done

# ── Prompt ──────────────────────────────────────────────────────────────────
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
