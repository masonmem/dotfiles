# Repository layout

```text
dotfiles/
├── install.sh                 first-time setup for a machine (profile → package list, templates, sync)
├── Brewfile                   shared Homebrew packages: every Mac, work included
├── Brewfile.d/
│   ├── navi.Brewfile          host-only extras (keyed on host name)
│   └── solaris.Brewfile
├── shell-clones.txt           pinned commits for oh-my-zsh, powerlevel10k, zsh plugins
│
├── zsh/                       ── packages (linked into $HOME) ──────────────────────
│   ├── .zshenv                PATH + XDG for every zsh
│   ├── .zprofile              login shells: re-apply .zshenv after macOS path_helper
│   ├── .zshrc                 interactive loader
│   └── .config/zsh/NN-*.zsh   modular config, loaded in name order
├── p10k/.p10k.zsh             powerlevel10k prompt layout
├── git/
│   ├── .gitconfig             shared git config; includes ~/.gitconfig.local last
│   └── .config/git/ignore     global gitignore
├── tmux/.tmux.conf
├── nvim/.config/nvim/init.lua
├── lazygit/.config/lazygit/config.yml
├── atuin/.config/atuin/       config.toml + themes/
├── personal/                  personal machines only
│   ├── .config/zsh/50-personal.zsh
│   ├── Brewfile               (not linked) homelab + media tools
│   ├── pipx-tools.txt         (not linked) MCP servers, py-natpmp
│   └── .stow-local-ignore
├── ollama/                    local-LLM agent stack (personal machines)
│   ├── .aider.conf.yml, .config/{goose,opencode}/, .config/zsh/{16,60,61}-*.zsh
│   ├── bin/litellm-keys       → ~/bin/litellm-keys
│   ├── bin/install-ollama.sh  (not linked) solaris: install the Ollama server
│   ├── launchagents/          (not linked) solaris: launchd service for Ollama
│   ├── Brewfile               (not linked) aider, opencode, goose
│   ├── README.md              (not linked)
│   └── .stow-local-ignore
│
├── bin/                       ── not packages ────────────────────────────────────
│   ├── sync-all               dotfiles-sync + ai-sync's sync
│   ├── dotfiles-sync          pull, brew, pipx, shell framework, link, prune
│   ├── bootstrap-shell        converge ~/.oh-my-zsh clones to shell-clones.txt
│   ├── qnap-gitstatus-fix     QNAP patch for p10k's gitstatus
│   ├── dexec                  shell / command in a running dev container
│   ├── dotfiles-docs          serve / build this documentation site locally
│   └── configure-vscode-ai    merge AI-related VS Code settings
├── scripts/devcontainer-tools.sh   install CLI tools inside a Linux container
├── templates/                 untracked per-machine files, copied once by install.sh
│   ├── gitconfig.local        → ~/.gitconfig.local
│   ├── ssh_config             → ~/.ssh/config
│   └── zsh-host.zsh           → ~/.config/zsh/90-<host>.zsh (copy by hand)
├── tests/                     tests/run + the individual tests
├── docs/                      this site (MkDocs); mkdocs.yml at the root
└── .githooks/pre-push         runs tests/run --offline before every push (enabled by dotfiles-sync)
```

`bin/` is on PATH everywhere (via `~/.zshenv`), so its commands work as plain
`sync-all`, `dexec`, etc., including over `ssh host <cmd>`.

## What decides "package or not"

Any top-level folder is a package, **except** `bin`, `docs`, `scripts`,
`templates`, `tests`, `Brewfile.d`, `site` (a local docs build) and dot-folders. The list is `NON_PACKAGES`
in `bin/dotfiles-sync`.
