" Preferences
syntax on
set nocompatible 

" Plugin Stuffs
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'vim-pandoc/vim-pandoc'
Plugin 'vim-pandoc/vim-pandoc-syntax' 
if has('nvim')
  Plugin 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plugin 'Shougo/deoplete.nvim'
  Plugin 'roxma/nvim-yarp'
  Plugin 'roxma/vim-hug-neovim-rpc'
  Plugin 'zchee/deoplete-jedi'
  Plugin 'fszymanski/deoplete-emoji'
endif
Plugin 'alvan/vim-closetag'
Plugin 'tpope/vim-surround'
call vundle#end()   

" NeoComplete Stuffs
let g:deoplete#enable_at_startup = 1
let g:deoplete#auto_complete = 1
let g:python_host_prog = '/usr/bin/python'
let g:python3_host_prog = '/usr/local/bin/python3'

" Additional Config

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

" Plugin Specific
" ===============

" NeoSnippet Setup

imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
\ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

if has('conceal')
  set conceallevel=2 concealcursor=niv
endif

" Closetag setup

let g:closetag_filenames = '*.html,*.xhtml,*.phtml'
let g:closetag_xhtml_filenames = '*.xhtml,*.jsx'
let g:closetag_emptyTags_caseSensitive = 1
let g:closetag_shortcut = '>'
let g:closetag_close_shortcut = '<leader>>'

" Vim Pandoc setup
"let g:pandoc#formatting#mode = 'ha'
let g:pandoc#modules#disabled = ["folding"]
let g:pandoc#biblio#use_bibtool = 1
