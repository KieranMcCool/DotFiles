alias x="exit"
alias vrc="vim ~/.vimrc"
alias ba="vim ~/.bash_aliases"
alias ff='find . -name $1'
alias mkcd='mkdir -p $1 && cd $1'
alias tx="pdflatex"
alias batt='pmset -g batt'
alias c='cd ~/Documents/Code'
alias n='cd ~/Documents/Notes'
alias d='cd ~/Desktop'
alias workon='conda activate'
alias deactivate='conda deactivate'
alias vim='nvim'
alias kaexe='killall -r .*.exe'
alias update="sudo pacman -Syu && yay -Syu"

function gh {
    git clone "https://github.com/$1/$2"
}

function ghme {
    gh "$GITHUB_USERNAME" "$1"
}
