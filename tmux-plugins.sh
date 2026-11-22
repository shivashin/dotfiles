#!/usr/bin/env bash
# tmux のプラグインを、tmux/plugins.lock に書いたコミットに固定して管理する。
# tpm はプラグインの読み込みだけに使い、インストールと更新はこのスクリプトで行う
# （tpm はコミットを指定してインストールできないため）。
#
# 使い方:
#   tmux-plugins.sh install            # plugins.lock のとおりに ~/.tmux/plugins に入れる（何度実行してもよい）
#   tmux-plugins.sh update [-d 日数]   # 公開から指定日数（既定 30 日）以上たった最新のコミットに plugins.lock を更新する
#   tmux-plugins.sh check              # .tmux.conf の @tpm_plugins と plugins.lock が一致するか確認する
#
# macOS 標準の bash 3.2 でも動くように書く（連想配列や mapfile は使わない）
set -euo pipefail

# CI などで別の場所にあるときは DOTFILES で指定する
DOTFILES="${DOTFILES:-$HOME/dotfiles}"
LOCK="$DOTFILES/tmux/plugins.lock"
TMUX_CONF="$DOTFILES/.tmux.conf"
PLUGIN_DIR="$HOME/.tmux/plugins"

# 差分に含まれていたら注意を出すパターン
SUSPICIOUS_PATTERNS='curl |wget |eval |base64|nc |ncat |/dev/tcp'

# plugins.lock から「owner/repo コミット」の行だけを出す
lock_entries() {
  grep -v -E '^[[:space:]]*(#|$)' "$LOCK"
}

# .tmux.conf の @tpm_plugins に書かれた owner/repo を出す
conf_plugins() {
  sed -n "/@tpm_plugins '/,/^'/p" "$TMUX_CONF" | grep -o -E '[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+'
}

cmd_install() {
  mkdir -p "$PLUGIN_DIR"
  local repo rev dir current
  while read -r repo rev; do
    dir="$PLUGIN_DIR/${repo##*/}"
    if [ ! -d "$dir/.git" ]; then
      echo "インストール: $repo @ ${rev:0:12}"
      git clone --quiet "https://github.com/$repo.git" "$dir"
    fi
    current="$(git -C "$dir" rev-parse HEAD)"
    if [ "$current" != "$rev" ]; then
      if [ -n "$(git -C "$dir" status --porcelain --ignore-submodules)" ]; then
        echo "変更があるので切り替えません: $dir（中身を確認してください）" >&2
        exit 1
      fi
      git -C "$dir" cat-file -e "$rev^{commit}" 2>/dev/null || git -C "$dir" fetch --quiet origin
      git -C "$dir" -c advice.detachedHead=false checkout --quiet "$rev"
      echo "切り替え: $repo ${current:0:12} -> ${rev:0:12}"
    fi
    if [ -f "$dir/.gitmodules" ]; then
      git -C "$dir" submodule update --quiet --init --recursive
    fi
  done < <(lock_entries)
  echo "tmux のプラグインは plugins.lock のとおりです"
}

cmd_update() {
  local days=30
  if [ "${1:-}" = "-d" ]; then
    days="${2:?日数を指定してください}"
  fi
  # 先に今の plugins.lock のとおりに入れておく（比較に使うため）
  cmd_install >/dev/null

  local repo rev dir new count changed=0
  TMP_LOCK="$(mktemp)"
  trap 'rm -f "$TMP_LOCK" "$TMP_LOCK.new"' EXIT
  cp "$LOCK" "$TMP_LOCK"
  while read -r repo rev; do
    dir="$PLUGIN_DIR/${repo##*/}"
    git -C "$dir" fetch --quiet origin
    # tpm で clone したものなどで origin/HEAD がなければ、リモートから設定する
    git -C "$dir" rev-parse --verify --quiet origin/HEAD >/dev/null || git -C "$dir" remote set-head origin --auto >/dev/null
    # 既定のブランチで、公開（コミット）から days 日以上たった最新のコミット
    new="$(git -C "$dir" log -1 --format=%H --before="$days days ago" origin/HEAD)"
    if [ -z "$new" ] || [ "$new" = "$rev" ]; then
      echo "[$repo] 更新なし"
      continue
    fi
    if ! git -C "$dir" merge-base --is-ancestor "$rev" "$new"; then
      echo "[$repo] 候補 ${new:0:12} は今のコミットより古いか、別の系統なので更新しません"
      continue
    fi
    count="$(git -C "$dir" rev-list --count "$rev..$new")"
    echo "[$repo] ${rev:0:12} -> ${new:0:12}（${count} コミット）"
    git -C "$dir" log --format='    %ad %s' --date=short "$rev..$new" | head -20
    if git -C "$dir" diff "$rev" "$new" | grep '^+' | grep -q -i -E "$SUSPICIOUS_PATTERNS"; then
      echo "    ⚠ 追加された行に curl / eval などが含まれます。差分を確認してください"
    fi
    echo "    差分: https://github.com/$repo/compare/$rev...$new"
    sed "s|^$repo $rev\$|$repo $new|" "$TMP_LOCK" >"$TMP_LOCK.new" && mv "$TMP_LOCK.new" "$TMP_LOCK"
    changed=1
  done < <(lock_entries)

  if [ "$changed" -eq 1 ]; then
    cp "$TMP_LOCK" "$LOCK"
    echo
    echo "plugins.lock を更新しました。git diff tmux/plugins.lock で確認し、$0 install で反映してください"
  fi
}

cmd_check() {
  local lock conf
  lock="$(lock_entries | awk '{print $1}' | sort)"
  conf="$(conf_plugins | sort)"
  if [ "$lock" != "$conf" ]; then
    echo ".tmux.conf の @tpm_plugins と tmux/plugins.lock が一致しません" >&2
    diff <(echo "$conf") <(echo "$lock") | sed 's/^</  .tmux.conf だけ:/; s/^>/  plugins.lock だけ:/' | grep -E 'だけ' >&2
    exit 1
  fi
  if lock_entries | awk '$2 !~ /^[0-9a-f]{40}$/ {bad=1} END {exit !bad}'; then
    echo "plugins.lock に 40 桁のコミット SHA でない行があります" >&2
    exit 1
  fi
  echo ".tmux.conf と plugins.lock は一致しています（$(echo "$lock" | wc -l | tr -d ' ') 個）"
}

case "${1:-}" in
  install) cmd_install ;;
  update) shift; cmd_update "$@" ;;
  check) cmd_check ;;
  *)
    sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'
    exit 1
    ;;
esac
