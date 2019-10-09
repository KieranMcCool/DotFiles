" Preferences
" ===========
syntax on
set nocompatible 

call plug#begin('~/.vim/plugged')


Plug 'alvan/vim-closetag'

" COC Completion
" ==============
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" NerdTree
" ========
Plug 'scrooloose/nerdtree'
Plug 'ryanoasis/vim-devicons'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'

" Vim-Pandoc
" ==========
Plug 'vim-pandoc/vim-pandoc'
Plug 'vim-pandoc/vim-pandoc-syntax' 

" CTRL P
Plug 'ctrlpvim/ctrlp.vim'

" SuperTab
Plug 'ervandew/supertab'
call plug#end()

" Additional Config
" =================

filetype plugin indent on 
set backspace=indent,eol,start

set path+=**

set tabstop=4
set expandtab

set autoindent
set smartindent
set smarttab
set shiftwidth=4

set showcmd
set number

set laststatus=2
set statusline=%F%m%r%h%w\ (%{&ff}){%Y}[%l,%v][%p%%]\ %{strftime(\"%d/%m/%y\ -\ %H:%M\")}

filetype indent on
set nolazyredraw
set showmatch
set incsearch

set wildmenu
if has('nvim')
tnoremap <Esc> <C-\><C-n>
endif

" Plugin Specific
" ===============

" Closetag setup

let g:closetag_filenames = '*.html,*.xhtml,*.phtml'
let g:closetag_xhtml_filenames = '*.xhtml,*.jsx'
let g:closetag_emptyTags_caseSensitive = 1
let g:closetag_shortcut = '>'
let g:closetag_close_shortcut = '<leader>>'

" Vim Pandoc setup
let g:pandoc#modules#disabled = ["folding"]
let g:pandoc#biblio#use_bibtool = 1

" NERDTree Setup
set encoding=UTF-8
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
map <C-n> :NERDTreeToggle<CR>
let g:NERDTreeShowIgnoredStatus = 1
let g:NERDTreeIndicatorMapCustom = {
\ "Modified" : "✹",
\ "Staged" : "✚",
\ "Untracked" : "✭",
\ "Renamed" : "➜",
\ "Unmerged" : "═",
\ "Deleted" : "✖",
\ "Dirty" : "✗",
\ "Clean" : "✔︎",
\ 'Ignored' : '☒',
\ "Unknown" : "?"
\ }

" Ctrl P set up
set runtimepath^=~/.vim/plugged/ctrlp.vim

" SuperTab
let g:SuperTabDefaultCompletionType = "<c-n>"
