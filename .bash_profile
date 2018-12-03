# colors
# Tell grep to highlight matches
export GREP_OPTIONS='--color=auto'

# Tell ls to be colourful
export CLICOLOR=1

if [ -f ~/.bashrc ]; then
        . ~/.bashrc
fi

export PATH=/Users/kmccool/Library/Python/2.7/bin:$HOME/miniconda3/bin:$PATH
