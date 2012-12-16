#!/bin/bash

ccache="$( which ccache )"
real="$( dirname "$ccache" )"/"$( readlink "$ccache" )"

echo "$ccache -> $real"
for cc in c++ c++-3.3 c++-4.0 c++-4.2 c++3 cc \
  g++ g++-3.3 g++-4.0 g++-4.2 g++2 g++3 \
  gcc gcc-3.3 gcc-4.0 gcc-4.2 gcc2 gcc3; do
  targ="/usr/local/bin/$cc"
  [ -e "$targ" ] && rm -f "$targ"
  echo "$targ -> $real"
  ln -s "$real" "$targ"
done
exit




[20:37] andy@voodoo:~/Works/Media/emitron/lib/pipetoys
$ ls /usr/local/Cellar/ccache/
3.1.8
[20:37] andy@voodoo:~/Works/Media/emitron/lib/pipetoys
$ ls -l /usr/local/bin/ccache 
lrwxr-xr-x  1 andy  staff  33 16 Dec 20:37 /usr/local/bin/ccache -> ../Cellar/ccache/3.1.8/bin/ccache
[20:38] andy@voodoo:~/Works/Media/emitron/lib/pipetoys
$ readlink $( which ccache )
../Cellar/ccache/3.1.8/bin/ccache


# vim:ts=2:sw=2:sts=2:et:ft=sh

