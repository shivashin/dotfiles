# mise / fzf / cdr / zoxide

# 言語ランタイム（ruby / node / python など）は mise で管理する
eval "$(mise activate zsh)"


# fzf history
function fzf-select-history() {
    BUFFER=$(history -n -r 1 | fzf --query "$LBUFFER" --reverse)
    CURSOR=$#BUFFER
    zle reset-prompt
}
zle -N fzf-select-history
bindkey '^r' fzf-select-history

# cdr自体の設定
if [[ -n $(echo ${^fpath}/chpwd_recent_dirs(N)) && -n $(echo ${^fpath}/cdr(N)) ]]; then
    autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
    add-zsh-hook chpwd chpwd_recent_dirs
    zstyle ':completion:*' recent-dirs-insert both
    zstyle ':chpwd:*' recent-dirs-default true
    zstyle ':chpwd:*' recent-dirs-max 1000
fi

# fzf cdr
function fzf-cdr() {
    local selected_dir=$(cdr -l | awk '{ print $2 }' | fzf --reverse)
    if [ -n "$selected_dir" ]; then
        BUFFER="cd ${selected_dir}"
        zle accept-line
    fi
    zle clear-screen
}
zle -N fzf-cdr
setopt noflowcontrol
bindkey '^q' fzf-cdr

# mise より優先させるため、mise の有効化のあとで PATH の先頭に足す
# Rancher Desktop（docker / kubectl など）。Rancher Desktop の PATH 管理は手動にしている
export PATH="$HOME/.rd/bin:$PATH"
export PATH=~/.npm-global/bin:$PATH

# zoxide (z コマンド / tmux の prefix+N で使うディレクトリ履歴)
eval "$(zoxide init zsh)"
