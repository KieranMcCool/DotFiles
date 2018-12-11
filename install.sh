#!/bin/bash
############################
# Credit to : https://github.com/mplacona/dotfiles/blob/master/bootstrap.sh for this script. 
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################

########## Variables

dir=~/DotFiles                    # dotfiles directory
olddir=~/DotFiles_old             # old dotfiles backup directory
files=$(find . -not -path "./.git*" -not -name ".gitignore" -not -name ".git*" -not -name "install.sh" -type f -exec basename {} \; | xargs echo)

##########

# create dotfiles_old in homedir
echo "Creating $olddir for backup of any existing dotfiles in ~"
mkdir -p "$olddir"
echo "...done"

# change to the dotfiles directory
echo "Changing to the $dir directory"
cd $dir
echo "...done"

# move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks 
for file in $files; do
    echo "Moving any existing dotfiles from ~ to $olddir"
    mv ~/$file $olddir
    echo "Creating symlink to $file in home directory."
    ln -s $dir/$file ~/$file
done

source ~/.bashrc
