#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
#PS1='[\u@\h \W]\$ '
PS1='\[\e[1;34m\][\u@\h \W]\$\[\e[0m\] '

alias mc='. /usr/lib/mc/mc-wrapper.sh'
alias wa=wordle-aid
alias yt='yt-dlp --write-subs '
alias tclsh='rlwrap tclsh'
alias ping='ping -c4'
alias l="ls -lrth"

export UBXOPTS="-P 18 -v 2"
export PATH=$PATH:~/bin

# see bash idioms chapter 10
# # Install `xclip` or `xsel` for Linux copy and paste
alias gc='xsel -b'
# "GetClip" get stuff from right "X" clipboard
alias pc='xsel -bi'
# "PutClip" put stuff to right "X" clipboard
# Or Mac: pbcopy/pbpaste
# Or Windows: gclip.exe/pclip.exe or getclip.exe/putclip.exe
# Cleaner `df`
alias df='df --print-type --exclude-type=tmpfs --exclude-type=devtmpfs'
alias diff='diff -u'
# Make unified diffs the default
alias locate='locate -i'
# Case-insensitive locate
alias ping='ping -c4'
# Only 4 pings by default
alias vzip='unzip -lvM'
# View contents of ZIP file
alias lst='ls -lrt | tail -5' # Show this dir's 5 most recently modified files
# Tweaked from
# https://oreil.ly/1SUg7

export CDPATH='.:~/:..:../..:~/.dirlinks'
