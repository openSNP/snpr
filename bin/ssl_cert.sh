#!/bin/bash

echo 'Cloning dehydrated...'
cd /home
git clone https://github.com/lukas2511/dehydrated.git --branch=v0.4.0 --depth=1
cd dehydrated

cp docs/examples/config config
mkdir -p /home/app/snpr/public/.well-known/acme-challenge

# by default, WELLKNOWN is commented out, so just set the variable
echo 'WELLKNOWN=/home/app/snpr/public/.well-known/acme-challenge' >> config

echo 'opensnp.org www.opensnp.org' > domains.txt

echo 'Starting dehydrated...'

./dehydrated --cron --accept-terms


echo 'Done, now copying keys'
cp /etc/ssl/private/opensnp.org.key /etc/ssl/private/opensnp.org.key.old
cp /home/dehydrated/certs/opensnp.org/privkey.pem /etc/ssl/private/opensnp.org.key
cp /etc/ssl/certs/opensnp.org.crt /etc/ssl/certs/opensnp.org.crt.old
cp /home/dehydrated/certs/opensnp.org/fullchain.pem /etc/ssl/certs/opensnp.org.crt

service nginx restart

