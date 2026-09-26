# Everyday workflow

## Pick up changes made elsewhere

```bash
sync-all
```

That's it. Run it whenever you sit down at a machine, or let a LaunchAgent do it
(see [running unattended](../concepts/sync.md#running-it-unattended)).

## Make a change

```bash
# 1. Edit. ~/.zshrc and ~/dotfiles/zsh/.zshrc are the same file.
nvim ~/.config/zsh/20-aliases.zsh

# 2. Try it in this shell.
exec zsh

# 3. Run the checks (--offline skips the shell-startup test, which clones from GitHub).
~/dotfiles/tests/run

# 4. Commit and push.
cd ~/dotfiles
git add -A
git commit -m "feat(zsh): add alias for …"
git push
```

Then run `sync-all` on the other machines. New files are linked, deleted files'
links are removed, and new Brewfile entries are installed.

!!! tip "Why run the tests"
    `sync-all` copies a mistake to every machine. `tests/run` catches the usual
    ones: shell syntax errors, shellcheck findings, a startup that prints
    errors, broken sync logic. You can't forget: the pre-push hook runs
    `tests/run --offline` before every push and blocks it if anything fails.

## What happens if you forget to commit

Nothing bad. On the machine with uncommitted edits, `sync-all` skips *only*
the pull, warns, and still installs and links everything else. Commit and push
when you're ready; the next sync pulls normally.

If you committed on two machines without pulling in between, the branches
diverge. Sync warns and skips the pull. Fix it in the repo:

```bash
cd ~/dotfiles && git pull --rebase && git push
```

## Tools that edit tracked files for you

Some commands write *through* the symlinks into the repo. That's usually what
you want (commit the result), but know which ones do it:

| Command | Writes to | What to do |
|---|---|---|
| `git config --global …` | `git/.gitconfig`, which **every** machine gets | For machine-only settings use `git config --file ~/.gitconfig.local …` |
| `gh auth setup-git` | `git/.gitconfig` (a credential helper) | Move the added lines to `~/.gitconfig.local`, or commit them if you want them everywhere |
| `p10k configure` | `p10k/.p10k.zsh` | Commit it to change the prompt everywhere |
| `lazygit` (config migrations) | `lazygit/.config/lazygit/config.yml` | Commit it; the tracked file is kept on the current schema so this is rare |

Check with `git -C ~/dotfiles status` now and then.

## Quick checks

```bash
git -C ~/dotfiles status                  # anything uncommitted?
git -C ~/dotfiles log --oneline -5        # what arrived recently?
cat ~/.config/dotfiles/packages           # what this machine uses
brew bundle check --no-upgrade --file=~/dotfiles/Brewfile --verbose   # anything missing?
```
