# Add shell aliases, functions, env

## Pick the file

| Should apply to… | File |
|---|---|
| every machine | an existing file in `zsh/.config/zsh/` (aliases → `20-aliases.zsh`, env → `10-env.zsh`, integrations → `40-tools.zsh`), or a new `NN-name.zsh` |
| personal machines only | `personal/.config/zsh/50-personal.zsh` |
| the LLM tooling | `ollama/.config/zsh/` |
| one machine only | `~/.config/zsh/90-<host>.zsh`, untracked ([template](../reference/untracked-files.md#templateszsh-hostzsh)) |
| every shell, including scripts and `ssh host cmd` (PATH-like things) | `zsh/.zshenv`, keep it tiny |
| before oh-my-zsh / p10k load | `~/.zshrc.early.local`, untracked |

Files load in name order, so the number decides what runs after what.
A **new** file needs no registration; `.zshrc` sources every `*.zsh` in
`~/.config/zsh/`. It only has to be linked, which the next `dotfiles-sync` does.

## Always guard optional tools

Shared files also run on hyperion, containers and the work Mac, which may lack
the tool. An unguarded alias replaces a working command with a broken one.

```zsh
# ✅ alias only when the tool exists
(( $+commands[duf] )) && alias df='duf'

# ✅ several lines
if (( $+commands[kubectl] )); then
  alias kgp='kubectl get pods'
  alias kga='kubectl get all'
fi

# ❌ breaks `df` wherever duf isn't installed
alias df='duf'
```

`(( $+commands[x] ))` is zsh's built-in "is `x` on PATH?"; it spawns no
process.

## Tool init scripts: cache them

For tools that print a shell snippet to `eval` (the `tool init zsh` pattern),
use the cache helper in `40-tools.zsh` instead of running the tool on every
shell start:

```zsh title="zsh/.config/zsh/40-tools.zsh"
(( $+commands[direnv] )) && _cached_init direnv direnv hook zsh
```

The output is cached in `~/.cache/zsh/direnv-init.zsh` and rebuilt whenever the
`direnv` binary is newer. Add the line before `unfunction _cached_init` at the
bottom of the file.

## Functions

Define them normally. Two conventions from this repo:

- **Wrapping a command**: call through `command`, so the wrapper doesn't call
  itself.

    ```zsh
    rg() { command rg --smart-case "$@" }
    ```

- **Don't depend on `_underscore` helpers at call time.** Some coding agents
  snapshot your shell functions but drop names starting with `_`. A function
  that calls such a helper later breaks in those shells (the nvm stubs in
  `70-nvm.zsh` hit this). Helpers used only during startup are fine.

## Environment variables

- For interactive shells, `export` in `10-env.zsh` (or the personal / host
  file).
- For **every** process, including GUI apps started from a terminal, agents and
  `ssh host cmd`, use `zsh/.zshenv`. Keep it to plain assignments: no output,
  nothing slow.
- **Never put a secret in a tracked file.** Read it from a file at startup, as
  `12-github-cli.zsh` does, or scope it to one command with a wrapper, as the
  aider/goose wrappers do:

    ```zsh
    aider() { OPENAI_API_KEY="$AIDER_LITELLM_KEY" command aider "$@" }
    ```

## PATH

Add directories to the single list in `zsh/.zshenv`. Missing directories are
dropped automatically, so machine-specific paths are fine there. Don't
`export PATH=…` in other files; it would miss non-interactive shells and lose
the ordering.

## Try it, then ship it

```bash
exec zsh                             # reload
~/dotfiles/tests/run                 # syntax, shellcheck, real shell startup
git -C ~/dotfiles commit -am "feat(zsh): …" && git -C ~/dotfiles push
```
