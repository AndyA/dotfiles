#!/bin/bash

ccache="$( which ccache )" 
if [ -z "$ccache" ]; then
  brew install ccache || exit
  ccache="$( which ccache )" 
fi
real="$( dirname "$ccache" )"/"$( readlink "$ccache" )"

echo "Using $ccache -> $real"

PATH=$( perl -e 'print join ":", grep !m{^/usr/local/bin}, split ":", $ENV{PATH}' )

for cc in c++ c++-3.3 c++-4.0 c++-4.2 c++3 cc \
  g++ g++-3.3 g++-4.0 g++-4.2 g++2 g++3 \
  gcc gcc-3.3 gcc-4.0 gcc-4.2 gcc2 gcc3; do
  targ="/usr/local/bin/$cc"
  [ -e "$targ" ] && rm -f "$targ"
  if which -s "$cc"; then
    echo "Linking $targ -> $real"
    ln -s "$real" "$targ"
  else
    echo "No $cc, skipped"
  fi
done

# vim:ts=2:sw=2:sts=2:et:ft=sh

