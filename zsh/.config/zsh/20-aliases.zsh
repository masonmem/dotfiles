# Aliases — guarded so missing optional binaries don't shadow real ones.
# Same `command -v` pattern as 40-tools.zsh. On hosts that don't have the
# fancy tool (hyperion QNAP, minimal Linux containers, work machine with
# stripped Brewfile), the alias is skipped and the underlying command
# (`cat`, `ls`, `vi`, …) keeps doing what you'd expect.

# --- Editors ---
# vi/vim → nvim. CRITICAL to guard: on hosts without nvim (QNAP, minimal
# Linux), aliasing breaks editing entirely.
if command -v nvim >/dev/null 2>&1; then
  alias vi='nvim'
  alias vim='nvim'
fi

# --- Modern CLI replacements ---
if command -v bat >/dev/null 2>&1; then
  alias cat='bat --paging=auto'
fi

if [[ -n "${DEVCONTAINER:-}" || -n "${REMOTE_CONTAINERS:-}" || -e /.dockerenv ]]; then
  # A host-built or cached eza binary can be incompatible with a container's
  # libc/CPU and has caused `ls` to segfault. Keep the native utility as the
  # reliable boundary; eza remains available explicitly for diagnosis.
  unalias ls ll la lt 2>/dev/null || true
  alias ll='command ls -alh'
  alias la='command ls -Ah'
elif command -v eza >/dev/null 2>&1; then
  alias ls='eza --group-directories-first'
  alias ll='eza -la --git --icons --group-directories-first'
  alias la='eza -la --icons --group-directories-first'
  alias lt='eza --tree --icons --group-directories-first'
fi

# --- Kubernetes ---
if command -v kubecolor >/dev/null 2>&1; then
  alias kubectl='kubecolor'
fi
# `k → kubectl` works whether kubectl is the binary or the kubecolor alias.
if command -v kubectl >/dev/null 2>&1; then
  alias k='kubectl'
fi

# --- Python ---
# pip3 is on every modern host; alias is harmless if pip3 is missing
# (would only fail on invocation, not shell startup). Guard anyway for
# explicit consistency.
if command -v pip3 >/dev/null 2>&1; then
  alias pip='pip3'
fi

# --- Claude Code ---
# `cc` is the C compiler in non-interactive shells (Makefiles, build scripts
# still find /usr/bin/cc); only typing `cc` at an interactive prompt is
# remapped. Guarded so hosts without the CLI keep `cc` as the compiler.
if command -v claude >/dev/null 2>&1; then
  alias cc='claude'
fi

# --- Git ---
if command -v lazygit >/dev/null 2>&1; then
  alias lg='lazygit'
fi
if command -v tldr >/dev/null 2>&1; then
  alias tldr='tldr --color'
fi

# --- Media ---
if command -v yt-dlp >/dev/null 2>&1; then
  alias youtube-dl='yt-dlp --remux-video mp4'
  alias ytdl='yt-dlp --remux-video mp4 --force-generic-extractor'
fi

# --- WireGuard NAT-PMP port forwarding ---
# Loop-alias; depends on natpmp-client.py being on PATH.
if command -v natpmp-client.py >/dev/null 2>&1; then
  alias pf='while true; do date && natpmp-client.py -g 10.2.0.1 -u -l 60 0 0 && natpmp-client.py -g 10.2.0.1 -l 60 0 0 | grep port || { echo -e "ERROR with natpmpc command \a"; break; }; sleep 45; done'
fi
