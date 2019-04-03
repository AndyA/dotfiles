#!/bin/bash

set -e

KEYBASE_DEB="/nfs/data/scratch/tmp/keybase_amd64.deb"

if [[ ! -e $KEYBASE_DEB ]]; then
  echo "Fetching keybase"
  curl --remote-name https://prerelease.keybase.io/keybase_amd64.deb
  KEYBASE_DEB="keybase_amd64.deb"
fi

sudo dpkg -i "$KEYBASE_DEB" || echo "IGNORE THOSE ERRORS! We're about to fix them..."
sudo apt-get install -fy

keybase ctl init

systemctl --user enable keybase.service
systemctl --user enable kbfs.service
systemctl --user enable keybase-redirector.service

loginctl enable-linger

systemctl --user start keybase.service
systemctl --user start kbfs.service
systemctl --user start keybase-redirector.service

# vim:ts=2:sw=2:sts=2:et:ft=sh

