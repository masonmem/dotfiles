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
