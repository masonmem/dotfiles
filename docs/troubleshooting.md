# Troubleshooting

Start with `sync-all` and read its output. Every warning says what it skipped
and why.

## Sync

??? failure "`ERROR: no package list at ~/.config/dotfiles/packages`"
    The machine has never been set up with `install.sh`, or the file was
    deleted. Sync won't guess which packages to link. Run
    `~/dotfiles/install.sh <personal|work|minimal>`; it keeps your existing
    files.

??? failure "`could not link: <package>` / `existing target is neither a link nor a directory`"
    A real file sits where a symlink should go. Sync never overwrites files.

    - If the repo's version is the one you want: `mv ~/<file> ~/<file>.old`,
      then `sync-all`, or run `dotfiles-sync --backup-conflicts` to do that for
      every conflict.
    - If yours has changes worth keeping: copy them into the repo file first,
      then do the above.

??? failure "`… is a symlink to somewhere else — not replacing it`"
    You made that symlink yourself (built-in linker only; stow reports it as a
    conflict). Remove it if the repo should own that path.

??? failure "`git push` is refused after `[pre-push] tests/run --offline`"
    A check failed; the output above says which one. Fix it, commit, and push
    again. To push anyway, once and on purpose: `git push --no-verify`.

??? warning "`uncommitted changes … skipping pull`"
    Expected when you have local edits. Everything except the pull still ran.
    Commit and push them, or `git stash`, then sync again.

??? warning "`local and upstream have diverged`"
    You committed on two machines without syncing in between.
    `cd ~/dotfiles && git pull --rebase && git push`.

??? warning "`brew bundle failed for …`"
    Usually a macOS version Homebrew doesn't support yet, or a network blip.
    The rest of the sync still ran. Re-run the command it prints once Homebrew
    catches up.

??? warning "Homebrew refuses a formula because its tap isn't trusted"
    The formula comes from a third-party tap declared without `trusted:`. Add it next to
    the tap in the Brewfile: `tap "owner/repo", trusted: { formula: "name" }`.

??? info "A tool I added to a Brewfile didn't appear on another machine"
    Check, on that machine: is the entry in a Brewfile it uses? (`packages:`
    and `host:` in the sync output tell you which apply.) Did the sync skip the
    pull? `git -C ~/dotfiles log -1` shows what it has.

??? info "A deleted file's symlink is still there"
    Stale links are pruned in `~`, `~/.config` and `~/bin`. A link elsewhere, or
    one belonging to a package the machine no longer enables, has to be removed
    by hand. See [Remove things](how-to/remove-things.md).

## Shell

??? failure "`[oh-my-zsh] …` errors, or no prompt theme"
    The framework isn't installed or is broken. Run `bootstrap-shell` and read
    its output. A clone with local edits is skipped with a warning; see
    [Update the shell framework](how-to/update-shell-framework.md#if-a-machine-didnt-move).

??? failure "Prompt icons show as boxes or question marks"
    The terminal isn't using a Nerd Font. Select *MesloLGS Nerd Font* (installed
    by the Brewfile) in the terminal's settings.

??? warning "`[WARNING]: Console output during zsh initialization detected`"
    Something printed during startup. Instant prompt is set to `quiet`, so
    this only shows if `.p10k.zsh` was changed back. Find the culprit with
    `zsh -ixc exit 2>&1 | less`, and move any output-producing command out of
    startup.

??? info "A command isn't found in `ssh host cmd` but works interactively"
    Non-interactive shells only read `~/.zshenv`. Its directory must be in the
    PATH list there, not in a `.zshrc`-sourced file. See [Shell startup](concepts/shell.md).

??? info "An alias doesn't exist on some machine"
    Aliases for optional tools are only defined where the tool is installed
    (`(( $+commands[tool] ))`). Install the tool, or check `which <tool>`.

??? info "Shell startup got slow"
    `zsh -ixc exit 2>&1 | ts -i '%.s' | sort -rn | head` (`ts` is in
    `moreutils`), or temporarily add `zmodload zsh/zprof` at the top of
    `~/.zshrc` and `zprof` at the bottom. A stale cache rebuilds itself:
    `rm -rf ~/.cache/zsh`.

??? info "`GH_TOKEN` isn't set"
    `12-github-cli.zsh` reads `~/code/ai-sync/secrets/github-mcp-pat.txt`
    (or `$AI_CONFIG/secrets/…`). If ai-sync still lives at the old
    `~/.ai-config`, move it; see [Updating an existing machine](getting-started/existing-machines.md).

## Git

??? failure "Git ignores a setting in `~/.gitconfig.local`"
    Check it's really read: `git config --show-origin --get <key>`. The
    include is at the end of `~/.gitconfig`, so the local file wins for any key.
    A repo's own `.git/config` still wins over both.

??? warning "`git -C ~/dotfiles status` shows `git/.gitconfig` changed, and I didn't edit it"
    Something ran `git config --global …` or `gh auth setup-git`, which write
    to the tracked file. Move machine-specific lines to `~/.gitconfig.local`
    (`git config --file ~/.gitconfig.local …`) and `git checkout git/.gitconfig`.

## Neovim

??? info "No Treesitter highlighting"
    nvim-treesitter needs **Neovim 0.12+** and the `tree-sitter` CLI (the
    `tree-sitter-cli` formula) plus a C compiler. On older Neovim it's skipped
    on purpose. Check `nvim --version` and `which tree-sitter`, then `:TSUpdate`.

## QNAP (hyperion)

??? failure "No git status in the prompt"
    Run `qnap-gitstatus-fix`. It reports whether the gitstatus patch is applied
    and whether `~/bin/mkfifo` exists. See [QNAP quirks](getting-started/qnap.md#qnap-quirks).

??? info "SSH login stays in `sh`"
    `~/.profile` must hand off to zsh; see [the snippet](getting-started/qnap.md#3-login-shells-must-be-handed-to-zsh).

## Dev containers

??? failure "Container shell has no aliases or prompt"
    The config directories hold symlinks into `~/dotfiles`, so the repo must be
    mounted at `/root/dotfiles` (read-only is fine). See [Dev containers](getting-started/dev-containers.md).

??? info "Tools didn't install"
    Run `~/dotfiles/scripts/devcontainer-tools.sh` inside the container to see
    the errors. Each tool installs independently, and a marker file prevents
    re-runs, so delete `/usr/local/share/.devcontainer-tools-installed` to retry
    on the next shell.
