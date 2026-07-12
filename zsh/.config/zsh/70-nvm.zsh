# Lazy NVM — defers the ~300-600ms nvm.sh load until first use of node/npm/etc.
# NVM_DIR is exported in 10-env.zsh.
#
# Each stub is self-contained: it removes all stubs, sources nvm.sh, then
# re-dispatches. Deliberately NO shared _helper function — agent/CI shell
# snapshots (Claude Code and friends) drop underscore-prefixed functions
# while keeping the stubs, which made every stub recurse to FUNCNEST
# ("command not found: _nvm_lazy_load", then pnpm → pnpm → …) in any
# non-interactive shell.

nvm()  { unfunction nvm node npm npx yarn pnpm 2>/dev/null; [[ -s "/opt/homebrew/opt/nvm/nvm.sh" ]] && source "/opt/homebrew/opt/nvm/nvm.sh"; nvm  "$@" }
node() { unfunction nvm node npm npx yarn pnpm 2>/dev/null; [[ -s "/opt/homebrew/opt/nvm/nvm.sh" ]] && source "/opt/homebrew/opt/nvm/nvm.sh"; node "$@" }
npm()  { unfunction nvm node npm npx yarn pnpm 2>/dev/null; [[ -s "/opt/homebrew/opt/nvm/nvm.sh" ]] && source "/opt/homebrew/opt/nvm/nvm.sh"; npm  "$@" }
npx()  { unfunction nvm node npm npx yarn pnpm 2>/dev/null; [[ -s "/opt/homebrew/opt/nvm/nvm.sh" ]] && source "/opt/homebrew/opt/nvm/nvm.sh"; npx  "$@" }
yarn() { unfunction nvm node npm npx yarn pnpm 2>/dev/null; [[ -s "/opt/homebrew/opt/nvm/nvm.sh" ]] && source "/opt/homebrew/opt/nvm/nvm.sh"; yarn "$@" }
pnpm() { unfunction nvm node npm npx yarn pnpm 2>/dev/null; [[ -s "/opt/homebrew/opt/nvm/nvm.sh" ]] && source "/opt/homebrew/opt/nvm/nvm.sh"; pnpm "$@" }
