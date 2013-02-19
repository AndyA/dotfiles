#!/bin/bash

function die {
  echo "$@" 1>&2
  exit 1
}

ccache="$( which ccache )" 
[ "$ccache" ] || die "Please install ccache and try again"

echo "Using $ccache"

PATH=$( perl -e 'print join ":", grep !m{^/usr/local/bin}, split ":", $ENV{PATH}' )

skip=""
for cc in {c++,g++,gcc,cc}{,-{2..5}{,.{0..9}}} clang; do
  targ="/usr/local/bin/$cc"
  if [ -L "$targ" ] && readlink "$targ" | grep ccache >/dev/null 2>&1; then
    echo "Removing $targ"
    rm -f "$targ"
  fi
  if [ -e "$targ" ]; then
    echo "$targ is not a link"
  else
    if which "$cc" >/dev/null 2>&1; then
      echo "Linking $targ -> $ccache"
      ln -s "$ccache" "$targ"
    else
      skip="$skip $cc"
    fi
  fi
done
if [ "$skip" ]; then
  echo "Not found:$skip"
fi

# vim:ts=2:sw=2:sts=2:et:ft=sh

