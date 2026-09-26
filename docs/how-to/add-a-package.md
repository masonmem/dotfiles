# Add a package

Create a package when a tool has config worth tracking **and** you want to turn
it on per machine. For example: config for a tool only some machines use, or a
bundle of personal settings plus the software they need.

If the config should simply be on every machine, add it to an existing package
instead (usually `zsh` or the tool's own).

## Example: a `wezterm` package

1. **Create the folder**, laid out like `$HOME`:

    ```text
    dotfiles/wezterm/
    ├── .config/wezterm/wezterm.lua     → ~/.config/wezterm/wezterm.lua
    ├── Brewfile                        (not linked: installs the app)
    └── .stow-local-ignore              (not linked: says what not to link)
    ```

    ```bash
    mkdir -p ~/dotfiles/wezterm/.config/wezterm
    mv ~/.config/wezterm/wezterm.lua ~/dotfiles/wezterm/.config/wezterm/
    ```

2. **Optional: the software it needs.**

    ```ruby title="wezterm/Brewfile"
    # wezterm/Brewfile — installed on hosts that enable the wezterm package.
    cask "wezterm"
    ```

    Python CLIs go in `wezterm/pipx-tools.txt` ([format](../reference/brewfiles.md#pipx-lists)).

3. **If the package has any file that must not be linked** (a `Brewfile`,
   `pipx-tools.txt`, a README, server-only files), add `.stow-local-ignore`.
   It *replaces* stow's default ignore list, so include the basics:

    ```text title="wezterm/.stow-local-ignore"
    # Package metadata; not linked into $HOME.
    \.DS_Store
    ^/README\.md
    ^/Brewfile
    ^/pipx-tools\.txt
    ```

    With no files to exclude, skip this file; stow's defaults already ignore
    READMEs.

4. **Enable it on this machine** and sync:

    ```bash
    echo wezterm >> ~/.config/dotfiles/packages
    sync-all
    readlink ~/.config/wezterm/wezterm.lua     # → …/dotfiles/wezterm/…
    ```

5. **Decide which profiles include it.** To give new machines of a profile the
   package, add it to the profile's list in `install.sh`:

    ```bash title="install.sh"
    --8<-- "install.sh:profiles"
    ```

    Existing machines aren't affected; their package list is theirs. Every sync
    prints the packages a machine *doesn't* enable, so you'll be reminded on
    each one:

    ```text
    [dotfiles-sync] not enabled on this host: ollama wezterm (edit ~/.config/dotfiles/packages to change)
    ```

6. **Test, commit, push.** `tests/run` checks that nothing it shouldn't gets
   linked.

## Checklist

- [ ] Top-level folder, files at their `$HOME`-relative paths
- [ ] No secrets, hostnames or work details (the repo is public)
- [ ] `.stow-local-ignore` if it has a `Brewfile`, `pipx-tools.txt`, README or other non-home files
- [ ] Shell snippets guarded (`(( $+commands[tool] ))`) and numbered for load order
- [ ] Added to `install.sh` profiles if new machines should get it
- [ ] Enabled on the machines that should have it
- [ ] Documented: a row in [Packages and profiles](../concepts/packages.md#the-packages)

!!! note "Names that can't be packages"
    `bin`, `docs`, `scripts`, `templates`, `tests`, `Brewfile.d`, `site` and dot-folders
    are reserved and never linked.
