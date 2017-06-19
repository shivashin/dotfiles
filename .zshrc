###############
# zsh Setting 
###############

###############
# �q�X�g���֘A
###############
# �����̕ۑ���
HISTFILE=$HOME/.zsh-history
## �������ɓW�J���闚���̐�
# HISTSIZE=10000
## �ۑ����闚���̐�
SAVEHIST=10000

## �R�}���h���C���̐擪���X�y�[�X�Ŏn�܂�ꍇ�q�X�g���ɒǉ����Ȃ�
setopt hist_ignore_space
## history (fc -l) �R�}���h���q�X�g�����X�g�����菜���B
setopt hist_no_store
## ���O�Ɠ����R�}���h���q�X�g���ɒǉ����Ȃ�
setopt hist_ignore_dups
## �q�X�g�����Ăяo���Ă�����s����ԂɈ�U�ҏW
setopt hist_verify
## zsh �̊J�n, �I���������q�X�g���t�@�C���ɏ�������
setopt extended_history
## �]���ȋ󔒂͋l�߂ċL�^
setopt hist_reduce_blanks  
## �Â��R�}���h�Ɠ������͖̂��� 
setopt hist_save_no_dups
## �q�X�g���ɒǉ������R�}���h�s���Â����̂Ɠ����Ȃ�Â����̂��폜
setopt hist_ignore_all_dups
## �⊮���Ƀq�X�g���������I�ɓW�J         
setopt hist_expand

## Screen�ł̃R�}���h���L�p
## �V�F�������f����.zshhistory�ɋL�^
setopt inc_append_history
## �q�X�g�������L
setopt share_history

###################
# �f�B���N�g���ύX
###################
## �f�B���N�g���������� cd
setopt auto_cd
## cd ���Ɏ����� push
setopt auto_pushd
## �����f�B���N�g���� pushd ���Ȃ�
setopt pushd_ignore_dups

############
# ��Ԋ֘A
############
## �⊮�@�\�̗L��
autoload -U compinit
compinit

## TAB �ŏ��ɕ⊮����؂�ւ���
setopt auto_menu
## �T�X�y���h���̃v���Z�X�Ɠ����R�}���h�������s�����ꍇ�̓��W���[��
setopt auto_resume
## �⊮�����ꗗ�\��
setopt auto_list
## �J�b�R�̑Ή��Ȃǂ������I�ɕ⊮
setopt auto_param_keys
## �f�B���N�g�����̕⊮�Ŗ����� / �������I�ɕt�����A���̕⊮�ɔ�����
setopt auto_param_slash
## �⊮���̃J�[�\���I����L����
zstyle ':completion:*:default' menu select=1
## �⊮���̐F�Â�
eval `dircolors`
export ZLS_COLORS=$LS_COLORS
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
## �⊮���ꗗ�Ńt�@�C���̎�ʂ��}�[�N�\��
setopt list_types
## �⊮�����l�߂ĕ\��
setopt list_packed
## �⊮�ŏ������ł��啶���ł��}�b�`������
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

#########
# �O���u
#########
## �g���O���u���g�p
## �t�@�C������ #, ~, ^ �� 3 �����𐳋K�\���Ƃ��Ĉ���
setopt extended_glob
## =command �� command �̃p�X���ɓW�J����
setopt equals
## --prefix=/usr �Ȃǂ� = �ȍ~���⊮
setopt magic_equal_subst
## �t�@�C�����̓W�J�Ŏ������ł͂Ȃ����l�I�Ƀ\�[�g
setopt numeric_glob_sort

##########
# ���o��
##########
## �o�͎�8�r�b�g��ʂ�
setopt print_eight_bit
## �X�y���`�F�b�N�B�ԈႤ�ƒ������Ă����
setopt correct
## �o�͂̕����񖖔��ɉ��s�R�[�h�������ꍇ�ł��\��
unsetopt promptcr
## {a-c} �� a b c �ɓW�J����@�\���g����悤�ɂ���
setopt brace_ccl
## Ctrl+S/Ctrl+Q �ɂ��t���[������g��Ȃ��悤�ɂ���
setopt NO_flow_control
## �R�}���h���C���ł� # �ȍ~���R�����g�ƌ��Ȃ�
setopt interactive_comments
## �t�@�C�����̓W�J�Ńf�B���N�g���Ƀ}�b�`�����ꍇ������ / ��t������
setopt mark_dirs
## �Ō�̃X���b�V���������I�ɍ폜���Ȃ�
setopt noautoremoveslash

###############
# �L�[�o�C���h
###############
## vim���C�N�L�[�o�C���h�ݒ�
bindkey -v

##################
# �v�����v�g�֘A
##################
# �F�L��
autoload -U colors
colors

## �F���g��
setopt prompt_subst

# �F���`
local GREEN=$'%{\e[1;32m%}'
local BLUE=$'%{\e[1;34m%}'
local DEFAULT=$'%{\e[1;m%}'

# �ʏ�̃v�����v�g
#PROMPT=$BLUE'[%n@%m] %(!.#.$) '$WHITE
PROMPT=$BLUE'[%n]%# '$WHITE
# �E���̃v�����v�g�B�����ŃJ�����g�f�B���N�g�����o���B
RPROMPT=$GREEN'[%~]'$WHITE
setopt transient_rprompt

##############
# �W���u����
##############
## �����R�}���h jobs �̏o�͂��f�t�H���g�� jobs -l �ɂ���
setopt long_list_jobs


#################
# ���̑��E������
#################
## �R�A�_���v�T�C�Y�𐧌�
# limit coredumpsize 102400


## �r�[�v��炳�Ȃ�
setopt nobeep

#########
# Alias 
#########
alias ls='ls -F --show-control-chars --color=aut'
alias ll='ls -ltr'
alias la='ls -a'
alias lal='ls -al'

alias c='cygstart'
alias r='ruby'
alias l='less'

#alias cd=cdls
alias cdp='cd ../'
alias cdpp='cd ../../'


#######################
# �O���[�o���G�C���A�X
#######################
alias -g L='| less'
alias -g H='| head'
alias -g T='| tail'
alias -g G='| grep'
alias -g GI='| grep -i'

############
# Function 
############
# cd ���� ls ����
function cdls() {
    # cd��alias�Ń��[�v����̂�\������
    \cd $1;
    ls;
}

###############
# Environment 
###############
export LANG=ja_JP.UTF-8
export LD_LIBRARY_PATH=/usr/local/lib
export LIBRARY_PATH=/usr/local/lib
export CPATH=/usr/local/include

###############
# Git
###############
RPROMPT="%{${fg[green]}%}[%~]%{${reset_color}%}"
autoload -Uz vcs_info
setopt prompt_subst
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "%F{yellow}!"
zstyle ':vcs_info:git:*' unstagedstr "%F{red}+"
zstyle ':vcs_info:*' formats "%F{green}%c%u[%b]%f"
zstyle ':vcs_info:*' actionformats '[%b|%a]'
precmd () { vcs_info }
RPROMPT=$RPROMPT'${vcs_info_msg_0_}'
