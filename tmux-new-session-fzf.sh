#!/usr/bin/env bash
# preview: パスと git の状態を見出しに出し、その下に tree で 2 階層まで表示する
if [ "$1" = "--preview" ]; then
  d="$2"
  [ -d "$d" ] || exit 0
  printf '\033[1;36m%s\033[0m\n' "${d/#$HOME/~}"
  if branch=$(git -C "$d" branch --show-current 2>/dev/null); then
    changes=$(git -C "$d" status --short 2>/dev/null | wc -l | tr -d ' ')
    printf '\033[33mbranch: %s\033[0m  (%s changes)\n' "${branch:-detached}" "$changes"
  fi
  echo
  tree -C -L 2 --dirsfirst --noreport -I 'node_modules|.git|vendor|__pycache__|.venv' "$d" | tail -n +2
  exit 0
fi

vim_binds=$(tmux show-environment -g FZF_VIM_BINDS 2>/dev/null | cut -d= -f2-)

# Enter: 新しい window / ctrl-h,j,k,l: 左,下,上,右に pane を分割
out=$(zoxide query -l 2>/dev/null |
  eval "fzf --reverse $vim_binds --expect=ctrl-h,ctrl-j,ctrl-k,ctrl-l --bind 'enter:accept-or-print-query' --preview '\"$0\" --preview {}' --preview-window=right,60%") || exit 0

# Normal modeで入ってwindowを起動したり、paneを開いたりをvim bindな感じで作るようにした
if [ "$(wc -l <<<"$out")" -ge 2 ]; then
  key=$(sed -n 1p <<<"$out")
  dir=$(sed -n 2p <<<"$out")
else
  key=""
  dir="$out"
fi
dir="${dir/#\~/$HOME}"
[ -d "$dir" ] || { tmux display-message "not a directory: $dir"; exit 1; }

case "$key" in
  ctrl-l) tmux split-window -h -c "$dir" ;;
  ctrl-h) tmux split-window -h -b -c "$dir" ;;
  ctrl-j) tmux split-window -v -c "$dir" ;;
  ctrl-k) tmux split-window -v -b -c "$dir" ;;
  *) tmux new-window -c "$dir" ;;
esac
