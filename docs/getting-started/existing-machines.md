# Updating an existing machine

For machines set up before the September 2026 restructure (navi, solaris,
hyperion, the work Mac). What changed, in short:

- There's a new **`personal`** package, and the local-LLM tools moved into
  `ollama/Brewfile`. The shared `Brewfile` is now work-safe.
- `dotfiles-sync` **needs** `~/.config/dotfiles/packages`. It no longer falls
  back to a default list, because the old default included the personal LLM
  stack.
- ai-sync is expected at **`~/code/ai-sync`**, no longer `~/.ai-config`.
- Templates moved to `templates/`, and PATH is set in one place (`~/.zshenv`).

## Steps

1. **Run `sync-all` twice.** The first run is still the *old* script (it's the
   one already running when the new code arrives). From the second run on, the
   new version cleans up stale links, including the old `~/launchagents` and
   `~/modelfiles` links from the ollama package.

2. **Check the package list.**

    ```bash
    cat ~/.config/dotfiles/packages
    ```

    | Machine | Should contain |
    |---|---|
    | navi, solaris | `zsh p10k tmux git nvim lazygit atuin personal ollama` |
    | work Mac | `zsh p10k tmux git nvim lazygit atuin` |
    | hyperion | `zsh p10k git` |

    If the file is missing, `dotfiles-sync` stops and tells you to run
    `~/dotfiles/install.sh <profile>`. Do that; it keeps your existing files.
    On navi and solaris, add **`personal`** (sync prints `not enabled on this
    host: personal` until you do):

    ```bash
    echo personal >> ~/.config/dotfiles/packages && sync-all
    ```

3. **ai-sync location.** If it still lives at `~/.ai-config`, move it:

    ```bash
    mv ~/.ai-config ~/code/ai-sync   # then re-run ~/code/ai-sync/install.sh
    ```

    Otherwise `GH_TOKEN` isn't exported and ai-sync's `bin/` isn't on PATH.

4. **Leftovers you can delete.** They're harmless, but no longer used:

    - `~/.config/zsh/completions/_kubectl`, if it's a real file. The kubectl
      completion now lives in `~/.cache/zsh/completions/`.
    - `~/.config/zsh/90-host.zsh.example`, if the old symlink survived.

5. **hyperion only:** the old manual `ln` loop is gone. `install.sh minimal`
   (or `dotfiles-sync`) now links everything with the built-in linker. If it
   reports an existing *real* file in the way, move it aside and re-run.
