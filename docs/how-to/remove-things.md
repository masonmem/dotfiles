# Remove things

Sync only ever *adds* software and *adds or repairs* links. Removals that
affect installed software are deliberate, manual steps.

## Delete or rename a tracked file

`git rm` or `git mv` it in the repo, commit, push. Every machine's next sync
removes the old symlink automatically, because it now points at a file that
doesn't exist.

## Stop installing a tool

1. Delete its line from the Brewfile (or `pipx-tools.txt`), commit, push.
   New machines won't get it.
2. Uninstall it where it's already installed, since sync never uninstalls:

    ```bash
    brew uninstall <formula>        # or: brew uninstall --cask <cask>
    pipx uninstall <name>
    ```

To find everything installed that no Brewfile lists, preview Homebrew's
cleanup (it only lists; `--force` would remove):

```bash
brew bundle cleanup --file=~/dotfiles/Brewfile
```

On personal Macs this also lists what package and host Brewfiles install, so
read the list before removing anything.

## Stop using a package on a machine

1. Remove its line from `~/.config/dotfiles/packages`.
2. Unlink its files. Sync won't do this, because it no longer looks at the
   package:

    ```bash
    stow -D -d ~/dotfiles -t ~ <package>
    ```

    Without stow (hyperion), delete the symlinks that point into
    `~/dotfiles/<package>/`.
3. Optionally uninstall the software its `Brewfile` / `pipx-tools.txt`
   brought in.

## Remove a package from the repo entirely

1. On each machine that enables it, do [the steps above](#stop-using-a-package-on-a-machine).
2. `git rm -r <package>`, remove it from the `install.sh` profiles and the docs,
   commit, push.

If you skip step 1 on some machine, its next sync warns
`ignoring '<package>' in …/packages: not a package`, and removes the dangling
links once the files are gone.

## Remove the whole setup from a machine

```bash
cd ~/dotfiles
for p in $(grep -v '^#' ~/.config/dotfiles/packages); do stow -D -d ~/dotfiles -t ~ "$p"; done
# restore anything install.sh set aside:
for f in $(find ~ -maxdepth 3 -name '*.pre-dotfiles' 2>/dev/null); do mv "$f" "${f%.pre-dotfiles}"; done
```

Installed software stays; remove it with `brew uninstall` if you want.
