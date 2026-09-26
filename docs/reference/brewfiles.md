# Brewfiles and tool lists

Live copies of every tool list in the repo. Which ones a machine installs
depends on its packages and host name; see [What sync does](../concepts/sync.md#2-homebrew).

| File | Installed on |
|---|---|
| `Brewfile` | every Mac |
| `personal/Brewfile`, `personal/pipx-tools.txt` | machines with the `personal` package |
| `ollama/Brewfile` | machines with the `ollama` package |
| `Brewfile.d/<host>.Brewfile` | that one host |
| `scripts/devcontainer-tools.sh` | dev containers |

## Shared: `Brewfile`

```ruby title="Brewfile"
--8<-- "Brewfile"
```

## Personal: `personal/Brewfile`

```ruby title="personal/Brewfile"
--8<-- "personal/Brewfile"
```

## Local-LLM stack: `ollama/Brewfile`

```ruby title="ollama/Brewfile"
--8<-- "ollama/Brewfile"
```

## Per host: `Brewfile.d/`

=== "navi"

    ```ruby title="Brewfile.d/navi.Brewfile"
    --8<-- "Brewfile.d/navi.Brewfile"
    ```

=== "solaris"

    ```ruby title="Brewfile.d/solaris.Brewfile"
    --8<-- "Brewfile.d/solaris.Brewfile"
    ```

## pipx lists

```text title="personal/pipx-tools.txt"
--8<-- "personal/pipx-tools.txt"
```

## Not in any Brewfile

| What | Installed by |
|---|---|
| oh-my-zsh, powerlevel10k, zsh-autosuggestions, zsh-syntax-highlighting | `bootstrap-shell`, pinned in `shell-clones.txt` |
| Neovim plugins | lazy.nvim, on first start |
| Ollama server (solaris) | `ollama/bin/install-ollama.sh` ([why](llm-stack.md#the-ollama-server-solaris)) |
| Rust (`~/.cargo/bin` is on PATH if present) | `rustup`, only if you want it |
| Node versions | `nvm install …` (Homebrew's `node` is the default) |
