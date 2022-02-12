# rc files

## bash

```
#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
#PS1='[\u@\h \W]\$ '
PS1='\[\e[1;34m\][\u@\h \W]\$\[\e[0m\] '

alias mc='. /usr/lib/mc/mc-wrapper.sh'

```



## vim

**.vimrc**

```
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
colorscheme murphy

nnoremap <silent> <C-l> :<C-u>nohlsearch<CR><C-l>
```

## plod

**.plodrc**

```
$PROMPT = 0;
$CRYPTCMD = "/usr/bin/crypt";
$EDITOR = "/usr/bin/vim";
$VISUAL = "/usr/bin/vim";
$PAGER =  "/usr/bin/less";
$LOGDIR = "$HOME/sync";
$LOGFILE  = "log";
$KEYVAL = "??????";
$STAMP = sprintf("%02d/%02d/%04d, %02d:%02d --", $DD, $MM, $YY+1900, $hh, $mm);

```

## mutt






## msmtp







