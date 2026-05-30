# Homebrew (Mac) — gated so this file is safe to source on non-Mac hosts
# (e.g. QNAP / Linux containers) where brew isn't installed.
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

# pipx default user bin (created by `pipx` 2025-09-09)
export PATH="$PATH:$HOME/.local/bin"
