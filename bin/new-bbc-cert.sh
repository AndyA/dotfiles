#!/bin/bash

STORE=~/.keystore
DROP=~/Dropbox/Temp/armsta04.p12
PKCS12=$STORE/andy.p12
CRT=$STORE/andy.crt
KEY=$STORE/andy.key

mkdir -p $STORE

STUNNEL_CFG=/etc/stunnel
[ -d /usr/local/etc/stunnel ] && STUNNEL_CFG=/usr/local/etc/stunnel

cp $DROP $PKCS12
openssl pkcs12 -in $PKCS12 -out $KEY -nodes -clcerts -nocerts
openssl pkcs12 -in $PKCS12 -out $CRT -nodes -clcerts -nokeys

# Copy some other places
cp $PKCS12 ~/.subversion/certs
sudo cp $CRT $KEY $STUNNEL_CFG
sudo chown root:admin $STUNNEL_CFG/andy.{crt,key}
sudo chmod 400 $STUNNEL_CFG/andy.{crt,key}

# vim:ts=2:sw=2:sts=2:et:ft=sh

