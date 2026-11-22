#!/usr/bin/env bash
# .Brewfile の tap / formula / cask が、Homebrew でまだ配布されているかを確認する。インストールはしない。
#   - 存在しない（名前が変わった・削除された）、または無効（disabled）になっていれば失敗する
#   - 非推奨（deprecated）は警告だけ出す
# macOS 標準の bash 3.2 でも動くように書く（mapfile などは使わない）
set -euo pipefail

brewfile="${1:-.Brewfile}"
export HOMEBREW_NO_AUTO_UPDATE=1

list() {
  local kind="$1" line
  LIST=()
  while IFS= read -r line; do
    [ -n "$line" ] && LIST+=("$line")
  done < <(brew bundle list --file="$brewfile" "--$kind")
}

status=0
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# サードパーティの formula を調べるには tap が必要。tap できなければ失敗にする
list tap
for tap in "${LIST[@]+"${LIST[@]}"}"; do
  if ! brew tap "$tap" >/dev/null 2>&1; then
    echo "::error::tap できません: $tap"
    status=1
  fi
done

# 公式以外の tap の formula / cask は、信頼済みにしないと Homebrew が読み込まない。
# brew bundle と同じく、.Brewfile で trusted: true を付けたものだけを信頼済みにする
while IFS= read -r line; do
  if [[ "$line" =~ ^(brew|cask)\ \"([^\"]+)\".*trusted:\ true ]]; then
    kind=formula
    [ "${BASH_REMATCH[1]}" = cask ] && kind=cask
    brew trust "--$kind" "${BASH_REMATCH[2]}" >/dev/null
  fi
done <"$brewfile"

check() {
  local kind="$1" name
  list "$kind"
  echo "${kind}: ${#LIST[@]}"
  [ "${#LIST[@]}" -eq 0 ] && return 0

  if ! brew info --json=v2 "--$kind" "${LIST[@]}" >"$tmp/info.json" 2>/dev/null; then
    # 見つからないものがあると brew info 全体が失敗するので、1 つずつ調べ直して特定する
    for name in "${LIST[@]}"; do
      if ! brew info --json=v2 "--$kind" "$name" >/dev/null 2>"$tmp/err"; then
        echo "::error::読み込めません（${kind}）: $name: $(grep -m1 '^Error:' "$tmp/err" | sed 's/^Error: //')"
        status=1
      fi
    done
    return 0
  fi

  python3 - "$kind" "$tmp/info.json" <<'EOF' || status=1
import json, sys
kind, path = sys.argv[1], sys.argv[2]
data = json.load(open(path))
items = data["formulae"] if kind == "formula" else data["casks"]
failed = False
for item in items:
    name = item.get("full_name") or item.get("full_token") or item.get("token")
    if item.get("disabled"):
        print(f"::error::無効になっています（{kind}）: {name}（{item.get('disable_reason')}）")
        failed = True
    elif item.get("deprecated"):
        print(f"::warning::非推奨です（{kind}）: {name}（{item.get('deprecation_reason')}）")
sys.exit(1 if failed else 0)
EOF
}

check formula
check cask

if [ "$status" -eq 0 ]; then
  echo "すべての tap / formula / cask を確認しました"
fi
exit "$status"
