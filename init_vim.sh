#!/usr/bin/env bash
# dpp.vim と denops.vim の本体を ~/.cache/dpp に clone する。すでにあるものはスキップする
set -euo pipefail

base="$HOME/.cache/dpp/repos/github.com"

shougo_items=(
  "dpp.vim"
  "dpp-ext-installer"
  "dpp-protocol-git"
  "dpp-ext-lazy"
  "dpp-ext-toml"
)

mkdir -p "$base/Shougo" "$base/vim-denops"

for item in "${shougo_items[@]}"; do
  if [ ! -d "$base/Shougo/$item" ]; then
    git clone "https://github.com/Shougo/$item" "$base/Shougo/$item"
  fi
done

if [ ! -d "$base/vim-denops/denops.vim" ]; then
  git clone https://github.com/vim-denops/denops.vim "$base/vim-denops/denops.vim"
fi
