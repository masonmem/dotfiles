# Shell reference

Every alias for an optional tool exists **only if the tool is installed**.
Otherwise the original command is left alone.

## Aliases

| Alias | Runs | Package | Condition |
|---|---|---|---|
| `vi`, `vim` | `nvim` | zsh | nvim installed |
| `cat` | `bat --paging=auto` | zsh | bat installed |
| `ls` | `eza --group-directories-first` | zsh | eza installed, not in a container |
| `ll` | `eza -la --git --icons --group-directories-first` | zsh | as above; in containers: `ls -alh` |
| `la` | `eza -la --icons --group-directories-first` | zsh | as above; in containers: `ls -Ah` |
| `lt` | `eza --tree --icons --group-directories-first` | zsh | eza installed, not in a container |
| `kubectl` | `kubecolor` | zsh | kubecolor installed |
| `k` | `kubectl` | zsh | kubectl installed |
| `pip` | `pip3` | zsh | pip3 installed |
| `cc` | `claude` | zsh | Claude Code installed (interactive only; scripts still get the C compiler) |
| `lg` | `lazygit` | zsh | lazygit installed |
| `youtube-dl` | `yt-dlp --remux-video mp4` | personal | yt-dlp installed |
| `ytdl` | `yt-dlp --remux-video mp4 --force-generic-extractor` | personal | yt-dlp installed |
| `pf` | NAT-PMP port-forward loop against `10.2.0.1` | personal | `natpmp-client.py` installed |

oh-my-zsh plugins add more:

- `git`: `gst`, `gco`, `gcm`, `gp`, `gl`, `glog`, … (list them with
  `alias | grep '=git'`)
- `vscode`: `vsc`, `vscd`, …
- `macos` (macOS only): `ofd`, `cdf`, `pfd`, …

Bypass any alias with `command`, as in `command ls`, or a backslash: `\cat`.

## Functions

| Function | What it does | Package |
|---|---|---|
| `copilot` | runs Copilot CLI with `umask 077`, and without its built-in GitHub MCP server (`gh` covers that). `COPILOT_ENABLE_GITHUB_MCP=1 copilot …` keeps it for one session. | zsh |
| `nvm`, `node`, `npm`, `npx`, `yarn`, `pnpm` | lazy-load stubs: the first call loads nvm, then runs the real command | zsh |
| `aider` | runs aider with `OPENAI_API_KEY` set to its own LiteLLM key; `AIDER_USE_MASTER_KEY=1` uses the master key | ollama |
| `goose` | runs goose with `OPENAI_API_KEY` set to its own LiteLLM key | ollama |

## Key bindings

| Keys | Where | Does |
|---|---|---|
| ++ctrl+r++ | shell | atuin history search |
| ++up++ | shell | atuin history search, starting from what you've typed |
| ++ctrl+t++ | shell | fzf: insert a file path (dirs first) |
| ++alt+c++ | shell | fzf: cd into a directory |
| ++right++ | shell | accept the grey autosuggestion |
| `cd <words>` / `zi` | shell | zoxide jump / interactive picker |
| ++ctrl+a++ | tmux | the tmux prefix; see [tmux](../guides/tmux.md) |

## Environment variables

### Set for you

| Variable | Value | Set in |
|---|---|---|
| `PATH` | see [Shell startup](../concepts/shell.md#why-path-lives-in-zshenv) | `.zshenv` |
| `XDG_CONFIG_HOME`, `XDG_CACHE_HOME`, `XDG_DATA_HOME` | `~/.config`, `~/.cache`, `~/.local/share` | `.zshenv` |
| `_ZO_DOCTOR` | `0` (silences a harmless zoxide warning) | `.zshenv` |
| `EDITOR`, `VISUAL` | `nvim`, else `vim`, else `vi` | `10-env.zsh` |
| `BAT_THEME` | `Catppuccin Macchiato` (bat, fzf previews, delta) | `10-env.zsh` |
| `LESS` | `-R --use-color` | `10-env.zsh` |
| `NVM_DIR` | `~/.nvm` | `10-env.zsh` |
| `GH_TOKEN` | ai-sync's `secrets/github-mcp-pat.txt`, if present and `GH_TOKEN` isn't set | `12-github-cli.zsh` |
| `FZF_DEFAULT_OPTS`, `FZF_DEFAULT_COMMAND`, `FZF_CTRL_T_*`, `FZF_ALT_C_OPTS` | Catppuccin colours, fd-based listing, previews | `40-tools.zsh` |
| `LITELLM_BASE_URL`, `OPENCODE_/AIDER_/GOOSE_LITELLM_KEY` | gateway URL, per-tool keys | `16-llm-gateway.zsh` (ollama) |
| `COPILOT_OTEL_ENABLED`, `OTEL_EXPORTER_OTLP_ENDPOINT`, `OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT` | Copilot telemetry to `localhost:4318`, *including prompt and code content* | `50-personal.zsh` (personal) |

### You can set

| Variable | Effect |
|---|---|
| `DOTFILES` | repo location for the scripts (default `~/dotfiles`; the shell config itself assumes `~/dotfiles`) |
| `AI_CONFIG` | ai-sync location (default `~/code/ai-sync`) |
| `ZSH` | oh-my-zsh location (default `~/.oh-my-zsh`) |
| `SHELL_CLONES_MANIFEST` | alternative pin file for `bootstrap-shell` (the tests use it) |
| `DEVCONTAINER=1` | marks a dev container (set in the compose file) |
| `COPILOT_ENABLE_GITHUB_MCP=1` | keep Copilot's GitHub MCP server for one run |
| `DEXEC_*` | see [dexec](commands.md#dexec) |

## Caches

| Path | Contents | Safe to delete? |
|---|---|---|
| `~/.cache/zsh/{fzf,atuin,zoxide}-init.zsh` | cached init scripts | yes, rebuilt on the next shell |
| `~/.cache/zsh/completions/_kubectl` | kubectl completion | yes, rebuilt on the next shell |
| `~/.cache/p10k-instant-prompt-*.zsh`, `~/.cache/gitstatus` | prompt caches | yes |
