set nocompatible


filetype on
syntax enable
set modeline
filetype indent on
filetype plugin on

set showcmd            " Show (partial) command in status line.
set showmatch          " Show matching brackets.
set ignorecase         " Do case insensitive matching
set smartcase          " Do smart case matching
set incsearch          " Incremental search
set autowrite          " Automatically save before commands like :next and :make
set hidden             " Hide buffers when they are abandoned

set shiftwidth=4
set smarttab
set expandtab
set hlsearch
set sts=4
set tw=80

colorscheme murphy

nnoremap <silent> <C-l> :<C-u>nohlsearch<CR><C-l>
autocmd BufNewFile,BufFilePre,BufRead *.md set filetype=markdown

set mouse=a

:runtime! ftplugin/man.vim
