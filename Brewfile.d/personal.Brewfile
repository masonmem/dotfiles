# Brewfile.d/personal.Brewfile — personal Macs only, never the work machine.
#
#   brew bundle --file ~/dotfiles/Brewfile.d/personal.Brewfile

tap "anomalyco/tap", trusted: { formula: "opencode" }

# ── Homelab GitOps (masonmem/homelab + Komodo) ───────────────────────────────
brew "gitleaks"                            # secret scanning, runs in homelab CI
brew "sops"                                # encrypted secrets for solaris stacks
brew "age"                                 # SOPS encryption backend

# ── Media ────────────────────────────────────────────────────────────────────
brew "yt-dlp"                              # video downloader (aliases in personal/.config/zsh/50-personal.zsh)
brew "ffmpeg"                              # yt-dlp remuxing; general A/V work

# ── Local-LLM agents (their configs are in the ollama package) ───────────────
# Ollama itself is NOT installed via Homebrew — the formula bottle ships no
# `llama-server` runner, so every model load fails. solaris runs the official
# build instead: ollama/bin/install-ollama.sh + ollama/launchagents/.
brew "aider"                               # diff-driven pair programming (60-aider-wrapper.zsh)
brew "anomalyco/tap/opencode"              # terminal AI coding agent (.config/opencode)
brew "block-goose-cli"                     # goose agent (61-goose-wrapper.zsh, .config/goose)
