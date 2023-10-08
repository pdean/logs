#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
#PS1='[\u@\h \W]\$ '
PS1='\[\e[1;35m\][\u@\h \W]\$\[\e[0m\] '

alias mc='. /usr/lib/mc/mc-wrapper.sh'
alias wa='wordle-aid'
alias tclsh='rlwrap tclsh'

export PATH=$PATH:~/bin
export EDITOR=vim

# see https://signalvnoise.com/posts/3264-automating-with-convention-introducing-sub
# https://github.com/qrush/sub
export PATH="${PATH}:/home/peter/my/bin"
source "/home/peter/my/libexec/../completions/my.bash"
_my_wrapper() {
  local command="$1"
  if [ "$#" -gt 0 ]; then
    shift
  fi

  case "$command" in
  shell)
    eval `my "sh-$command" "$@"`;;
  *)
    command my "$command" "$@";;
  esac
}
alias my=_my_wrapper

# see bash idioms chapter 10 
# # Install `xclip` or `xsel` for Linux copy and paste
alias gc='xsel -b'
# "GetClip" get stuff from right "X" clipboard
alias pc='xsel -bi'
# "PutClip" put stuff to right "X" clipboard
# Or Mac: pbcopy/pbpaste
# Or Windows: gclip.exe/pclip.exe or getclip.exe/putclip.exe
# Cleaner `df`
#alias df='df --print-type --exclude-type=tmpfs --exclude-type=devtmpfs'
alias df='df -h -P -T -x tmpfs -x devtmpfs'
alias diff='diff -u'
# Make unified diffs the default
#alias locate='locate -i'
# Case-insensitive locate
alias ping='ping -c4'
# Only 4 pings by default
#alias vzip='unzip -lvM'
# View contents of ZIP file
#alias lst='ls -lrt | tail -5' # Show this dir's 5 most recently modified files
# Tweaked from
# https://oreil.ly/1SUg7
