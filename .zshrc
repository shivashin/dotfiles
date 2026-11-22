# Added by Kiro CLI
case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) export PATH="${PATH:+$PATH:}$HOME/.local/bin" ;; esac
# zsh の設定は ~/dotfiles/zsh/ に役割ごとに分けてあり、ファイル名の順に読み込む
for _zshrc_file in ~/dotfiles/zsh/*.zsh(N); do
  source "$_zshrc_file"
done
unset _zshrc_file
