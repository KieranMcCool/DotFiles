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
export BROWSER=/usr/bin/firefox
export GITHUB_USERNAME="KieranMcCool"

# Path
export MinicondaPath='/home/kmccool/miniconda3/bin'
export MSBuildSDKsPath="/opt/dotnet/sdk/$(dotnet --version)/Sdks"
export CustomScriptsPath='/home/kmccool/.scripts'
export NpmPath='/home/kmccool/.npm/bin'
export PATH=$PATH:$MinicondaPath:$MSBuildSDKsPath:$CustomScriptsPath:$NpmPath

npm config set prefix ~/.npm

[[ -f ~/.bash_aliases ]] && . ~/.bash_aliases
[ -f /opt/miniconda3/etc/profile.d/conda.sh ] && source /opt/miniconda3/etc/profile.d/conda.sh

eval "$(pandoc --bash-completion)"

