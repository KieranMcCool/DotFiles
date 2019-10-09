alias x="exit"
alias vrc="vim ~/.vimrc"
alias ba="vim ~/.bash_aliases"
alias ff='find . -name $1'
alias mkcd='mkdir -p $1 && cd $1'
alias tx="pdflatex"
alias ffx="firefox"
alias fm="open . || nautilus ."
alias subl="/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl"
alias batt='pmset -g batt'
alias c='cd ~/Documents/Code'
alias n='cd ~/Documents/Notes'
alias d='cd ~/Desktop'
alias makenotes='python ~/Documents/Code/notes/main.py'
alias workon='conda activate'
alias deactivate='conda deactivate'
alias hrs='cat log.md | grep -e "##" | sed -E "s|##(.)* - ||g" | sed -E "s| (.)*||g" | python -c "import sys; print(sum(int(l) for l in sys.stdin))"'
alias proj='cd ~/Documents/Notes/Level4Project-Docs && workon pytorch'
alias vim='nvim'
alias kaexe='killall -r .*.exe'

function gh {
    git clone "https://github.com/$1/$2"
}

function ghme {
    gh "$GITHUB_USERNAME" "$1"
}
