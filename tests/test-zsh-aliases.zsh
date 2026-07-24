#!/usr/bin/env zsh
set -eu

repo=${0:A:h:h}
aliases_file="$repo/zsh/.config/zsh/20-aliases.zsh"

container_ls=$(
  DEVCONTAINER=1 zsh -dfc \
    "source ${(q)aliases_file}; alias ls 2>/dev/null || print -- '<unalias>'"
)

if [[ "$container_ls" != "<unalias>" ]]; then
  print -u2 -- "expected native ls in a dev container, got: $container_ls"
  exit 1
fi

print -- "zsh alias policy: ok"
