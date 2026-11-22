##############
# plugin
##############
source ~/.zplug/init.zsh

# Supports checking out a specific branch/tag/commit
zplug "b4b4r07/enhancd", at:v1
zplug "mollifier/anyframe", at:4c23cb60

# Set the priority when loading
# e.g., zsh-syntax-highlighting must be loaded
# after executing compinit command and sourcing other plugins
# (If the defer tag is given 2 or above, run after compinit command)
zplug "zsh-users/zsh-syntax-highlighting", at:0.8.0, defer:2

# cmplete
zplug "zsh-users/zsh-completions", at:0.36.0

#fish-like autosuggestion
zplug 'zsh-users/zsh-autosuggestions', at:v0.7.1

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# Then, source plugins and add commands to $PATH
zplug load --verbose
