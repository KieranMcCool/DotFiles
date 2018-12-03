" Preferences
" ===========
syntax on
set nocompatible 

" Vundle Configs
" ==============
set rtp+=~/.vim/bundle/Vundle.vim

call plug#begin('~/.vim/plugged')

" Deoplete
" ========
if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif

" Deoplete Completion Sources
" ===========================
Plug 'zchee/deoplete-jedi'
Plug 'wokalski/autocomplete-flow'
Plug 'zchee/deoplete-clang'
Plug 'tpope/vim-surround'
Plug 'alvan/vim-closetag'

" Language Server
Plug 'autozimu/LanguageClient-neovim', { 
            \'branch' : 'next',
            \'do': 'bash install.sh'
            \}

" NerdTree
" ========
Plug 'scrooloose/nerdtree'
Plug 'ryanoasis/vim-devicons'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'Xuyuanp/nerdtree-git-plugin'

" Vim-Pandoc
" ==========
Plug 'vim-pandoc/vim-pandoc'
Plug 'vim-pandoc/vim-pandoc-syntax' 

" CTRL P
Plug 'ctrlpvim/ctrlp.vim'
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
set cursorline
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

" DeoComplete Stuffs

call deoplete#custom#source('LanguageClient',
            \ 'min_pattern_length',
            \ 2)
set runtimepath+=~/.vim/bundle/deoplete.nvim/
set runtimepath+=~/.vim/bundle/deoplete-jedi/

let g:deoplete#enable_at_startup = 1
let g:deoplete#auto_complete = 1
let g:python_host_prog = '/home/kmccool/miniconda3/envs/neo2/bin/python'
let g:python3_host_prog = '/home/kmccool/miniconda3/envs/neo3/bin/python'

" Language Server
set hidden
let g:LanguageClient_loggingLevel = 'DEBUG'
let g:LanguageClient_loggingFile = '/home/kmccool/Desktop/log.txt'
let g:LanguageClient_serverCommands = {
    \ 'cs': ['/opt/omnisharp-roslyn/OmniSharp.exe', '-lsp', '-e', 'utf-8'],
    \ 'css': ['/home/kmccool/.npm/bin/css-languageserver', '-stdio'],
    \ 'typescript': ['/home/kmccool/.npm/bin/typescript-language-server', '-stdio'],
    \ 'cpp': ['clangd'],
    \ 'c': ['clangd']
    \ }

nnoremap <F5> :call LanguageClient_contextMenu()<CR>
" Or map each action separately
nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
nnoremap <silent> <F2> :call LanguageClient#textDocument_rename()<CR>

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
set runtimepath^=~/.vim/bundle/ctrlp.vim
