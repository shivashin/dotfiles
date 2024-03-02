#!/bin/bash

if [ "$OSTYPE" == "darwin"* ]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  brew install git
elif [ "$OSTYPE" == "linux-gnu"* ]; then
  apt-get install git -y
fi

# For vim plugin
mkdir -p ~/.vim/bundle
git clone https://github.com/Shougo/neobundle.vim.git ~/.vim/bundle/neobundle.vim

# MEMO: https://dev.macha795.com/zsh-prompt-customize/
# For git completetion
mkdir -p ~/.zsh/completion/
curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.zsh -o ~/.zsh/completion/git-completion.zsh
curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh -o ~/.zsh/completion/git-prompt.sh
chmod a+x ~/.zsh/completion/git-prompt.sh
chmod a+x ~/.zsh/completion/git-completion.zsh
mv ~/.zsh/completion/git-completion.zsh ~/.zsh/completion/_git
rm -f ~/.zcompdump

# fonts
git clone https://github.com/powerline/fonts ~/
cd fonts
./install.sh
fc-cache -vf
## After this section, you need to modify terminal font

if [ "$OSTYPE" == "darwin"* ]; then
  cp .Brewfile ~
  mv .Brewfile Brewfile
  brew bundle
fi
