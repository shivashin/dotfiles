mkdir -p ~/.zsh/completion/
curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.zsh -o ~/.zsh/completion/git-completion.zsh
curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh -o ~/.zsh/completion/git-prompt.sh
chmod a+x ~/.zsh/completion/git-prompt.sh
chmod a+x ~/.zsh/completion/git-completion.zsh
mv ~/.zsh/completion/git-completion.zsh ~/.zsh/completion/_git
rm -f ~/.zcompdump
git clone https://github.com/powerline/fonts ~/
pushd fonts
./install.sh
popd
fc-cache -vf
# change font DejaVu Sans Mono Powerline
