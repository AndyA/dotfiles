#!/bin/sh

STORE=~/.keystore
DROP=~/Desktop/andy.p12
PKCS12=$STORE/andy.p12
CRT=$STORE/andy.crt
KEY=$STORE/andy.key

cp $DROP $PKCS12
openssl pkcs12 -in $PKCS12 -out $KEY -nodes -clcerts -nocerts
openssl pkcs12 -in $PKCS12 -out $CRT -nodes -clcerts -nokeys

# Copy some other places
cp $PKCS12 ~/.subversion/certs
sudo cp $CRT $KEY /alt/local/etc/stunnel
sudo chown root:admin /alt/local/etc/stunnel/andy.{crt,key}
sudo chmod 400 /alt/local/etc/stunnel/andy.{crt,key}

# vim:ts=2:sw=2:sts=2:et:ft=sh

