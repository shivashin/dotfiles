# 環境変数と PATH

## 言語（プロンプトの記号を出すため UTF-8 にする。日本語ロケールがない Linux では C.UTF-8 を使う）
if locale -a 2>/dev/null | grep -qiE '^ja_JP\.utf-?8$'; then
  export LANG=ja_JP.UTF-8
else
  export LANG=C.UTF-8
fi

## ruby warning ignore only using ruby version over 2.7
#export RUBYOPT='-W:no-deprecated -W:no-experimental'
## less hilight
export LESS='-R'

## OS ごとの設定
case "$OSTYPE" in
  darwin*)
    # Homebrew（Apple Silicon）
    eval "$(/opt/homebrew/bin/brew shellenv)"
    export PATH="$HOMEBREW_PREFIX/opt/mysql@8.0/bin:$PATH"
    export LESSOPEN="| $HOMEBREW_PREFIX/bin/src-hilite-lesspipe.sh %s"
    ;;
  linux*)
    # setup.sh が mise を ~/.local/bin に入れる
    export PATH="$HOME/.local/bin:$PATH"
    ;;
esac
## bootsnap setting
export ENABLE_BOOTSNAP=1
## spring setting
export DISABLE_SPRING=1
## 256 色を使う
export TERM=xterm-256color
