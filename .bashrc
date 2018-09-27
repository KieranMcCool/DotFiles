#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'

PS1='[\u@\h \W]\$ '
DEFAULT_PS1=$PS1
PS1='\[\033[31m\][\[\033[33m\]\u\[\033[32m\]@\[\033[34m\]\h \[\033[35m\]\W\[\033[31m\]] \[\033[37m\]\$ '

EDITOR=/usr/bin/vi
BROWSER=/usr/bin/firefox

PATH=$PATH:/home/kmccool/miniconda3/bin/
[[ -f ~/.bash_aliases ]] && . ~/.bash_aliases
