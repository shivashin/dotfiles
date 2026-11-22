############
# 補間関連
############
fpath=(~/.zsh/completion $fpath)
## 補完機能の有効
autoload -U compinit
compinit

## TAB で順に補完候補を切り替える
setopt auto_menu
## サスペンド中のプロセスと同じコマンド名を実行した場合はリジューム
setopt auto_resume
## 補完候補を一覧表示
setopt auto_list
## カッコの対応などを自動的に補完
setopt auto_param_keys
## ディレクトリ名の補完で末尾の / を自動的に付加し、次の補完に備える
setopt auto_param_slash
## 補完候補の色づけ
if (( $+commands[gdircolors] )); then
  eval "$(gdircolors -b)"
elif (( $+commands[dircolors] )); then
  eval "$(dircolors -b)"
fi
export ZLS_COLORS=$LS_COLORS
zstyle ':completion:*:default' menu select=2
zstyle ':completion:*' verbose yes
zstyle ':completion:*' completer _expand _complete _match _prefix _approximate _list _history
zstyle ':completion:*:messages' format '%F{YELLOW}%d'$DEFAULT
zstyle ':completion:*:warnings' format '%F{RED}No matches for:''%F{YELLOW} %d'$DEFAULT
zstyle ':completion:*:descriptions' format '%F{YELLOW}completing %B%d%b'$DEFAULT
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:descriptions' format '%F{yellow}Completing %B%d%b%f'$DEFAULT
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-separator '-->'
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
## 補完候補一覧でファイルの種別をマーク表示
setopt list_types
## 補完候補を詰めて表示
setopt list_packed
## 補完で小文字でも大文字でもマッチさせる
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
