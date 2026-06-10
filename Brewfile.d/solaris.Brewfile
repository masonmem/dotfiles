# Brewfile.d/solaris.Brewfile — solaris (Mac Mini, always-on server) extras.
#
# Installed by dotfiles-sync IN ADDITION to the shared Brewfile when
# `hostname -s` (lowercased) is "solaris". Server-role packages only —
# nothing here should be wanted on a laptop or work machine.
# See README § Brewfile workflow.

tap "moghtech/komodo"
tap "mikescher/tap"

brew "moghtech/komodo/periphery"           # Komodo agent — deploys every homelab stack on solaris
brew "node_exporter"                       # Prometheus host metrics exporter
brew "glances"                             # system monitoring (TUI + web UI)
brew "mikescher/tap/dops"                  # nicer `docker ps` output for stack triage
