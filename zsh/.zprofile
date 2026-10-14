# ~/.zprofile — login shells only.
#
# On macOS, /etc/zprofile runs path_helper after ~/.zshenv, moving the system
# directories ahead of ours (so /usr/bin/git would beat Homebrew's). Re-apply
# our PATH order. Harmless elsewhere: .zshenv is idempotent.
source "$HOME/.zshenv"
