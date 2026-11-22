#!/usr/bin/env bash
# dotfiles のセットアップ。macOS（Homebrew）と Linux（apt / dnf）に対応する。
# 何度実行してもよい。すでに入っているものはスキップする。
#
# 使い方:
#   git clone https://github.com/shivashin/dotfiles.git ~/dotfiles
#   ~/dotfiles/setup.sh
set -euo pipefail

DOTFILES="$HOME/dotfiles"

log() { printf '\033[1;34m==> %s\033[0m\n' "$*"; }
skip() { printf '    %s（スキップ）\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

if [[ "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" != "$(cd "$DOTFILES" 2>/dev/null && pwd -P)" ]]; then
  echo "dotfiles を $DOTFILES に clone してから実行してください" >&2
  exit 1
fi

# root で実行しているときは sudo を使わない
if [[ "$(id -u)" -eq 0 ]]; then SUDO=(); else SUDO=(sudo); fi

# ---------------------------------------------------------------- macOS
setup_macos() {
  log "Homebrew"
  if ! have brew && [[ ! -x /opt/homebrew/bin/brew ]]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    skip "Homebrew は入っています"
  fi
  eval "$(/opt/homebrew/bin/brew shellenv)"

  log "シンボリックリンク"
  sh "$DOTFILES/dotfileslink.sh"

  log "Homebrew のパッケージ（~/.Brewfile）"
  # 入っていないものだけを入れる。既存のパッケージはアップグレードしない
  brew bundle --global --no-upgrade

  log "Powerline フォント"
  if compgen -G "$HOME/Library/Fonts/*Powerline*" >/dev/null; then
    skip "Powerline フォントは入っています"
  else
    local tmp
    tmp="$(mktemp -d)"
    git clone --depth 1 https://github.com/powerline/fonts.git "$tmp/fonts"
    "$tmp/fonts/install.sh"
    rm -rf "$tmp"
    echo "    ターミナルのフォントを Powerline 対応のもの（例: DejaVu Sans Mono for Powerline）に変えてください"
  fi
}

# ---------------------------------------------------------------- Linux
setup_linux() {
  log "パッケージ"
  if have apt-get; then
    "${SUDO[@]}" apt-get update
    "${SUDO[@]}" apt-get install -y git zsh tmux vim curl tree unzip ca-certificates
  elif have dnf; then
    # Amazon Linux 2023 は curl-minimal が入っていて、curl を入れると衝突するので入れない
    local pkgs=(git zsh tmux vim-enhanced tree unzip tar util-linux-user)
    have curl || pkgs+=(curl)
    "${SUDO[@]}" dnf install -y "${pkgs[@]}"
  else
    echo "apt-get / dnf が見つかりません" >&2
    exit 1
  fi

  log "シンボリックリンク"
  sh "$DOTFILES/dotfileslink.sh"

  log "mise"
  if have mise || [[ -x "$HOME/.local/bin/mise" ]]; then
    skip "mise は入っています"
  else
    curl -fsSL https://mise.run | sh
  fi
  export PATH="$HOME/.local/bin:$PATH"
}

# ---------------------------------------------------------------- 共通
setup_common() {
  log "mise のツール"
  mise trust --quiet "$DOTFILES/mise/config.toml"
  [[ -f "$HOME/.config/mise/conf.d/linux.toml" ]] && mise trust --quiet "$DOTFILES/mise/linux.toml"
  # pipx: のツールは uv で入れるので、uv を先に用意する（macOS は Homebrew の uv を使う）
  have uv || mise install uv
  mise install

  log "zsh のプラグイン（sheldon）"
  # sheldon は macOS では Homebrew、Linux では mise で入る。mise exec を通すとどちらでも見つかる
  mise exec -- sheldon lock

  log "tmux のプラグイン（tmux/plugins.lock のコミットに固定）"
  bash "$DOTFILES/tmux-plugins.sh" install

  log "Vim のプラグインマネージャ（dpp.vim / denops.vim）"
  bash "$DOTFILES/init_vim.sh"

  log "dotfiles の Git フック（gitleaks による秘密情報のチェック）"
  git -C "$DOTFILES" config core.hooksPath .githooks

  if [[ "$(basename "${SHELL:-}")" != "zsh" ]]; then
    echo
    echo "ログインシェルが zsh ではありません。必要なら次を実行してください:"
    echo "  chsh -s \"$(command -v zsh)\""
  fi

  if [[ ! -f "$HOME/.gitconfig.local" ]]; then
    echo
    echo "$HOME/.gitconfig.local がありません。普段使う Git の名前とアドレスを書いてください（dotfiles には入れない）:"
    echo "  git config --file ~/.gitconfig.local user.name  \"<名前>\""
    echo "  git config --file ~/.gitconfig.local user.email \"<アドレス>\""
  fi

  echo
  echo "残りの手順:"
  echo "  - Vim で :call dpp#async_ext_action('installer', 'install') を実行する"
}

case "$(uname -s)" in
  Darwin) setup_macos ;;
  Linux) setup_linux ;;
  *) echo "未対応の OS です: $(uname -s)" >&2; exit 1 ;;
esac
setup_common
log "完了"
