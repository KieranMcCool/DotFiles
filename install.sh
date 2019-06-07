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


mkdir -p ~/.config/nvim
ln -s ~/.vimrc ~/.config/nvim/init.vim

curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

sudo pacman -S --noconfirm git neovim yay pandoc pandoc-citeproc texlive-core caprine kdeplasma-addons npm dotnet-sdk dotnet-runtime lutris latte-dock redshift
yay -S --noconfirm spotify visual-studio-code-bin google-chrome gtk3-nocsd-git sierrabreeze-kwin-decoration-git nerd-fonts-hack

mkdir ~/Documents/Code
mkdir ~/Documents/Notes
