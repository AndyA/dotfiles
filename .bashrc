# .bashrc

if [[ $- != *i* ]]; then
  return
fi

export EDITOR=vim
export PAGER=less
export RCUNAME=`uname`
export LC_CTYPE=$LANG

if [ -n "$PS1" ]; then
  # Directory shortcuts
  shopt -s cdable_vars
  shopt -s histappend
  shopt -s checkwinsize
  shopt -s checkhash

  # Ignore hidden files during completion
  bind 'set match-hidden-files off' 

  export HISTFILESIZE=10000
  export HISTCONTROL=erasedups
fi

function source_dir {
  dir=$1
  if [ -d $dir ] ; then
    for rc in $dir/* ; do
      [ -f $rc ] && source $rc
    done
  fi
}

[ -f ~/.bash_local ] && source ~/.bash_local

# Per platform config
source_dir "$HOME/.bash.d/$RCUNAME"
# Per host config
source_dir "$HOME/.bash.d/$HOSTNAME"
# Local config
source_dir "$HOME/.bash.d/local"
# Global topical config
source_dir "$HOME/.bash.d"

PATH=$($HOME/bin/path_append $PATH)
export PATH

[ -f ~/.aliases ] && source ~/.aliases
[ -f ~/.cargo/env ] && source ~/.cargo/env

PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a"

# vim:ts=2:sw=2:sts=2:et:ft=bash
