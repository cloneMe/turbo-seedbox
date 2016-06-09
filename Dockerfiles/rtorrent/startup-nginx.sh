#!/bin/bash

set -x

chown -R www-data:www-data /var/www/rutorrent
cp /.htpasswd /var/www/rutorrent/
mkdir -p /downloads/rutorrent/torrents
chown -R www-data:www-data /downloads/rutorrent

rm -f /etc/nginx/sites-enabled/*


rm /var/www/rutorrent/.htpasswd


# Basic auth enabled by default
site=rutorrent-basic.nginx




if $USE_SSL ; then
  site=rutorrent-tls.nginx
  if [[ -f /etc/nginx/ssl/dhparams.pem ]]; then
    sed -e 's/nginx.crt/fullchain.pem/g' -e 's/nginx.key/privkey.pem/g' -e 's/#ssl_dhparam/ssl_dhparam/g'  /root/$site > /etc/nginx/sites-enabled/$site
  
  elif [[ -f /etc/nginx/ssl/nginx.crt && -f /etc/nginx/ssl/nginx.key ]]; then
    cp /root/$site /etc/nginx/sites-enabled/
  fi
else 
 cp /root/$site /etc/nginx/sites-enabled/
fi



# Check if .htpasswd presents
if [ -e /.htpasswd ]; then
cp /.htpasswd /var/www/rutorrent/ && chmod 755 /var/www/rutorrent/.htpasswd && chown www-data:www-data /var/www/rutorrent/.htpasswd
else
# disable basic auth
sed -i 's/auth_basic/#auth_basic/g' /etc/nginx/sites-enabled/$site
fi

nginx -g "daemon off;"

