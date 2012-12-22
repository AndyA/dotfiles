#!/bin/bash

function die {
  echo "$@" 1>&2
  exit 1
}

ccache="$( which ccache )" 
if [ -z "$ccache" ]; then
  which brew && brew install ccache
  which apt-get && sudo apt-get install ccache
  ccache="$( which ccache )" 
  [ "$ccache" ] || die "No ccache"
fi

if link="$( readlink "$ccache" )"; then
  real="$( dirname "$ccache" )"/"$( readlink "$ccache" )"
  ccache="$real"
fi

echo "Using $ccache"

PATH=$( perl -e 'print join ":", grep !m{^/usr/local/bin}, split ":", $ENV{PATH}' )

for cc in c++ c++-3.3 c++-4.0 c++-4.2 c++3 cc \
  g++ g++-3.3 g++-4.0 g++-4.2 g++2 g++3 \
  gcc gcc-3.3 gcc-4.0 gcc-4.2 gcc2 gcc3; do
  targ="/usr/local/bin/$cc"
  [ -e "$targ" ] && rm -f "$targ"
  if which "$cc" >/dev/null 2>&1; then
    echo "Linking $targ -> $real"
    ln -s "$real" "$targ"
  else
    echo "No $cc, skipped"
  fi
done

# vim:ts=2:sw=2:sts=2:et:ft=sh

