#!/bin/bash
# zsh プラグインの最新タグを確認し、sheldon/plugins.toml の tag を更新するスクリプト
# リリースからMIN_AGE_DAYS日以上経過したタグのみ対象とする

MIN_AGE_DAYS=${1:-30}
PLUGINS_TOML="$HOME/dotfiles/sheldon/plugins.toml"

plugins=(
  "zsh-users/zsh-syntax-highlighting"
  "zsh-users/zsh-completions"
  "zsh-users/zsh-autosuggestions"
)

now=$(date +%s)

for repo in "${plugins[@]}"; do
  # 全タグをバージョン順で取得（新しい順）、プレリリースは除外
  tags=$(git ls-remote --tags "https://github.com/${repo}.git" \
    | grep -v '\^{}' \
    | awk '{print $2}' \
    | sed 's|refs/tags/||' \
    | grep -vi '\(alpha\|beta\|rc\|pre\|dev\|snapshot\)' \
    | sort -rV)

  latest=""
  for tag in $tags; do
    # タグの作成日を GitHub API から取得
    tag_date=$(curl -sf "https://api.github.com/repos/${repo}/git/ref/tags/${tag}" \
      | grep -o '"url": "https://api.github.com/repos/.*/git/tags/[^"]*"' \
      | head -1 \
      | grep -o 'https://[^"]*')

    if [[ -n "$tag_date" ]]; then
      created=$(curl -sf "$tag_date" | grep '"date"' | head -1 | sed -n 's/.*"\([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\).*/\1/p')
    fi

    # annotated tag でない場合はコミット日を使う
    if [[ -z "$created" ]]; then
      created=$(curl -sf "https://api.github.com/repos/${repo}/commits/refs/tags/${tag}" \
        | grep '"date"' | tail -1 | sed -n 's/.*"\([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\).*/\1/p')
    fi

    if [[ -z "$created" ]]; then
      continue
    fi

    tag_ts=$(date -j -f "%Y-%m-%d" "$created" +%s 2>/dev/null || date -d "$created" +%s 2>/dev/null)
    age_days=$(( (now - tag_ts) / 86400 ))

    if [[ $age_days -ge $MIN_AGE_DAYS ]]; then
      latest="$tag"
      echo "[$repo] candidate: $tag (released ${age_days} days ago)"
      break
    else
      echo "[$repo] skipping $tag (only ${age_days} days old, need ${MIN_AGE_DAYS}+)"
    fi
  done

  if [[ -z "$latest" ]]; then
    echo "[$repo] no tag meets the ${MIN_AGE_DAYS}-day threshold"
    continue
  fi

  # github = "<repo>" の行のあとにある、最初の tag = "..." を対象にする
  current=$(awk -v repo="github = \"${repo}\"" '$0 == repo {found=1; next} found && /^tag = / {gsub(/^tag = "|"$/, ""); print; exit}' "$PLUGINS_TOML")

  if [[ -z "$current" ]]; then
    echo "[$repo] not found in $PLUGINS_TOML"
  elif [[ "$latest" != "$current" ]]; then
    echo "[$repo] updating: $current -> $latest"
    sed -i.bak "\|^github = \"${repo}\"\$|,\|^tag = |s|^tag = \".*\"\$|tag = \"${latest}\"|" "$PLUGINS_TOML"
  else
    echo "[$repo] $current (up to date)"
  fi
done

rm -f "${PLUGINS_TOML}.bak"
echo ""
echo "Done. Review changes: git diff sheldon/plugins.toml"
echo "Then run: sheldon lock --update"
