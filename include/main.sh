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

useSSL="false"
if [ "$useHttps" = "self" ]; then
 useSSL="true"
 if [ ! -f "ssl/nginx.key" ]; then
  self
 fi
fi

 docker build -t$mode kelvinchen/seedbox:base  Dockerfiles/base
 docker build -t$mode kelvinchen/seedbox:frontend2   Dockerfiles/frontend    &
if [ "$rtorrent" = "true" ]; then
 docker build -t$mode nilteam/rtorrent2              Dockerfiles/rtorrent    &
fi
if [ "$sickrage" = "true" ]; then
 docker build -t$mode kelvinchen/seedbox:sickrage2   Dockerfiles/sickrage    &
fi
if [ "$couchPotato" = "true" ]; then
 docker build -t$mode nilteam/couchpotato           Dockerfiles/couchpotato &
fi

if [ "$pureftpd" = "true" ]; then
 docker build -t$mode nilteam/pureftpd           Dockerfiles/pureftpd &
fi
if [ "$openvpn" = "true" ]; then
 docker build -t$mode kelvinchen/seedbox:openvpn           Dockerfiles/openvpn &
fi
if [ "$teamspeak" = "true" ]; then
 docker build -t$mode nilteam/teamspeak           Dockerfiles/teamspeak &
fi

if [[ "$filemanager" = "true" && ! -f "Dockerfiles/filemanager/Filemanager-master.zip" ]]; then
# download https://github.com/simogeo/Filemanager/archive/master.zip
  if hash curl 2>/dev/null; then
   curl  https://codeload.github.com/simogeo/Filemanager/zip/master > Dockerfiles/filemanager/Filemanager-master.zip
  else
   wget -O Dockerfiles/filemanager/Filemanager-master.zip https://codeload.github.com/simogeo/Filemanager/zip/master
  fi
  docker build -t nilteam/filemanager2           Dockerfiles/filemanager
fi
if [[ "$explorer" = "true" && ! -d "Dockerfiles/explorer" ]]; then
  git clone --depth=1 https://github.com/soyuka/explorer.git Dockerfiles/explorer
  docker build -t nilteam/explorer           Dockerfiles/explorer
fi

function addProxy_pass {
local  result="$1"
result="$result                       if (\$remote_user = \"$4\") {\n"
result="$result                             proxy_pass http://$2:$3;\n"
result="$result                            break;\n              }\n"
echo "$result"
}
function addCouchPotato {
local  result="$1\n"
result="$result couchPotato_$2:\n"
result="$result    image: nilteam/couchpotato\n"
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
function delete {
if [ "$2" = "true" ]; then
 sed -i "/#$1_end#/d" docker-compose.yml
 sed -i "/#$1_end#/d" nginx.conf
 echo "       - $1\n"
else
#Delete the lines starting from the pattern 'plex' till ,#plex_end#...

  local l=$(grep -n " $1:" docker-compose.yml | grep -Eo '^[^:]+' )
  if [ "$l" = "" ]; then
   sed -i "/#$1_end#/d" docker-compose.yml
  else
   sed -i "$l,/#$1_end#/d" docker-compose.yml
  fi
  l=$(grep -n "upstream $1" nginx.conf | grep -Eo '^[^:]+' )
  if [ "$l" = "" ]; then
   sed -i "/#$1_end#/d" nginx.conf
  else
   sed -i "$l,/#$1_end#/d" nginx.conf
  fi
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
	if [ "$couchPotato" = "true" ]; then
		cp_ng_conf=$(addProxy_pass "$cp_ng_conf" "seedboxdocker_couchpotato_$userName" "5050" "$userName")
		cp_dc_conf=$(addCouchPotato "$cp_dc_conf" "$userName")
		depends_on="$depends_on       - couchPotato_$userName\n"
	fi
done < "$users"


sed -e 's|#sickrage_conf#|'"$sickrage_conf"'|g' -e 's|#couchpotato_conf#|'"$cp_ng_conf"'|g' -e "s|#server_name#|$server_name|g" ./"$INCLUDE"/nginx.conf.tmpl > ./nginx.conf

sed -e 's|#couckPotato_conf#|'"$cp_dc_conf"'|g' -e "s|#pwd#|$here|g"  -e "s|#seedboxFolder#|$seedboxFiles|g" -e "s|#server_name#|$server_name|g" -e "s|#plex_config#|$plex_config|g" ./"$INCLUDE"/docker-compose.yml.tmpl > ./docker-compose.yml

#Delete undeployed servers
depends_on="$depends_on$(delete "plex" $plex)"
depends_on="$depends_on$(delete "sickrage" $sickrage)"
depends_on="$depends_on$(delete "rtorrent" $rtorrent)"
delete "couchPotato" $couchPotato > /dev/null
delete "openvpn" $openvpn > /dev/null
delete "teamspeak" $teamspeak > /dev/null
depends_on="$depends_on$(delete "explorer" $explorer)"
delete "pureftpd" $pureftpd > /dev/null
depends_on="$depends_on$(delete "filemanager" $filemanager)"
delete "fail2ban" $fail2ban > /dev/null

if [ "$depends_on" != "" ]; then
 depends_on="    depends_on: \n$depends_on"
fi

sed -i 's|#useSSL#|'"$useSSL"'|g' docker-compose.yml
sed -i 's|#TZ#|'"$TZ"'|g' docker-compose.yml
sed -i 's|#frontend_dependencies#|'"$depends_on"'|g' docker-compose.yml


#First idea: ln /var/log/auth.log $seedboxFiles/log/ssh/host.log
# will not work because you can have a log rotation.
# Fix : use /var/log in the fail2ban container
if [ ! -f /var/log/auth.log ]; then
 # in case: if /var/log/auth.log does not exist, use a fake
 mkdir -p $here/include/tmp
 touch $here/include/tmp/auth.log
 sed -i 's|/var/log:/host|'"$here"'/include/tmp:/host|g' docker-compose.yml
fi
