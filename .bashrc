#
# ~/.bashrc
#
# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='\[\e[38;2;157;124;216m\]\u \W\[\e[0m\] '
export PATH=~/.npm-global/bin:$PATH
