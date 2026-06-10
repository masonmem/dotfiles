tap "jesseduffield/lazygit"

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
brew "tealdeer"                            # fast tldr client (aliased in 20-aliases.zsh)
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
# oh-my-zsh, powerlevel10k, zsh-autosuggestions, zsh-syntax-highlighting are
# NOT brew-managed — bin/bootstrap-shell git-clones them into ~/.oh-my-zsh/,
# which is the layout .zshrc actually loads from.

# ── Git ──────────────────────────────────────────────────────────────────────
brew "git"
brew "git-delta"                           # syntax-highlighted diff pager
brew "git-lfs"                             # large file storage
brew "gh"                                  # GitHub CLI
brew "jesseduffield/lazygit/lazygit"       # terminal UI for git
brew "lazydocker"                          # terminal UI for docker (k9s-like)

# ── Editors ──────────────────────────────────────────────────────────────────
brew "neovim"                              # modern vim

# ── Languages & runtimes ─────────────────────────────────────────────────────
brew "go"                                  # Go programming language
brew "golangci-lint"                       # Go linter aggregator
brew "node"                                # Default node — keeps /opt/homebrew/bin/{node,npx} on PATH
                                           # so launchd / opencode MCP subprocesses / cron find
                                           # node without sourcing nvm. nvm still wins when active.
brew "nvm"                                 # Node version manager (per-project pins)
brew "pipx"                                # install Python CLI tools in isolation (tool list: pipx-tools.txt)
brew "pnpm"                                # fast Node package manager
brew "python@3.14"                         # Python
brew "yarn"                                # Node package manager

# ── Kubernetes ───────────────────────────────────────────────────────────────
brew "k9s"                                 # terminal UI for k8s
brew "kubecolor"                           # colorized kubectl output
brew "kubectx"                             # switch k8s contexts/namespaces
brew "stern"                               # multi-pod log tailing

# ── Media & networking ───────────────────────────────────────────────────────
brew "ffmpeg"                              # video/audio processing
brew "yt-dlp"                              # video downloader
brew "iperf3"                              # network bandwidth testing
brew "qrencode"                            # QR code generator

# ── Homelab GitOps (masonmem/homelab + Komodo) ───────────────────────────────
brew "gitleaks"                            # secret-scanning, runs in homelab CI
brew "sops"                                # encrypted secrets for solaris stacks
brew "age"                                 # SOPS encryption backend (per-host + admin keys)

# ── LLM / AI tooling ─────────────────────────────────────────────────────────
brew "ollama"                              # local LLM runtime (server lives on solaris)
brew "aider"                               # AI pair programming in the terminal
brew "opencode"                            # terminal-native AI coding agent
brew "block-goose-cli"                     # goose AI agent (block.xyz)
brew "uv"                                  # Python pkg/runtime mgr; provides `uvx` for MCP servers

# ── Applications ─────────────────────────────────────────────────────────────
cask "claude-code@latest"                  # Anthropic's terminal-based AI coding agent (@latest tracks releases faster)
cask "copilot-cli"                         # GitHub Copilot CLI — part of the core agent stack
cask "docker-desktop"
cask "font-meslo-lg-nerd-font"             # p10k's recommended font — what the prompt glyphs assume
cask "font-jetbrains-mono-nerd-font"       # editor font
