# New Mac

About 15 minutes, most of it Homebrew downloading.

## 1. Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

The installer asks you to add a line to `~/.zprofile`. You can skip that:
`install.sh` replaces `~/.zprofile`, and the new one already puts Homebrew on
PATH.

## 2. Clone the repo

```bash
git clone https://github.com/masonmem/dotfiles.git ~/dotfiles
```

HTTPS works before the machine has an SSH key. Once you've added a key to
GitHub, switch the remote so you can push:

```bash
git -C ~/dotfiles remote set-url origin git@github.com:masonmem/dotfiles.git
```

## 3. Run the installer

=== "Personal Mac"

    ```bash
    ~/dotfiles/install.sh personal
    ```

=== "Work Mac"

    ```bash
    ~/dotfiles/install.sh work
    ```

    This links and installs **only** the shared layer. Nothing from the
    `personal` or `ollama` packages is linked or installed. See
    [Keep work and personal apart](../how-to/work-machine.md).

What it does:

1. Writes `~/.config/dotfiles/packages` with the profile's packages (skipped if
   the file already exists).
2. Creates `~/.gitconfig.local` and `~/.ssh/config` from `templates/`, only if
   they don't exist. It also creates `~/.ssh/sockets` and `~/.nvm`.
3. Runs [`dotfiles-sync`](../concepts/sync.md) with `--backup-conflicts`. Any
   existing file that would block a link, such as the `~/.zprofile` Homebrew
   asked you to create, is renamed to `<file>.pre-dotfiles`. Nothing is deleted.

!!! tip "Safe to re-run"
    `install.sh` never overwrites the package list or your local files. Run it
    again at any time, for example after fixing a conflict it reported.

## 4. Finish the machine-specific bits

- [ ] **Git identity.** Edit `~/.gitconfig.local` and uncomment `[user]`. Git
  refuses to commit until you do, on purpose. On the work Mac, see
  [per-directory identity](../how-to/work-machine.md#git-identity).
- [ ] **SSH hosts.** Add hosts to the top of `~/.ssh/config`.
- [ ] **Agent config.** It lives in its own repo:
  ```bash
  git clone git@github.com:masonmem/ai-sync.git ~/code/ai-sync
  ~/code/ai-sync/install.sh          # work Mac: add --work
  ```
- [ ] **Personal Macs:** pull the LiteLLM keys with `litellm-keys pull`. See
  [Local LLM stack](../reference/llm-stack.md).
- [ ] **Terminal font:** pick *MesloLGS Nerd Font* (installed by the
  Brewfile), or the prompt icons show as boxes.
- [ ] Open a **new terminal**.

## 5. Check it worked

```bash
readlink ~/.zshrc                   # → dotfiles/zsh/.zshrc
cat ~/.config/dotfiles/packages     # the packages this Mac uses
sync-all                            # should finish with "done."
```

From now on, `sync-all` is all you run. See the
[Everyday workflow](../how-to/daily-workflow.md).
