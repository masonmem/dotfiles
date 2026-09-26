# Update the shell framework

oh-my-zsh, powerlevel10k and the two zsh plugins only change when you bump
their pins in `shell-clones.txt`. That way every machine moves together, and
only to versions you've tried. (Background: [Shell framework pins](../concepts/shell-framework.md).)

## Steps

1. **Try the new version on this machine.** For example, powerlevel10k:

    ```bash
    cd ~/.oh-my-zsh/custom/themes/powerlevel10k
    git fetch --tags
    git log --oneline HEAD..origin/master | head      # what's new
    git checkout origin/master                        # or a tag
    exec zsh                                          # does the prompt still render?
    ```

2. **Record the new pin.** Copy the full SHA and a readable version:

    ```bash
    git rev-parse HEAD                                # full SHA for the pin
    git describe --tags                               # e.g. v1.20.0-110-gabc1234, for the comment
    ```

    Update that line in `~/dotfiles/shell-clones.txt`:

    ```text
    custom/themes/powerlevel10k   https://github.com/romkatv/powerlevel10k.git   <new-sha>   # <describe output>
    ```

3. **Test and ship.**

    ```bash
    cd ~/dotfiles && tests/run           # the startup test clones the new pins
    git commit -am "chore(shell): bump powerlevel10k to <version>" && git push
    ```

Every other machine checks out the new commit on its next `sync-all`. When
p10k moves, the gitstatus and instant-prompt caches are cleared automatically,
and hyperion's QNAP patch is re-applied.

## If a machine didn't move

`bootstrap-shell` leaves a clone alone when it has local edits, and says so:

```text
[bootstrap-shell] WARN: custom/themes/powerlevel10k: local changes — leaving it at a0c9dbe …
```

Look at what's changed, and discard it if it isn't yours to keep:

```bash
cd ~/.oh-my-zsh/custom/themes/powerlevel10k
git status && git diff
git checkout -- . && sync-all
```

## Adding another oh-my-zsh plugin

1. Add a line to `shell-clones.txt`:
   `custom/plugins/<name>   <git-url>   <sha>   # <version>`.
2. Add `<name>` to `plugins=(…)` in `zsh/.zshrc`.
3. Test, commit, push.

Plugins that ship *with* oh-my-zsh (like `git` or `macos`) need only step 2.
