#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias ll='ls -al'

export PATH="$HOME/.local/bin:$PATH"

# PS1='[\u@\h \W]\$ '
PS1="> \[\e[1;32m\]\u \[\e[0m\]> \[\e[0;34m\]\w\[\e[0m\] > "
[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && \
    . /usr/share/bash-completion/bash_completion

