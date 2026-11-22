##############
# plugin
##############
# sheldon（sheldon/plugins.toml）でプラグインを読み込む。未取得のプラグインがあれば自動で取得する
if (( $+commands[sheldon] )); then
  eval "$(sheldon source)"
fi

## zsh-history-substring-search: 入力した文字を含む履歴を、挿入モードでは ↑ / ↓、ノーマルモードでは k / j でたどる
if (( $+widgets[history-substring-search-up] )); then
  bindkey -M viins '^[[A' history-substring-search-up
  bindkey -M viins '^[[B' history-substring-search-down
  bindkey -M viins "$terminfo[kcuu1]" history-substring-search-up
  bindkey -M viins "$terminfo[kcud1]" history-substring-search-down
  bindkey -M vicmd 'k' history-substring-search-up
  bindkey -M vicmd 'j' history-substring-search-down
fi
