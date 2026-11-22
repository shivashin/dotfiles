#!/bin/sh
# ~/dotfiles のファイルへのシンボリックリンクを張る。何度実行してもよい。
# リンクを張る場所に実体のファイルがあれば、<名前>.bak.<日時> に退避してから張る。
set -eu

DOTFILES="$HOME/dotfiles"

link() {
  src="$DOTFILES/$1"
  dest="$2"
  mkdir -p "$(dirname "$dest")"

  if [ -L "$dest" ]; then
    # すでに正しいリンクなら何もしない。別の場所へのリンクは張り直す（中身は消えない）
    [ "$(readlink "$dest")" = "$src" ] && return 0
    rm "$dest"
  elif [ -e "$dest" ]; then
    backup="$dest.bak.$(date +%Y%m%d%H%M%S)"
    mv "$dest" "$backup"
    echo "退避しました: $dest -> $backup"
  fi

  ln -s "$src" "$dest"
  echo "リンクしました: $dest -> $src"
}

link .vimrc "$HOME/.vimrc"
link .zshrc "$HOME/.zshrc"
link .tmux.conf "$HOME/.tmux.conf"
link .latexmkrc "$HOME/.latexmkrc"
link .gitconfig "$HOME/.gitconfig"
link .Brewfile "$HOME/.Brewfile"
link mise/config.toml "$HOME/.config/mise/config.toml"
if [ "$(uname -s)" = "Linux" ]; then
  link mise/linux.toml "$HOME/.config/mise/conf.d/linux.toml"
fi
