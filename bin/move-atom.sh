#!/bin/bash

cd ~
git pull
git clone git@github.com:AndyA/my-atom-config.git
rsync -avP ~/.atom/ ~/my-atom-config/
rm -rf ~/.atom
mv ~/my-atom-config ~/.atom

# vim:ts=2:sw=2:sts=2:et:ft=sh

