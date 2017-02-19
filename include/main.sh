# MAINTAINER https://github.com/cloneMe
. "$INCLUDE"/install.sh
. "$INCLUDE"/https.sh

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

echo $seedboxFiles
echo $here

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


function addProxy_pass {
local  result="$1"
result="$result        if (\$remote_user = \"$4\") {\n"
result="$result          proxy_pass http://$2:$3;\n"
result="$result        break;\n        }\n"
echo "$result"
}
function addCouchPotato {
local  result="$1\n"
result="$result couchpotato_$2:\n"
result="$result    image: funtwo/couchpotato:latest-dev\n"
result="$result    container_name: seedboxdocker_couchpotato_$2\n"
result="$result    restart: always\n"
result="$result    networks: \n"
result="$result      - seedbox\n"
result="$result    mem_limit: 300m\n"
result="$result    memswap_limit: 500m\n"
result="$result    volumes:\n"
result="$result        - #seedboxFolder#/config/couchpotato_$2/:/config\n"
result="$result        - #seedboxFolder#/downloads/:/torrents\n"

echo "$result"
}

function addCustomProviders {
  git clone --depth=1 https://github.com/djoole/couchpotato.provider.t411.git /$tmpFolder/frenchproviders &> /dev/null 
  mkdir -p $seedboxFiles/config/couchpotato_$1/custom_plugins
  cp -r /$tmpFolder/frenchproviders/t411 $seedboxFiles/config/couchpotato_$1/custom_plugins/t411
  rm -rf /$tmpFolder/frenchproviders
}

function delete {
#Delete the lines starting from the pattern 'servicename' till ,#end_servicename#...
if [ "$2" = "f" ]; then
  local l=$(grep -n "#start_$1" docker-compose.yml | grep -Eo '^[^:]+' )
  if [ "$l" != "" ]; then
   sed -i "$l,/#end_$1/d" docker-compose.yml
  fi

  l=$(grep -n "#start_$1" services.conf | grep -Eo '^[^:]+' | head -1)
  while [ "$l" != "" ]; do
    sed -i "$l,/#end_$1/d" services.conf
    l=$(grep -n "#start_$1" services.conf | grep -Eo '^[^:]+' | head -1)
  done
else
 echo "       - $1\n"
fi
}

function generateHelp {
mkdir -p help
userUp=$(echo "$1" | tr '[:lower:]' '[:upper:]')

echo "
5.1 Sickrage

Open \"Search Settings\" and click on the \"torrent search\" tab. Choose \"rtorrent\" and put following values:

    Search Settings: $httpMode://rtorrent.$server_name/RPC$userUp
    Http auth : basic
    Set userName & password
    Download file location: /downloads/rtorrent/$1/watch

Open the \"Post Processing\" menu, activate it and set following values:
    /downloads/rtorrent/$1/watch
    Processing Method: hard link

When adding a a new serie, set /downloads/rtorrent/$1/serie as the parent folder (step 2).

5.2 Couchpotato

It is not necessary to set username & password. Activate \"rtorrent\" and put following values:

    Host: $httpMode://rtorrent.$server_name
    Rpc Url: /RPC$userUp
    Http auth : basic
    Set userName & password
    Download file location: /downloads/rtorrent/$1/film
  
Plex
Issue : Plex NEVER asks for authentication. Everybody can access to it :/
nano $seedboxFiles/config/plex/Library/Application\ Support/Plex\ Media\ Server/Preferences.xml
There is \"Disable Remote Security=1\". Changed that 1 to a 0 and restarted my Plex : docker restart seedboxdocker_plex_1
Src : https://forums.plex.tv/discussion/132399/plex-security-issue

" > help/$1.txt
}

