#!/bin/bash

[ -e ~/perl5/perlbrew/etc/bashrc ] || exit

if diff ~/bin/perlbrew-0.60-bashrc.orig ~/perl5/perlbrew/etc/bashrc >/dev/null; then
  cp ~/bin/perlbrew-0.60-bashrc.orig ~/perl5/perlbrew/etc/bashrc 
  echo "Fixed perlbrew bashrc"
fi

# vim:ts=2:sw=2:sts=2:et:ft=sh

