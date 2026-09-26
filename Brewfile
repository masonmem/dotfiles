# Brewfile — shared by EVERY Mac, including the work machine. Keep it to
# general tooling. Personal-only software goes in a package Brewfile
# (personal/Brewfile, ollama/Brewfile) and single-host software in
# Brewfile.d/<host>.Brewfile; dotfiles-sync installs all that apply.

tap "jesseduffield/lazygit", trusted: { formula: "lazygit" }

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
brew "tree-sitter-cli"                     # nvim-treesitter compiles parsers with it

# ── Languages & runtimes ─────────────────────────────────────────────────────
brew "go"                                  # Go programming language
brew "golangci-lint"                       # Go linter aggregator
brew "node"                                # Default node — keeps /opt/homebrew/bin/{node,npx} on PATH
                                           # so launchd / opencode MCP subprocesses / cron find
                                           # node without sourcing nvm. nvm still wins when active.
brew "nvm"                                 # Node version manager (per-project pins)
brew "pipx"                                # isolated Python CLIs (lists: <package>/pipx-tools.txt)
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

# ── AI tooling ───────────────────────────────────────────────────────────────
# The local-LLM agent stack (aider, opencode, goose) is in ollama/Brewfile.
brew "uv"                                  # Python pkg/runtime mgr; provides `uvx` for MCP servers

# ── Applications ─────────────────────────────────────────────────────────────
cask "claude-code@latest"                  # Anthropic's terminal-based AI coding agent (@latest tracks releases faster)
cask "copilot-cli"                         # GitHub Copilot CLI — part of the core agent stack
cask "docker-desktop"
cask "font-meslo-lg-nerd-font"             # p10k's recommended font — what the prompt glyphs assume
cask "font-jetbrains-mono-nerd-font"       # editor font