function generateURL {
mkdir -p help
echo "
Following services are deployed:
" > help/URL.txt
if [ "$portainer" = "true" ]; then
   echo "
portainer
$httpMode://$server_name/portainer
" >> help/URL.txt
fi
if [ "$rtorrent" = "true" ]; then
   echo "
rtorrent
$httpMode://$server_name/rtorrent
" >> help/URL.txt
fi
if [ "$sickrage" = "true" ]; then
   echo "
sickrage
$httpMode://$server_name/sickrage
" >> help/URL.txt
fi
if [ "$couchpotato" = "true" ]; then
   echo "
couchpotato
$httpMode://$server_name/couchpotato
" >> help/URL.txt
fi
if [ "$headphones" = "true" ]; then
   echo "
headphones
$httpMode://$server_name/headphones
" >> help/URL.txt
fi
if [ "$plex" = "true" ]; then
   echo "
Plex
$httpMode://$server_name/plex
" >> help/URL.txt
fi
if [ "$emby" = "true" ]; then
   echo "
emby
$httpMode://$server_name/emby
" >> help/URL.txt
fi
if [ "$limbomedia" = "true" ]; then
   echo "
limbomedia
$httpMode://$server_name/media
" >> help/URL.txt
fi
if [ "$cloud" = "true" ]; then
   echo "
cloud
$httpMode://$server_name/cloud
" >> help/URL.txt
fi
if [ "$pureftpd" = "true" ]; then
   echo "
muximux
$httpMode:/$server_name/muximux
" >> help/URL.txt
fi
if [ "$muximux" = "true" ]; then
   echo "
glances
$httpMode://$server_name/glances
" >> help/URL.txt
fi
if [ "$glances" = "true" ]; then
   echo "
plexpy
$httpMode://$server_name/plexpy
" >> help/URL.txt
fi
if [ "$plexpy" = "true" ]; then
   echo "
syncthing
$httpMode://$server_name/syncthing
" >> help/URL.txt
fi
if [ "$syncthing" = "true" ]; then
   echo "
FTP
ftp://$server_name
" >> help/URL.txt
fi
}

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
    addCustomProviders $userName
  fi
  generateHelp "$userName"
done < "$users"
generateURL

sed -e 's|#sickrage_conf#|'"$sickrage_conf"'|g' -e 's|#couchpotato_conf#|'"$cp_ng_conf"'|g' -e "s|#server_name#|$server_name|g" ./"$INCLUDE"/services.conf.tmpl > ./services.conf

sed -e 's|#couckPotato_conf#|'"$cp_dc_conf"'|g' -e "s|#pwd#|$here|g"  -e "s|#seedboxFolder#|$seedboxFiles|g" -e "s|#server_name#|$server_name|g" ./"$INCLUDE"/docker-compose.yml.tmpl > ./docker-compose.yml
sed -i 's|#PLEX_USERNAME#|'"$plexUser"'|g' docker-compose.yml
sed -i 's|#PLEX_PASSWORD#|'"$plexPass"'|g' docker-compose.yml

#Delete undeployed servers
depends_on="$depends_on$(delete "plex" $plex)"
depends_on="$depends_on$(delete "emby" $emby)"
depends_on="$depends_on$(delete "limbomedia" $limbomedia)"
depends_on="$depends_on$(delete "sickrage" $sickrage)"
depends_on="$depends_on$(delete "rtorrent" $rtorrent)"
depends_on="$depends_on$(delete "headphones" $headphones)"
delete "couchpotato" $couchpotato > /dev/null
delete "openvpn" $openvpn > /dev/null
delete "teamspeak" $teamspeak > /dev/null
delete "pureftpd" $pureftpd > /dev/null
delete "fail2ban" $fail2ban > /dev/null
depends_on="$depends_on$(delete "cloud" $cloud)"
depends_on="$depends_on$(delete "syncthing" $syncthing)"
depends_on="$depends_on$(delete "plexpy" $plexpy)"
depends_on="$depends_on$(delete "glances" $glances)"
depends_on="$depends_on$(delete "muximux" $muximux)"
depends_on="$depends_on$(delete "portainer" $portainer)"

if [ "$depends_on" != "" ]; then
 depends_on="    depends_on: \n$depends_on"
fi

sed -i 's|#useSSL#|'"$useSSL"'|g' docker-compose.yml
sed -i 's|#TZ#|'"$TZ"'|g' docker-compose.yml
sed -i 's|#frontend_dependencies#|'"$depends_on"'|g' docker-compose.yml
sed -i "s|#plex_config#|$plex_config|g" docker-compose.yml
sed -i "s|#emby_config#|$emby_config|g" docker-compose.yml
sed -i "s|#headphones_config#|$headphones_config|g" docker-compose.yml

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
