#!/bin/bash
############################
# Credit to : https://github.com/mplacona/dotfiles/blob/master/bootstrap.sh for this script. 
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################

########## Variables

dir=$(pwd)                   # dotfiles directory
olddir=$(pwd)/backup # old dotfiles backup directory
files=$(find . -not -path "./backup" -not -path "./.git*" -not -name ".gitignore" \
    -not -name ".git*" -not -name "install.sh" -type f -exec basename {} \; | xargs echo)

##########

# create dotfiles_old in homedir
mkdir -p "$olddir"

# change to the dotfiles directory
cd $dir

# move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks 
for file in $files; do
    mv ~/$file $olddir
    ln -s $dir/$file ~/$file
done

source ~/.bashrc
