#!/bin/sh
ln -sf ~/dotfiles/.vimrc ~/.vimrc
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.tmux.conf ~/.tmux.conf
ln -sf ~/dotfiles/.latexmkrc ~/.latexmkrc
ln -sf ~/dotfiles/.gitconfig ~/.gitconfig
ln -sf ~/dotfiles/.Brewfile ~/.Brewfile
mkdir -p ~/.config/mise
ln -sf ~/dotfiles/mise/config.toml ~/.config/mise/config.toml
if [ "$(uname -s)" = "Linux" ]; then
  mkdir -p ~/.config/mise/conf.d
  ln -sf ~/dotfiles/mise/linux.toml ~/.config/mise/conf.d/linux.toml
fi
