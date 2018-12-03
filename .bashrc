#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1='[\u@\h \W]\$ '
DEFAULT_PS1=$PS1
PS1='\[\033[31m\][\[\033[33m\]\u\[\033[32m\]@\[\033[34m\]\h \[\033[35m\]\W\[\033[31m\]] \[\033[37m\]\$ '

EDITOR=/usr/bin/vi
BROWSER=/usr/bin/firefox

# Add miniconda to path
PATH=$PATH:/home/kmccool/miniconda3/bin/:/home/kmccool/.scripts

npm config set prefix ~/.npm
PATH=$PATH:/home/kmccool/.npm/bin
[[ -f ~/.bash_aliases ]] && . ~/.bash_aliases
