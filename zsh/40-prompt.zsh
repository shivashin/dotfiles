##################
# プロンプト関連
##################
# 色有効
autoload -U colors
colors

## 色を使う
export CLICOLOR=1
# 色を定義
local GREEN=$'%{\e[1;32m%}'
local BLUE=$'%{\e[1;34m%}'
local DEFAULT=$'%{\e[1;m%}'

# git ブランチ名を色付きで表示させるメソッド
function git-current-branch {
  local branch_name st branch_status

  branch='\ue0a0'
  color='%{\e[38;5;' #  文字色を設定
  green='114m%}'
  red='001m%}'
  yellow='227m%}'
  blue='033m%}'
  reset='%{\e[0m%}'   # reset

  color='%{\e[38;5;' #  文字色を設定
  green='114m%}'

  # ブランチマーク
  if [ ! -e  ".git" ]; then
    # git 管理されていないディレクトリは何も返さない
    return
  fi

  branch_name=`git rev-parse --abbrev-ref HEAD 2> /dev/null`
  st=`git status 2> /dev/null`
  if [[ -n `echo "$st" | grep "^nothing to"` ]]; then
    # 全て commit されてクリーンな状態
    branch_status="${color}${green}${branch}"
  elif [[ -n `echo "$st" | grep "^Untracked files"` ]]; then
    # git 管理されていないファイルがある状態
    branch_status="${color}${red}${branch}?"
  elif [[ -n `echo "$st" | grep "^Changes not staged for commit"` ]]; then
    # git add されていないファイルがある状態
    branch_status="${color}${red}${branch}+"
  elif [[ -n `echo "$st" | grep "^Changes to be committed"` ]]; then
    # git commit されていないファイルがある状態
    branch_status="${color}${yellow}${branch}!"
  elif [[ -n `echo "$st" | grep "^rebase in progress"` ]]; then
    # コンフリクトが起こった状態
    echo "${color}${red}${branch}!(no branch)${reset}"
    return
  else
    # 上記以外の状態の場合
    branch_status="${color}${blue}${branch}"
  fi

  # ブランチ名を色付きで表示する
  echo "${branch_status}$branch_name${reset}"
}

# 通常のプロンプト
export LASTCMD_END_TIME
function left-prompt {
  name_t='255m%}'      # user name text color
  name_b='130m%}'    # user name background color
  path_t='255m%}'     # path text color
  path_b='031m%}'   # path background color
  time_t='255m%}'   # current_time text color
  time_b='128m%}'   # current_time background color
  arrow='072m%}'   # arrow color
  text_color='%{\e[38;5;'    # set text color
  back_color='%{\e[30;48;5;' # set background color
  reset='%{\e[0m%}'   # reset
  sharp="\uE0B0"      # triangle

  user="${back_color}${name_b}${text_color}${name_t}"
  dir="${back_color}${path_b}${text_color}${path_t}"
  current_time="${back_color}${time_b}${text_color}${time_t}"
  finish_time='%F{243}-> ${LASTCMD_END_TIME}%f'$'\n'
  branch='`git-current-branch`'
  echo "${finish_time}${user}%n${back_color}${path_b}${text_color}${name_b}${sharp} ${dir}%~${back_color}${time_b}${text_color}${path_b}${sharp} ${current_time}%D{%Y-%m-%d %H:%M:%S}${reset}${text_color}${time_b}${sharp}${reset}\n${branch}${text_color}${arrow}> ${reset}"
}

setopt prompt_subst
PROMPT=`left-prompt`

# コマンドの実行ごとに改行
function precmd() {
  # Print a newline before the prompt, unless it's the
  # first prompt in the process.
  if [ -z "$NEW_LINE_BEFORE_PROMPT" ]; then
      NEW_LINE_BEFORE_PROMPT=1
  elif [ "$NEW_LINE_BEFORE_PROMPT" -eq 1 ]; then
      echo ""
  fi
  LASTCMD_END_TIME=$(date "+%H:%M:%S")
}

LASTCMD_END_TIME=$(date "+%H:%M:%S")
update-lprompt-accpet-line() {
  zle .reset-prompt
  zle .accept-line
}
zle -N accept-line update-lprompt-accpet-line

setopt transient_rprompt
