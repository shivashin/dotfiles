#!/bin/bash
# dpp toml プラグインの安全な更新スクリプト
#
# 使い方:
#   ./update_vim_plugin_versions.sh                    # 全プラグインをチェック（更新は確認付き）
#   ./update_vim_plugin_versions.sh -d 14             # 14日以上経過したもののみ
#   ./update_vim_plugin_versions.sh Shougo/ddc.vim    # 指定プラグインのみ
#   ./update_vim_plugin_versions.sh -d 7 Shougo/ddu.vim tpope/vim-surround

set -uo pipefail

MIN_AGE_DAYS=30
TOML_DIR="$HOME/dotfiles/tomls"
TARGETS=()

# 引数パース
while [[ $# -gt 0 ]]; do
  case "$1" in
    -d|--days) MIN_AGE_DAYS="$2"; shift 2 ;;
    *) TARGETS+=("$1"); shift ;;
  esac
done

now=$(date +%s)

# 安全性チェック: 差分の警告パターン
SUSPICIOUS_PATTERNS='curl |wget |eval |exec |system\(|\.sh|base64|nc |ncat '

check_safety() {
  local repo="$1" old_rev="$2" new_rev="$3"

  echo "  [安全性チェック]"

  # コミット数（双方向で確認）
  compare_json=$(curl -sf "https://api.github.com/repos/${repo}/compare/${old_rev}...${new_rev}")
  commit_count=$(echo "$compare_json" | grep '"total_commits"' | sed 's/[^0-9]//g')
  status=$(echo "$compare_json" | grep '"status"' | sed 's/.*: "//;s/".*//')

  if [[ "$status" == "behind" ]]; then
    # old_revがnew_revより先 → 逆方向で取得
    compare_json=$(curl -sf "https://api.github.com/repos/${repo}/compare/${new_rev}...${old_rev}")
    commit_count=$(echo "$compare_json" | grep '"total_commits"' | sed 's/[^0-9]//g')
    echo "    ⚠️  現在のrevは候補より新しい（ダウングレード）"
  fi

  if [[ -n "$commit_count" ]]; then
    if [[ "$commit_count" -gt 50 ]]; then
      echo "    ⚠️  コミット数: ${commit_count} (多い - 要確認)"
    else
      echo "    ✓ コミット数: ${commit_count}"
    fi
  fi

  # 差分に不審なパターンがないか
  diff_content=$(echo "$compare_json" | grep -i '"patch"' || true)
  suspicious=$(echo "$diff_content" | grep -iE "$SUSPICIOUS_PATTERNS" || true)
  if [[ -n "$suspicious" ]]; then
    echo "    ⚠️  不審なパターン検出: curl/eval/exec 等を含む変更あり"
  else
    echo "    ✓ 不審なパターンなし"
  fi

  # リポジトリのスター数
  stars=$(curl -sf "https://api.github.com/repos/${repo}" | grep '"stargazers_count"' | head -1 | sed 's/[^0-9]//g')
  if [[ -n "$stars" ]]; then
    if [[ "$stars" -lt 10 ]]; then
      echo "    ⚠️  Stars: ${stars} (少ない - メンテナンス状況を確認)"
    else
      echo "    ✓ Stars: ${stars}"
    fi
  fi

  echo "    📎 差分: https://github.com/${repo}/compare/${old_rev}...${new_rev}"

  # 差分をlessで表示
  printf "    差分を表示しますか? [y/N]: "
  read -r show_diff
  if [[ "$show_diff" =~ ^[Yy]$ ]]; then
    curl -sfL "https://github.com/${repo}/compare/${old_rev}...${new_rev}.patch" | less
  fi
}

