#!/bin/sh
VERSION=1.6.9
PREFIX=/alt/local
TEMP="/tmp/svn.$$"
HERE=$(pwd)
mkdir -p $TEMP
cd $TEMP
sudo apt-get update
sudo apt-get install build-essential openssl ssh expat libxyssl-dev libssl-dev
sudo apt-get remove subversion
sudo dpkg --purge subversion
wget http://subversion.tigris.org/downloads/subversion-$VERSION.tar.gz
wget http://subversion.tigris.org/downloads/subversion-deps-$VERSION.tar.gz
tar xvfz subversion-$VERSION.tar.gz
tar xvfz subversion-deps-$VERSION.tar.gz
cd subversion-$VERSION/neon/
./configure --prefix=$PREFIX --with-ssl --with-pic
make
sudo make install
cd ..
rm -rf neon
./configure --prefix=$PREFIX --with-ssl --with-neon=$PREFIX
make
sudo make install
cd $HERE
rm -rf $TEMP
exit 0
