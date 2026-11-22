##############
# plugin
##############
# sheldon（sheldon/plugins.toml）でプラグインを読み込む。未取得のプラグインがあれば自動で取得する
if (( $+commands[sheldon] )); then
  eval "$(sheldon source)"
fi
