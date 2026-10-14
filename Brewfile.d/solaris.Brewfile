# Brewfile.d/solaris.Brewfile — solaris (Mac mini, always-on server) only.
# Server-role packages; nothing here should be wanted on a laptop.
#
#   brew bundle --file ~/dotfiles/Brewfile.d/solaris.Brewfile

tap "moghtech/komodo", trusted: { formula: "periphery" }
tap "mikescher/tap", trusted: { formula: "dops" }

brew "moghtech/komodo/periphery"           # Komodo agent — deploys every homelab stack on solaris
brew "node_exporter"                       # Prometheus host metrics exporter
brew "glances"                             # system monitoring (TUI + web UI)
brew "mikescher/tap/dops"                  # nicer `docker ps` output for stack triage
