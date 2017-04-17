# MAINTAINER https://github.com/cloneMe
. "$INCLUDE"/install.sh
. "$INCLUDE"/https.sh
. "$INCLUDE"/functions.sh

######################################################""
############# DO NOT UPDATE
######################################################""
users="htpasswd.txt"

if [ ! -f "$users" ]; then
  printf "foo:$(openssl passwd -crypt foo)\n" >> "$users"
  printf "bar:$(openssl passwd -crypt foo)\n" >> "$users"
fi

# for windows users
if [ ${here:0:3} = "/C/" ]; then
 here=/c${here:2}
 seedboxFiles=/c${seedboxFiles:2}
fi

echo "New folders will be created in $seedboxFiles"
#echo "$here"

tmpFolder="$here/$INCLUDE/tmp"
mkdir -p $tmpFolder

useSSL="false"
if [ "$useHttps" = "self" ]; then
 useSSL="true"
 if [ ! -f "ssl/nginx.key" ]; then
  self
 fi
elif [ "$useHttps" = "letsEncrypt" ]; then
 letsencrypt
 if [ -f "ssl/privkey.pem" ]; then
  useSSL="true"
 fi
elif [ "$useHttps" = "provided" ]; then
 if [[ -f "ssl/nginx.key" || -f "ssl/privkey.pem" ]]; then
  useSSL="true"
 else
   echo "error: ssl/nginx.key or ssl/privkey.pem not found. Provide these files then run this script again."
 fi
fi
httpMode="http"
if [ "$useSSL" = "true" ]; then
 httpMode="https"
fi

if [[ "$openvpn" = "true" && ! -d "$seedboxFiles/config/openvpn" ]]; then
   OVPN_DATA="$seedboxFiles/config/openvpn:/etc/openvpn"
   docker run -v "$OVPN_DATA" --rm kylemanna/openvpn ovpn_genconfig -u udp://"$server_name"
   docker run -v "$OVPN_DATA" --rm -it kylemanna/openvpn ovpn_initpki
   echo "#!/bin/bash
   # Generate a client certificate without a passphrase
docker run -v $OVPN_DATA --rm -it kylemanna/openvpn easyrsa build-client-full \$1 nopass
# Retrieve the client configuration with embedded certificates
docker run -v $OVPN_DATA --rm kylemanna/openvpn ovpn_getclient \$1 > \$1.ovpn
" > createVpnFor.sh
    chmod +x createVpnFor.sh
fi


sickrage_conf=""
web_port=20001

cp_dc_conf=""
cp_ng_conf=""

while IFS='' read -r line || [[ -n "$line" ]]; do
    #echo "Text read from file: $line"
    IFS=':' read -r userName string <<< "$line"
  #sickrage
  sickrage_conf=$(addProxy_pass "$sickrage_conf" "seedboxdocker_sickrage" "$web_port" "$userName")
  web_port=$[$web_port+1]
  #CouchPotato
  if [ "$couchpotato" = "true" ]; then
    cp_ng_conf=$(addProxy_pass "$cp_ng_conf" "seedboxdocker_couchpotato_$userName" "5050" "$userName")
    cp_dc_conf=$(addCouchPotato "$cp_dc_conf" "$userName")
    depends_on="$depends_on       - couchpotato_$userName\n"
  fi
  generateHelp "$userName"
done < "$users"
generateURL

sed -e 's|#sickrage_conf#|'"$sickrage_conf"'|g' -e 's|#couchpotato_conf#|'"$cp_ng_conf"'|g' -e "s|#server_name#|$server_name|g" ./"$INCLUDE"/nginx.conf.tmpl > ./nginx.conf

sed -e 's|#couckPotato_conf#|'"$cp_dc_conf"'|g' -e "s|#pwd#|$here|g"  -e "s|#seedboxFolder#|$seedboxFiles|g" -e "s|#server_name#|$server_name|g" ./"$INCLUDE"/docker-compose.yml.tmpl > ./docker-compose.yml
sed -i 's|#PLEX_USERNAME#|'"$plexUser"'|g' docker-compose.yml
sed -i 's|#PLEX_PASSWORD#|'"$plexPass"'|g' docker-compose.yml

#Delete undeployed servers
depends_on="$depends_on$(delete "plexpy" $plexpy)"
depends_on="$depends_on$(delete "plex" $plex)"
depends_on="$depends_on$(delete "emby" $emby)"
depends_on="$depends_on$(delete "limbomedia" $limbomedia)"
depends_on="$depends_on$(delete "libresonic" $libresonic)"
depends_on="$depends_on$(delete "ubooquity" $ubooquity)"
depends_on="$depends_on$(delete "sickrage" $sickrage)"
depends_on="$depends_on$(delete "radarr" $radarr)"
depends_on="$depends_on$(delete "mylar" $mylar)"
depends_on="$depends_on$(delete "rtorrent" $rtorrent)"
depends_on="$depends_on$(delete "jackett" $jackett)"
depends_on="$depends_on$(delete "headphones" $headphones)"
delete "couchpotato" $couchpotato > /dev/null
delete "openvpn" $openvpn > /dev/null
delete "teamspeak" $teamspeak > /dev/null
delete "pureftpd" $pureftpd > /dev/null
delete "fail2ban" $fail2ban > /dev/null
delete "subliminal" $subliminal > /dev/null
depends_on="$depends_on$(delete "cloud" $cloud)"
depends_on="$depends_on$(delete "explorer" $explorer)"
depends_on="$depends_on$(delete "filemanager" $filemanager)"
depends_on="$depends_on$(delete "syncthing" $syncthing)"
depends_on="$depends_on$(delete "glances" $glances)"
depends_on="$depends_on$(delete "muximux" $muximux)"
depends_on="$depends_on$(delete "htpcmanager" $htpcmanager)"
depends_on="$depends_on$(delete "portainer" $portainer)"
depends_on="$depends_on$(delete "watchtower" $watchtower)"
depends_on="$depends_on$(delete "elfinder" $elfinder)"
depends_on="$depends_on$(delete "butterfly" $butterfly)"

if [ "$depends_on" != "" ]; then
 depends_on="    depends_on: \n$depends_on"
fi

sed -i 's|#useSSL#|'"$useSSL"'|g' docker-compose.yml
sed -i 's|#TZ#|'"$TZ"'|g' docker-compose.yml
sed -i 's|#frontend_dependencies#|'"$depends_on"'|g' docker-compose.yml
sed -i "s|#plex_config#|$plex_config|g" docker-compose.yml
sed -i "s|#emby_config#|$emby_config|g" docker-compose.yml
sed -i "s|#headphones_config#|$headphones_config|g" docker-compose.yml
sed -i "s|#mux_config#|$mux_config|g" docker-compose.yml

if [[ "$headphones" = "true" && ! -f $seedboxFiles/config/headphones/headphones.ini ]]; then
 mkdir -p $seedboxFiles/config/headphones
 cp $INCLUDE/headphones.ini $seedboxFiles/config/headphones/headphones.ini
fi
#First idea: ln /var/log/auth.log $seedboxFiles/log/ssh/host.log
# will not work because you can have a log rotation.
# Fix : use /var/log in the fail2ban container
if [ ! -f /var/log/auth.log ]; then
 # in case: if /var/log/auth.log does not exist, use a fake
 touch $tmpFolder/auth.log
 sed -i 's|/var/log:/host|'"$tmpFolder"':/host|g' docker-compose.yml
fi


