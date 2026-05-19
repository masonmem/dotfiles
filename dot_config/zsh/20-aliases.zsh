# --- Modern CLI replacements ---
alias cat='bat --paging=never --style=plain'
alias ls='eza'
alias ll='eza -la --git --icons'
alias la='eza -la --icons'
alias lt='eza --tree --icons'

# --- Kubernetes ---
alias kubectl='kubecolor'
alias k='kubectl'

# --- Git ---
alias lg='lazygit'

# --- Media ---
alias youtube-dl='yt-dlp --remux-video mp4'
alias ytdl='yt-dlp --remux-video mp4 --force-generic-extractor'

# --- WireGuard NAT-PMP port forwarding ---
alias pf='while true; do date && natpmp-client.py -g 10.2.0.1 -u -l 60 0 0 && natpmp-client.py -g 10.2.0.1 -l 60 0 0 | grep port || { echo -e "ERROR with natpmpc command \a"; break; }; sleep 45; done'
