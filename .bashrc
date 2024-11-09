#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1='[\u@\h \W]\$ '
DEFAULT_PS1=$PS1
PS1='\[\033[31m\][\[\033[33m\]\u\[\033[32m\]@\[\033[34m\]\h \[\033[35m\]\W\[\033[31m\]] \[\033[37m\]\$ '

# Variables
export EDITOR=/usr/bin/nvim
export BROWSER=/usr/bin/google-chrome-stable
export GITHUB_USERNAME="KieranMcCool"

# Path
export CustomScriptsPath='~/.scripts:~/.scripts/private'
export NpmPath='~/.npm/bin'
export PATH=$PATH:$CustomScriptsPath:$NpmPath

npm config set prefix ~/.npm

[[ -f ~/.bash_aliases ]] && . ~/.bash_aliases

eval "$(pandoc --bash-completion)"