update_plugin() {
  local repo="$1" toml="$2"

  # 最新安定タグを取得
  tags=$(git ls-remote --tags "https://github.com/${repo}.git" 2>/dev/null \
    | grep -v '\^{}' \
    | awk '{print $2}' \
    | sed 's|refs/tags/||' \
    | grep -vi '\(alpha\|beta\|rc\|pre\|dev\|snapshot\)' \
    | sort -rV || true)

  candidate=""
  for tag in $tags; do
    created=$(curl -sf "https://api.github.com/repos/${repo}/commits/refs/tags/${tag}" \
      | grep '"date"' | tail -1 | sed -n 's/.*"\([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\).*/\1/p')

    if [[ -z "$created" ]]; then
      continue
    fi

    tag_ts=$(date -j -f "%Y-%m-%d" "$created" +%s 2>/dev/null || date -d "$created" +%s 2>/dev/null)
    age_days=$(( (now - tag_ts) / 86400 ))

    if [[ $age_days -ge $MIN_AGE_DAYS ]]; then
      candidate="$tag"
      break
    fi
  done

  # 現在のrev（完全一致で取得）
  current=$(grep -A1 "repo.*${repo}'" "$toml" | grep "^rev" | head -1 | sed "s/.*= ['\"]//;s/['\"]//")
  if [[ -z "$current" ]]; then
    current=$(grep -A1 "repo.*${repo}\"" "$toml" | grep "^rev" | head -1 | sed "s/.*= ['\"]//;s/['\"]//")
  fi

  # ハイブリッド方式:
  # タグがない or ローカルがタグより先 → N日以上経過したHEADコミットを候補にする
  use_head=false
  if [[ -z "$candidate" ]]; then
    use_head=true
  elif [[ -n "$current" && -n "$candidate" ]]; then
    # ローカルがタグより先か確認
    compare_status=$(curl -sf "https://api.github.com/repos/${repo}/compare/${current}...${candidate}" \
      | grep '"status"' | sed 's/.*: "//;s/".*//')
    if [[ "$compare_status" == "behind" ]]; then
      use_head=true
    fi
  fi

  if [[ "$use_head" == true ]]; then
    # HEADのコミット日を確認してN日ルールを適用
    head_info=$(curl -sf "https://api.github.com/repos/${repo}/commits/HEAD")
    head_date=$(echo "$head_info" | grep '"date"' | tail -1 | sed -n 's/.*"\([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\).*/\1/p')
    head_hash=$(git ls-remote "https://github.com/${repo}.git" HEAD 2>/dev/null | awk '{print substr($1,1,7)}')

    if [[ -n "$head_date" ]]; then
      head_ts=$(date -j -f "%Y-%m-%d" "$head_date" +%s 2>/dev/null || date -d "$head_date" +%s 2>/dev/null)
      head_age=$(( (now - head_ts) / 86400 ))
      if [[ $head_age -ge $MIN_AGE_DAYS ]]; then
        candidate="$head_hash"
      else
        echo "  [$repo] HEAD (${head_hash}) は ${head_age}日前 (${MIN_AGE_DAYS}日未満) - スキップ"
        return
      fi
    else
      candidate="$head_hash"
    fi
  fi

  if [[ -z "$candidate" ]]; then
    echo "  [$repo] ${MIN_AGE_DAYS}日以上の候補なし - スキップ"
    return
  fi

  if [[ "$candidate" == "$current" ]]; then
    echo "  [$repo] $current (最新)"
    return
  fi

  echo "  [$repo] $current -> $candidate"

  # 安全性チェック
  if [[ -n "$current" ]]; then
    check_safety "$repo" "$current" "$candidate"
  fi

  # 確認プロンプト
  printf "  適用しますか? [y/N]: "
  read -r answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    sed -i.bak "/$(echo "$repo" | sed 's/\//\\\//g')/{ n; s/rev = .*/rev = '${candidate}'/; }" "$toml"
    echo "  ✓ 更新しました"
  else
    echo "  → スキップ"
  fi
}

# メイン処理
for toml in "$TOML_DIR"/*.toml; do
  repos=$(grep -n "^repo" "$toml" | sed "s/.*= ['\"]//;s/['\"]//")

  for repo in $repos; do
    # ターゲット指定がある場合はフィルタ
    if [[ ${#TARGETS[@]} -gt 0 ]]; then
      match=false
      for target in "${TARGETS[@]}"; do
        if [[ "$repo" == *"$target"* ]]; then
          match=true
          break
        fi
      done
      [[ "$match" == false ]] && continue
    fi

    update_plugin "$repo" "$toml"
  done
done

rm -f "$TOML_DIR"/*.bak
echo ""
echo "Done. Review: git diff tomls/"
