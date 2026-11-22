#########
# Alias 
#########
alias ls='ls -F --color=auto'
alias ll='ls -ltr'
alias la='ls -a'
alias lal='ls -al'

alias r='ruby'
alias l='less'

#alias cd=cdls
alias cdp='cd ../'
alias cdpp='cd ../../'
alias gitdiff='git difftool --tool=vimdiff --no-prompt'

#######################
# グローバルエイリアス
#######################
alias -g L='| less'
alias -g H='| head'
alias -g T='| tail'
alias -g G='| grep'
alias -g GI='| grep -i'

############
# Function 
############
# cd して ls する
function cdls() {
    # cdがaliasでループするので\をつける
    \cd $1;
    ls;
}
