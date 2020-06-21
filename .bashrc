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
export MinicondaPath='/home/kmccool/miniconda3/bin'
export MSBuildSDKsPath=$( echo /usr/share/dotnet/sdk/3.*/Sdks );
export CustomScriptsPath='/home/kmccool/.scripts'
export NpmPath='/home/kmccool/.npm/bin'
export PATH=$PATH:$MinicondaPath:$MSBuildSDKsPath:$CustomScriptsPath:$NpmPath

npm config set prefix ~/.npm

[[ -f ~/.bash_aliases ]] && . ~/.bash_aliases
[ -f /opt/miniconda3/etc/profile.d/conda.sh ] && source /opt/miniconda3/etc/profile.d/conda.sh

eval "$(pandoc --bash-completion)"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/kmccool/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/kmccool/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/kmccool/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/kmccool/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

