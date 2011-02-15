# .bashrc
export EDITOR=vim
export PAGER=less
export RCUNAME=`uname`

umask 0022

if [ -n "$PS1" ]; then
  # Directory shortcuts
  shopt -s cdable_vars
  shopt -s histappend
  shopt -s checkwinsize
  shopt -s checkhash

  # Ignore hidden files during completion
  bind 'set match-hidden-files off' 

  export HISTFILESIZE=10000
  export HISTCONTROL=ignoredups
fi

function source_dir {
  dir=$1
  if [ -d $dir ] ; then
    for rc in $dir/* ; do
      [ -f $rc ] && source $rc
    done
  fi
}

MANPATH=$(manpath)

# Per platform config
source_dir "$HOME/.bash.d/$RCUNAME"
# Per host config
source_dir "$HOME/.bash.d/$HOSTNAME"
# Global topical config
source_dir "$HOME/.bash.d"

PATH=$($HOME/bin/path_append $PATH)
MANPATH=$($HOME/bin/path_append $MANPATH)
export PATH MANPATH

[ -f ~/.aliases ] && source ~/.aliases

# vim:ts=2:sw=2:sts=2:et:ft=sh
