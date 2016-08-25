#!/bin/bash
# thanks to https://github.com/aptalca/docker-webserver/blob/master/defaults/letsencrypt.sh
echo "<------------------------------------------------->"
echo
echo "<------------------------------------------------->"
echo "cronjob running at "$(date)
tmpFolder=$1
sslFolder=$2

. $tmpFolder/letsencrypt/defaults/domains.conf

echo "URL is" $URL
echo "Subdomains are" $SUBDOMAINS2
echo "deciding whether to renew the cert(s)"
if [ -f "$tmpFolder/letsencrypt/live/$URL/fullchain.pem" ]; then
  EXP=$(date -d "`openssl x509 -in $tmpFolder/letsencrypt/live/$URL/fullchain.pem -text -noout|grep "Not After"|cut -c 25-`" +%s)
  DATENOW=$(date -d "now" +%s)
  DAYS_EXP=$(( ( $EXP - $DATENOW ) / 86400 ))
  if [[ $DAYS_EXP -gt 30 ]]; then
    echo "Existing certificate is still valid for another $DAYS_EXP day(s); skipping renewal."
    exit 0
  else
    echo "Preparing to renew certificate that is older than 60 days"
  fi
else
  echo "Preparing to generate server certificate for the first time"
fi
echo "Temporarily stopping Nginx"
docker stop seedboxdocker_front_1
echo "Generating/Renewing certificate"
docker run -i --rm \
    -v $tmpFolder/letsencrypt:/etc/letsencrypt \
    -p 80:80 -p 443:443 \
    xataz/letsencrypt \
        certonly --non-interactive --renew-by-default --standalone --standalone-supported-challenges tls-sni-01 --rsa-key-size 4096 --email $EMAIL --agree-tos -d $URL $SUBDOMAINS2
cp $tmpFolder/letsencrypt/live/$URL/* $sslFolder
echo "Restarting web server"
docker start seedboxdocker_front_1