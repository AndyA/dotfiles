#!/bin/bash
# Mon script d'installation FFMpeg + X264 
#
# Nicolargo - 04/2010
#
# Based on: http://ubuntuforums.org/showthread.php?t=786095
# !!! Attention gestion des accents dans grep Révision !!!
# Revert change: sudo apt-get remove x264 ffmpeg build-essential subversion git-core checkinstall yasm texi2html libfaac-dev libfaad-dev libmp3lame-dev libsdl1.2-dev libtheora-dev libx11-dev libxfixes-dev libxvidcore-dev zlib1g-dev
#
# Syntaxe: # ./ffmpeginstall.sh
#
# GPL
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Library General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor Boston, MA 02110-1301,  USA
set -e
VERSION="0.1"
LAMEVERSION="3.98.4"

BUILDDIR="/tmp/build-ffmpeg-$$"
mkdir $BUILDDIR
cd $BUILDDIR

sudo apt-get remove ffmpeg x264 libx264-dev libmp3lame-dev lame-ffmpeg libvpx qt-faststart
sudo apt-get update
sudo apt-get install build-essential subversion git-core checkinstall yasm texi2html libfaac-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libsdl1.2-dev libtheora-dev libx11-dev libxfixes-dev libxvidcore-dev zlib1g-dev nasm

cd $BUILDDIR
git clone git://git.videolan.org/x264.git
cd x264
./configure
make
sudo checkinstall --pkgname=x264 --pkgversion "2:0.`grep X264_BUILD x264.h -m1 | cut -d' ' -f3`.`git rev-list HEAD | wc -l`+git`git rev-list HEAD -n 1 | head -c 7`" --backup=no --default

cd $BUILDDIR
wget http://downloads.sourceforge.net/project/lame/lame/$LAMEVERSION/lame-$LAMEVERSION.tar.gz
tar xzvf lame-$LAMEVERSION.tar.gz
cd lame-$LAMEVERSION
./configure --enable-nasm --disable-shared
make
sudo checkinstall --pkgname=lame-ffmpeg --pkgversion=$LAMEVERSION --backup=no --default --deldoc=yes

cd $BUILDDIR
git clone git://review.webmproject.org/libvpx.git
cd libvpx
./configure
make
sudo checkinstall --pkgname=libvpx --pkgversion="`date +%Y%m%d%H%M`-git" --backup=no --default --deldoc=yes

cd $BUILDDIR
svn checkout svn://svn.ffmpeg.org/ffmpeg/trunk ffmpeg
cd ffmpeg
./configure --enable-gpl --enable-version3 --enable-nonfree --enable-postproc --enable-pthreads --enable-libfaac --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libtheora --enable-libx264 --enable-libxvid --enable-x11grab --enable-libmp3lame --enable-libvpx
make
sudo checkinstall --pkgname=ffmpeg --pkgversion "4:SVN-r`svn info | grep vision | awk '{ print $NF }'`" --backup=no --default

make tools/qt-faststart
sudo checkinstall --pkgname=qt-faststart --pkgversion "4:SVN-r`svn info | grep Revision | \
      awk '{ print $NF }'`" --backup=no --default --deldoc=yes install -D -m755 \
      tools/qt-faststart /usr/local/bin/qt-faststart

hash x264 ffmpeg qt-faststart

