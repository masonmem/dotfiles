# Shell framework pins

oh-my-zsh, powerlevel10k, zsh-autosuggestions and zsh-syntax-highlighting are
**git clones** under `~/.oh-my-zsh`, because that's where `.zshrc` loads them
from. They are not Homebrew formulae. Their versions are pinned in
`shell-clones.txt`, just as the Brewfile declares Homebrew packages.

## The pin file

```text title="shell-clones.txt (entries)"
--8<-- "shell-clones.txt:entries"
```

Each entry has three fields: the path under `~/.oh-my-zsh` (`.` means the
folder itself), the git URL, and a **full commit SHA**. The trailing comment
records the human-readable version.

## What `bootstrap-shell` does with it

`dotfiles-sync` runs it on every host. For each entry:

| State of the clone | Action |
|---|---|
| missing | clone, then check out the pin |
| already at the pin | nothing, and no network access |
| at another commit, no local edits | fetch (unshallowing if needed), check out the pin |
| has local edits | warn and leave it alone |
| hyperion's known QNAP patch is the only edit | set the patch aside, check out the pin, re-apply the patch |

When powerlevel10k moves, it also clears `~/.cache/gitstatus` and the
instant-prompt caches so the new version takes effect.

Why pin at all: before this existed, each machine stayed on whatever version it
was first set up with. One laptop ran a four-year-old powerlevel10k that
couldn't render the current prompt config. Pins make every machine converge on
the same tested versions.

To upgrade, see [Update the shell framework](../how-to/update-shell-framework.md).
