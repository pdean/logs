# rc files

## .bashrc

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



## .vimrc


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

## .plodrc

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

## .xinitrc

```
#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# start some nice programs

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

#twm &
#xclock -geometry 50x50-1+1 &
#xterm -geometry 80x50+494+51 &
#xterm -geometry 80x20+494-0 &
#exec xterm -geometry 80x66+0+0 -name login

eval $(gnome-keyring-daemon --start)
export SSH_AUTH_SOCK
exec mate-session

```




## mutt






## msmtp






## vim modelines

### tcl

```
# vim:sts=4:sw=4:tw=80:et:ft=tcl 




```

