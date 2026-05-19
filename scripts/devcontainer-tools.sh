#!/usr/bin/env bash
# Install CLI tools in a devcontainer (Linux arm64/amd64).
# Idempotent — safe to run multiple times.
# Tools are installed to /usr/local/bin.
set -euo pipefail

ARCH=$(uname -m)
case "$ARCH" in
  aarch64|arm64) ARCH_ALT="aarch64"; GOARCH="arm64"; ARCH_FZF="arm64" ;;
  x86_64)        ARCH_ALT="x86_64";  GOARCH="amd64"; ARCH_FZF="amd64" ;;
  *) echo "Unsupported arch: $ARCH"; exit 1 ;;
esac

BIN="/usr/local/bin"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

installed() { command -v "$1" &>/dev/null; }

# ── bat ──────────────────────────────────────────────────────────────────────
if ! installed bat; then
  echo "Installing bat..."
  BAT_VER=$(curl -sL "https://api.github.com/repos/sharkdp/bat/releases/latest" | grep tag_name | cut -d'"' -f4 | tr -d 'v')
  curl -sL "https://github.com/sharkdp/bat/releases/download/v${BAT_VER}/bat-v${BAT_VER}-${ARCH_ALT}-unknown-linux-gnu.tar.gz" | tar xz -C "$TMP"
  cp "$TMP/bat-v${BAT_VER}-${ARCH_ALT}-unknown-linux-gnu/bat" "$BIN/"
fi

# ── eza ──────────────────────────────────────────────────────────────────────
if ! installed eza; then
  echo "Installing eza..."
  EZA_VER=$(curl -sL "https://api.github.com/repos/eza-community/eza/releases/latest" | grep tag_name | cut -d'"' -f4 | tr -d 'v')
  curl -sL "https://github.com/eza-community/eza/releases/download/v${EZA_VER}/eza_${ARCH_ALT}-unknown-linux-gnu.tar.gz" | tar xz -C "$TMP"
  cp "$TMP/eza" "$BIN/"
fi

# ── fd ───────────────────────────────────────────────────────────────────────
if ! installed fd; then
  echo "Installing fd..."
  FD_VER=$(curl -sL "https://api.github.com/repos/sharkdp/fd/releases/latest" | grep tag_name | cut -d'"' -f4 | tr -d 'v')
  curl -sL "https://github.com/sharkdp/fd/releases/download/v${FD_VER}/fd-v${FD_VER}-${ARCH_ALT}-unknown-linux-gnu.tar.gz" | tar xz -C "$TMP"
  cp "$TMP/fd-v${FD_VER}-${ARCH_ALT}-unknown-linux-gnu/fd" "$BIN/"
fi

# ── ripgrep ──────────────────────────────────────────────────────────────────
if ! installed rg; then
  echo "Installing ripgrep..."
  RG_VER=$(curl -sL "https://api.github.com/repos/BurntSushi/ripgrep/releases/latest" | grep tag_name | cut -d'"' -f4)
  curl -sL "https://github.com/BurntSushi/ripgrep/releases/download/${RG_VER}/ripgrep-${RG_VER}-${ARCH_ALT}-unknown-linux-gnu.tar.gz" | tar xz -C "$TMP"
  cp "$TMP/ripgrep-${RG_VER}-${ARCH_ALT}-unknown-linux-gnu/rg" "$BIN/"
fi

# ── fzf ──────────────────────────────────────────────────────────────────────
if ! installed fzf; then
  echo "Installing fzf..."
  FZF_VER=$(curl -sL "https://api.github.com/repos/junegunn/fzf/releases/latest" | grep tag_name | cut -d'"' -f4 | tr -d 'v')
  curl -sL "https://github.com/junegunn/fzf/releases/download/v${FZF_VER}/fzf-${FZF_VER}-linux_${ARCH_FZF}.tar.gz" | tar xz -C "$TMP"
  cp "$TMP/fzf" "$BIN/"
fi

# ── zoxide ───────────────────────────────────────────────────────────────────
if ! installed zoxide; then
  echo "Installing zoxide..."
  curl -sLS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash -s -- --bin-dir "$BIN"
fi

# ── atuin ────────────────────────────────────────────────────────────────────
if ! installed atuin; then
  echo "Installing atuin..."
  ATUIN_VER=$(curl -sL "https://api.github.com/repos/atuinsh/atuin/releases/latest" | grep tag_name | cut -d'"' -f4 | tr -d 'v')
  curl -sL "https://github.com/atuinsh/atuin/releases/download/v${ATUIN_VER}/atuin-${ARCH_ALT}-unknown-linux-gnu.tar.gz" | tar xz -C "$TMP"
  cp "$TMP/atuin" "$BIN/" 2>/dev/null || cp "$TMP/atuin-${ARCH_ALT}-unknown-linux-gnu/atuin" "$BIN/" 2>/dev/null || true
fi

# ── lazygit ──────────────────────────────────────────────────────────────────
if ! installed lazygit; then
  echo "Installing lazygit..."
  LG_VER=$(curl -sL "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep tag_name | cut -d'"' -f4 | tr -d 'v')
  curl -sL "https://github.com/jesseduffield/lazygit/releases/download/v${LG_VER}/lazygit_${LG_VER}_linux_${GOARCH}.tar.gz" | tar xz -C "$TMP"
  cp "$TMP/lazygit" "$BIN/"
fi

# ── neovim ───────────────────────────────────────────────────────────────────
if ! installed nvim; then
  echo "Installing neovim..."
  curl -sL "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${GOARCH}.tar.gz" | tar xz -C "$TMP"
  cp -r "$TMP/nvim-linux-${GOARCH}"/* /usr/local/
fi

# ── delta (git pager) ────────────────────────────────────────────────────────
if ! installed delta; then
  echo "Installing delta..."
  DELTA_VER=$(curl -sL "https://api.github.com/repos/dandavison/delta/releases/latest" | grep tag_name | cut -d'"' -f4)
  curl -sL "https://github.com/dandavison/delta/releases/download/${DELTA_VER}/delta-${DELTA_VER}-${ARCH_ALT}-unknown-linux-gnu.tar.gz" | tar xz -C "$TMP"
  cp "$TMP/delta-${DELTA_VER}-${ARCH_ALT}-unknown-linux-gnu/delta" "$BIN/"
fi

echo "✓ All devcontainer tools installed"
