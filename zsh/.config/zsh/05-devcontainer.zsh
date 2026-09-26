# Dev containers (DEVCONTAINER=1): install the CLI tools once per container
# and apply the work-safe AI config layer. Expects the host's ~/dotfiles to be
# mounted at ~/dotfiles — see README § Dev containers.
[[ -z "${DEVCONTAINER:-}" ]] && return

_dc_stamp="/usr/local/share/.devcontainer-tools-installed"
if [[ ! -f "$_dc_stamp" && -x "$HOME/dotfiles/scripts/devcontainer-tools.sh" ]]; then
  print "⏳ Installing shell tools (first run)..."
  if TOOL_CACHE="/var/cache/devcontainer-tools" "$HOME/dotfiles/scripts/devcontainer-tools.sh" &>/dev/null; then
    touch "$_dc_stamp" && print "✓ Done"
  else
    print -u2 "✗ Some tools failed to install; re-run $HOME/dotfiles/scripts/devcontainer-tools.sh to see why."
  fi
fi

# Apply only the portable/work-safe ai-sync layer, and only when the repo has
# been cloned into this container. Never install home-only skills here.
_ai_sync="${AI_CONFIG:-$HOME/code/ai-sync}"
_ai_stamp="$HOME/.local/share/ai-sync/.container-installed"
if [[ -x "$_ai_sync/install.sh" && ! -f "$_ai_stamp" ]]; then
  print "⏳ Installing portable AI configuration..."
  mkdir -p "${_ai_stamp:h}"
  "$_ai_sync/install.sh" --work --container && touch "$_ai_stamp" && print "✓ Done"
fi

[[ -x "$HOME/dotfiles/bin/configure-vscode-ai" ]] \
  && "$HOME/dotfiles/bin/configure-vscode-ai" --container &>/dev/null
unset _dc_stamp _ai_sync _ai_stamp
