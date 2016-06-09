#!/bin/bash
cp /template/rutorrent-basic.nginx /root/
cp /template/rutorrent-tls.nginx /root/
cp /template/supervisord.conf /etc/supervisor/conf.d/

mkdir -p /log/app
#for rtorrent
mkdir -p /downloads/torrents/config/torrents 
chown -R www-data:www-data /downloads/torrents/config
mkdir -p /config/rtorrent
#for each user
dht_port=49162
scgi_port=5001
while IFS='' read -r line || [[ -n "$line" ]]; do
    #echo "Text read from file: $line"
    IFS=':' read -r userName string <<< "$line"
    mkdir -p /home/$userName
	mkdir -p /var/www/rutorrent/conf/users/$userName
    userUp=$(echo "$userName" | tr '[:lower:]' '[:upper:]')

     dht_port2=$[$dht_port+1]
     sed -e "s/#user#/$userName/g" /template/startup-rtorrent-user.sh > /root/startup-rtorrent-$userName.sh
	 chmod +x /root/startup-rtorrent-$userName.sh
     sed -e "s/#user#/$userName/g" -e "s/#userScgi#/$scgi_port/g" -e "s/#userDht#/$dht_port/g" -e "s/#userDht2#/$dht_port2/g" /template/.rtorrent.rc.tmpl > /home/$userName/.rtorrent.rc
     sed -e "s/#user#/$userName/g" -e "s/#userScgi#/$scgi_port/g" -e "s/#userDht#/$dht_port/g" -e "s/#userDht2#/$dht_port2/g" -e "s/#userUpper#/$userUp/g" /template/config.php.tmpl > /var/www/rutorrent/conf/users/$userName/config.php
     cp /template/plugins.ini /var/www/rutorrent/conf/users/$userName/

    sed -e "s/#user#/$userName/g" /template/supervisord.tmpl >> /etc/supervisor/conf.d/supervisord.conf
    sed -e "s/#userUpper#/$userUp/g" -e "s/#userScgi#/$scgi_port/g" /template/nginx.tmpl >> /root/rutorrent-basic.nginx
	sed -e "s/#userUpper#/$userUp/g" -e "s/#userScgi#/$scgi_port/g" /template/nginx.tmpl >> /root/rutorrent-tls.nginx
    dht_port=$[$dht_port+2]
    scgi_port=$[$scgi_port+1]
    
done < "$1"
echo "}" >> /root/rutorrent-basic.nginx
echo "}" >> /root/rutorrent-tls.nginx


echo "done"
supervisord