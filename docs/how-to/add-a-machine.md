# Add a machine or host-only setup

## A brand-new machine

Follow [Getting started](../getting-started/index.md). Nothing in the repo
needs to change for a new machine, unless it needs software no other machine
has.

## Software only one machine gets

For example, solaris runs the Komodo agent and a metrics exporter that no
laptop should have.

1. Find the host name sync uses. It prints it:

    ```bash
    dotfiles-sync | grep 'host:'        # [dotfiles-sync] host: solaris
    ```

    It's the Mac's configured name (`scutil --get HostName`, falling back to
    `LocalHostName`; on Linux, `hostname -s`), lowercased.

2. Create `Brewfile.d/<host>.Brewfile`:

    ```ruby title="Brewfile.d/solaris.Brewfile"
    --8<-- "Brewfile.d/solaris.Brewfile"
    ```

3. Commit and push. That machine installs it on its next sync; no other
   machine does.

!!! question "Host file or package?"
    Use a **host Brewfile** for software tied to one machine's role (a server
    daemon). Use a **[package](add-a-package.md)** when it's config plus
    software that several machines might turn on.

## Shell tweaks for one machine

Private, per-host shell settings go in `~/.config/zsh/90-<host>.zsh`. It isn't
tracked, and loads last so it can override anything:

```bash
cp ~/dotfiles/templates/zsh-host.zsh ~/.config/zsh/90-$(hostname -s).zsh
```

The template has examples for solaris (auto-attach tmux over SSH), the work Mac
and hyperion. Settings that must exist before oh-my-zsh / p10k load
(`ZSH_THEME`, `POWERLEVEL9K_*`) go in `~/.zshrc.early.local` instead.

## Change a machine's profile

Edit its package list, then sync:

```bash
nvim ~/.config/dotfiles/packages
sync-all
```

Adding a package links it and installs its software. **Removing** one needs an
extra step; see [Remove things](remove-things.md#stop-using-a-package-on-a-machine).

## Record the machine

Add a row to the machines table in [Packages and profiles](../concepts/packages.md)
and in the README, so it's clear what each machine runs.
