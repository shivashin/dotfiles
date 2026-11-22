#!/usr/bin/env bash
# Linux のコンテナの中で setup.sh を確認する。root で実行し、dotfiles は /src に読み取り専用でマウントする。
#   docker run --rm -v "$PWD":/src:ro ubuntu:24.04 bash /src/.github/scripts/test-setup-linux.sh
#
# sudo を使う一般ユーザーで setup.sh を 2 回実行し、次のことを確認する。
#   - 2 回とも成功する（何度実行してもよい）
#   - zsh と tmux がエラーを出さずに起動する
#   - mise で入れたツールが使える
set -euo pipefail

TEST_USER=dev

echo "::group::テスト用ユーザーの作成"
if command -v apt-get >/dev/null; then
  apt-get update -qq
  DEBIAN_FRONTEND=noninteractive apt-get install -y -qq sudo >/dev/null
else
  # Amazon Linux 2023 のコンテナには useradd と su が入っていない
  dnf install -y -q sudo shadow-utils util-linux >/dev/null
fi
useradd -m -s /bin/bash "$TEST_USER"
echo "$TEST_USER ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$TEST_USER"
echo "::endgroup::"

# su - は環境変数を引き継がないので、TERM を渡す
run_as_user() {
  su - "$TEST_USER" -c "export TERM=xterm-256color; $1"
}

run_as_user 'cp -a /src ~/dotfiles'

for i in 1 2; do
  echo "::group::setup.sh（${i} 回目）"
  run_as_user 'cd && dotfiles/setup.sh'
  echo "::endgroup::"
done

echo "::group::zsh の起動"
# 対話シェルとして起動し、標準エラー出力に何も出ないことを確認する
run_as_user 'cd ~ && zsh -i -c "exit 0" </dev/null 2>/tmp/zsh.err >/dev/null'
if [ -s /tmp/zsh.err ]; then
  echo "zsh の起動時にエラーが出ました:"
  cat /tmp/zsh.err
  exit 1
fi
echo "ok"
echo "::endgroup::"

echo "::group::tmux の起動"
run_as_user 'tmux -f ~/.tmux.conf new-session -d -s ci && sleep 2 && tmux show -sv set-clipboard && tmux kill-server'
echo "::endgroup::"

echo "::group::mise で入れたツール"
# $c などはテスト用ユーザーの zsh で展開させるので、シングルクォートのままにする
# shellcheck disable=SC2016
run_as_user 'cd ~ && zsh -i -c "
  set -e
  for c in mise fzf rg zoxide uv deno gitleaks sheldon ruby node python3 terraform cfn-lint onelogin-aws-login; do
    printf \"%-20s %s\n\" \$c \"\$(command -v \$c)\"
  done
  terraform version | head -1
  cfn-lint --version
  onelogin-aws-login --help >/dev/null 2>&1
" </dev/null 2>/dev/null'
echo "::endgroup::"

echo "::group::Git フック"
run_as_user 'git -C ~/dotfiles config core.hooksPath | grep -qx .githooks && echo "core.hooksPath=.githooks"'
echo "::endgroup::"

echo "すべての確認が通りました"
