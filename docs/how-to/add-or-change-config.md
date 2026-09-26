# Add or change a config file

## Change a tracked file

Edit it through `$HOME` or in the repo; it's the same file. Commit, push,
`sync-all` elsewhere. Nothing else to do.

## Track a new file in an existing package

Say you want to track `~/.config/git/attributes` in the `git` package.

1. Move the real file into the package, keeping its path relative to `$HOME`:

    ```bash
    mkdir -p ~/dotfiles/git/.config/git
    mv ~/.config/git/attributes ~/dotfiles/git/.config/git/attributes
    ```

2. Link it:

    ```bash
    dotfiles-sync        # or: stow --no-folding -R -d ~/dotfiles -t ~ git
    ```

3. Check: `readlink ~/.config/git/attributes` should point into `~/dotfiles`.
4. Commit and push. Other machines get the link on their next sync, **if they
   enable that package**.

!!! warning "Move it first"
    If a real file already sits where a link should go, sync refuses to replace
    it and reports a conflict. That protects your data, but it means you move
    the file into the repo yourself (step 1). On a fresh machine, `install.sh`
    moves such files aside for you as `<file>.pre-dotfiles`.

## Which package?

| The file is for… | Package |
|---|---|
| zsh | `zsh` (shared) or `personal` |
| git, tmux, Neovim, lazygit, atuin | the package of that name |
| the LLM agents | `ollama` |
| a tool with no package yet | [create one](add-a-package.md) |

## Rename or delete a file

Just do it in the repo, with `git mv` or `git rm`, then commit and push.

On every machine, the next sync links the new name. It also removes the old
symlink, which is now broken and points into the repo. Nothing is left behind.

## Files a tool keeps rewriting

If a tool rewrites its config constantly (window positions, caches, "last
opened"), don't track the whole file. Every machine would keep changing the
repo. Track only a stable file the tool *includes*, or leave it untracked.

Examples here: Neovim's `lazy-lock.json` is deliberately untracked, and the
tracked `lazygit/config.yml` is kept on lazygit's current schema so lazygit
never needs to rewrite it.

## Something only one machine should have

Don't track it. Use the machine-local files: `~/.gitconfig.local`,
`~/.config/zsh/90-<host>.zsh`, `~/.ssh/config`. See
[Untracked files](../reference/untracked-files.md).
