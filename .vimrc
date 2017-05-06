" Plugin Stuffs
call plug#begin('~/.vim/plugged')
Plug 'vim-pandoc/vim-pandoc'
Plug 'vim-pandoc/vim-pandoc-syntax' 

" Initialize plugin system
call plug#end()

" Preferences
syntax on
set nocompatible 

set path+=**

set tabstop=4
set expandtab

set autoindent
set smartindent
set smarttab
set shiftwidth=4

set showcmd
set cursorline
set number

set laststatus=2
set statusline=%F%m%r%h%w\ (%{&ff}){%Y}[%l,%v][%p%%]\ %{strftime(\"%d/%m/%y\ -\ %H:%M\")}

filetype indent on
set lazyredraw
set showmatch
set incsearch

set wildmenu


" Vim Pandoc setup
let g:pandoc#formatting#mode = 'ha'
let g:pandoc#modules#disabled = ["folding"]
let g:pandoc#biblio#use_bibtool = 1

" Word Processing setup
function! Wp()
    set tw=80
    set wm=2
    set wrap linebreak nolist
endfunction
