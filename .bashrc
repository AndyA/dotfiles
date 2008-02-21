# .bashrc
export EDITOR=vim
export PAGER=less
export UNAME=`uname`

# Directory shortcuts
shopt -s cdable_vars
shopt -s histappend
shopt -s checkwinsize

export HISTFILESIZE=10000
export HISTCONTROL=ignoredups

function source_dir {
    dir=$1
    if [ -d $dir ] ; then
        for rc in $dir/* ; do
            [ -f $rc ] && source $rc
        done
    fi
}

# Per platform config
source_dir "$HOME/.bash.d/$UNAME"
# Per host config
source_dir "$HOME/.bash.d/$HOSTNAME"
# Global topical config
source_dir "$HOME/.bash.d"

PATH=`$HOME/bin/path_append $PATH`
export PATH

[ -f ~/.aliases ] && source ~/.aliases

