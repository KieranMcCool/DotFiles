#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1='[\u@\h \W]\$ '
DEFAULT_PS1=$PS1
PS1='\[\033[31m\][\[\033[33m\]\u\[\033[32m\]@\[\033[34m\]\h \[\033[35m\]\W\[\033[31m\]] \[\033[37m\]\$ '

export EDITOR=/usr/bin/nvim
export BROWSER=/usr/bin/firefox

# Path

export MinicondaPath='/home/kmccool/miniconda3/bin'
export MSBuildSDKsPath="/opt/dotnet/sdk/$(dotnet --version)/Sdks"
export CustomScriptsPath='/home/kmccool/.scripts'
export PATH=$PATH:$MinicondaPath:$MSBuildSDKsPath:$CustomScriptsPath

npm config set prefix ~/.npm
PATH=$PATH:/home/kmccool/.npm/bin
[[ -f ~/.bash_aliases ]] && . ~/.bash_aliases
[ -f /opt/miniconda3/etc/profile.d/conda.sh ] && source /opt/miniconda3/etc/profile.d/conda.sh

eval "$(pandoc --bash-completion)"

