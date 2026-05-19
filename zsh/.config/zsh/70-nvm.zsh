# Lazy NVM — defers the ~300-600ms nvm.sh load until first use of node/npm/etc.
# NVM_DIR is exported in 10-env.zsh.

_nvm_lazy_load() {
  # Remove stubs so subsequent calls go to the real binaries/functions
  unfunction nvm node npm npx yarn pnpm 2>/dev/null
  [[ -s "/opt/homebrew/opt/nvm/nvm.sh" ]] && source "/opt/homebrew/opt/nvm/nvm.sh"
}

nvm()  { _nvm_lazy_load; nvm  "$@" }
node() { _nvm_lazy_load; node "$@" }
npm()  { _nvm_lazy_load; npm  "$@" }
npx()  { _nvm_lazy_load; npx  "$@" }
yarn() { _nvm_lazy_load; yarn "$@" }
pnpm() { _nvm_lazy_load; pnpm "$@" }
