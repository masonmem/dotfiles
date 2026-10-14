# Brewfile — every Mac. Software for one machine only goes in
# Brewfile.d/<host>.Brewfile.
#
#   brew bundle --file ~/dotfiles/Brewfile

tap "jesseduffield/lazygit", trusted: { formula: "lazygit" }
tap "anomalyco/tap", trusted: { formula: "opencode" }

# ── Core CLI tools ───────────────────────────────────────────────────────────
brew "bat"                                 # cat with syntax highlighting
brew "bat-extras"                          # batgrep, batdiff, batman, etc.
brew "coreutils"                           # GNU core utilities
brew "eza"                                 # modern ls replacement
brew "fd"                                  # modern find replacement
brew "fzf"                                 # fuzzy finder
brew "htop"                                # interactive process viewer
brew "jq"                                  # JSON processor
brew "ripgrep"                             # modern grep replacement
brew "tealdeer"                            # fast tldr client (`tldr`)
brew "tree"                                # directory tree viewer
brew "watch"                               # run command periodically
brew "wget"                                # HTTP file retriever
brew "yq"                                  # YAML/JSON/XML processor

# ── Shell ────────────────────────────────────────────────────────────────────
brew "atuin"                               # shell history database (Ctrl-R)
brew "stow"                                # symlink farm manager (dotfiles)
brew "tmux"                                # terminal multiplexer
brew "zoxide"                              # smarter cd replacement
brew "zsh"                                 # latest zsh (over macOS system zsh)
# oh-my-zsh and its theme/plugins are git clones (see README), not brews: the
# same ~/.oh-my-zsh then works on the QNAP and mounted into dev containers.

# ── Git ──────────────────────────────────────────────────────────────────────
brew "git"
brew "git-delta"                           # syntax-highlighted diff pager
brew "git-lfs"                             # large file storage
brew "gh"                                  # GitHub CLI
brew "jesseduffield/lazygit/lazygit"       # terminal UI for git
brew "lazydocker"                          # terminal UI for docker (k9s-like)

# ── Editors ──────────────────────────────────────────────────────────────────
brew "neovim"                              # modern vim
brew "tree-sitter-cli"                     # nvim-treesitter compiles parsers with it

# ── Languages & runtimes ─────────────────────────────────────────────────────
brew "go"                                  # Go programming language
brew "golangci-lint"                       # Go linter aggregator
brew "node"                                # Default node — keeps /opt/homebrew/bin/{node,npx} on PATH
                                           # so launchd / opencode MCP subprocesses / cron find
                                           # node without sourcing nvm. nvm still wins when active.
brew "nvm"                                 # Node version manager (per-project pins)
brew "pipx"                                # isolated Python CLIs
brew "pnpm"                                # fast Node package manager
brew "python@3.14"                         # Python
brew "yarn"                                # Node package manager

# ── Kubernetes ───────────────────────────────────────────────────────────────
brew "k9s"                                 # terminal UI for k8s
brew "kubecolor"                           # colorized kubectl output
brew "kubectx"                             # switch k8s contexts/namespaces
brew "stern"                               # multi-pod log tailing

# ── Networking ───────────────────────────────────────────────────────────────
brew "iperf3"                              # network bandwidth testing
brew "qrencode"                            # QR code generator

# ── Homelab GitOps (masonmem/homelab + Komodo) ───────────────────────────────
brew "gitleaks"                            # secret scanning, runs in homelab CI
brew "sops"                                # encrypted secrets for solaris stacks
brew "age"                                 # SOPS encryption backend

# ── Media ────────────────────────────────────────────────────────────────────
brew "yt-dlp"                              # video downloader (aliases in .zshrc)
brew "ffmpeg"                              # yt-dlp remuxing; general A/V work

# ── AI tooling ───────────────────────────────────────────────────────────────
brew "uv"                                  # Python pkg/runtime mgr; provides `uvx` for MCP servers
# Local-LLM agents; their configs are the `ollama` package. Ollama itself is
# NOT installed via Homebrew — the formula bottle ships no `llama-server`
# runner, so every model load fails. solaris runs the official build instead:
# ollama/bin/install-ollama.sh + ollama/launchagents/.
brew "aider"                               # diff-driven pair programming (60-aider-wrapper.zsh)
brew "anomalyco/tap/opencode"              # terminal AI coding agent (.config/opencode)
brew "block-goose-cli"                     # goose agent (61-goose-wrapper.zsh, .config/goose)

# ── Applications ─────────────────────────────────────────────────────────────
cask "claude-code@latest"                  # Anthropic's terminal-based AI coding agent (@latest tracks releases faster)
cask "copilot-cli"                         # GitHub Copilot CLI — part of the core agent stack
cask "docker-desktop"
cask "font-meslo-lg-nerd-font"             # p10k's recommended font — what the prompt glyphs assume
cask "font-jetbrains-mono-nerd-font"       # editor font
