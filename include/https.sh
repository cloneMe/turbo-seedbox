#!/bin/bash

function letsencrypt ()
{
mkdir -p ssl
mkdir -p $tmpFolder/letsencrypt/defaults
URL=$server_name
if [ ! -z $SUBDOMAINS ]; then
# see https://github.com/aptalca/docker-webserver/blob/master/firstrun.sh
  echo "SUBDOMAINS entered, processing"
  for job in $(echo $SUBDOMAINS | tr "," " "); do
    export SUBDOMAINS2="$SUBDOMAINS2 -d "$job"."$URL""
  done
  echo "Sub-domains processed are:" $SUBDOMAINS2
  echo -e "SUBDOMAINS2=\"$SUBDOMAINS2\" URL=\"$URL\" EMAIL=\"$EMAIL\"" > $tmpFolder/letsencrypt/defaults/domains.conf
else
  echo "No subdomains defined"
  echo -e "URL=\"$URL\" EMAIL=\"$EMAIL\"" > $tmpFolder/letsencrypt/defaults/domains.conf
fi

if [ ! -f $tmpFolder/letsencrypt/config/donoteditthisfile.conf ]; then
 mkdir -p $tmpFolder/letsencrypt/config
 touch $tmpFolder/letsencrypt/config/donoteditthisfile.conf
fi

. $tmpFolder/letsencrypt/config/donoteditthisfile.conf
#use quotes to fix:
#include/https.sh: line 29: [: files,rtorrent,sickrage,couchpotato,plex,explorer: unary operator expected

if [ ! "$URL" = "$ORIGURL" ] || [ ! "$SUBDOMAINS" = "$ORIGSUBDOMAINS" ]; then
  if [ -d $tmpFolder/letsencrypt/$URL ]; then
  echo "Different sub/domains entered than what was used before. Revoking and deleting existing certificate, and an updated one will be created"
  docker run -it --rm \
    -v $tmpFolder/letsencrypt:/etc/letsencrypt \
    -p 8080:80 -p 8443:443 \
    xataz/letsencrypt \
        revoke --non-interactive --cert-path /etc/letsencrypt/live/$URL/fullchain.pem
  fi
  rm -rf $tmpFolder/letsencrypt/live/$URL
  rm -rf /ssl/*.pem
  echo -e "ORIGURL=\"$URL\" ORIGSUBDOMAINS=\"$SUBDOMAINS\"" > $tmpFolder/letsencrypt/config/donoteditthisfile.conf
fi
chmod +x $INCLUDE/letsencrypt.sh 
echo "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" > $tmpFolder/letsencryptcron.conf
here2=`pwd`
echo "0 2 * * * $here/$INCLUDE/letsencrypt.sh $tmpFolder $here2/ssl/ >> $tmpFolder/letsencrypt.log 2>&1" >> $tmpFolder/letsencryptcron.conf
crontab $tmpFolder/letsencryptcron.conf
if [[ ! -f ssl/dhparams.pem ]]; then
   openssl dhparam -out ssl/dhparams.pem 4096 &
fi
# todo: call letsencrypt.sh $tmpFolder $here2/ssl/
}

function self ()
{
mkdir -p ssl
openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
      -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=*.$server_name" \
      -keyout ssl/nginx.key -out ssl/nginx.crt

}

