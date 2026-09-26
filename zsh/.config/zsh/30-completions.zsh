# Completions. Most come from Homebrew's site-functions (fpath in ~/.zshrc).
#
# kubectl ships with Docker Desktop rather than Homebrew, so its completion is
# generated into the cache (on fpath via ~/.zshrc) and refreshed whenever the
# kubectl binary is newer. It is used from the next shell onwards.
if (( $+commands[kubectl] )); then
  _kubectl_comp="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completions/_kubectl"
  if [[ ! -s "$_kubectl_comp" || "$commands[kubectl]" -nt "$_kubectl_comp" ]]; then
    mkdir -p "${_kubectl_comp:h}"
    kubectl completion zsh >| "$_kubectl_comp" 2>/dev/null || rm -f "$_kubectl_comp"
  fi
  unset _kubectl_comp
  compdef kubecolor=kubectl 2>/dev/null   # kubecolor wraps kubectl
fi
