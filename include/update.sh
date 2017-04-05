
function addCustomProviders {
  echo "addCustomProviders for $1"
  mkdir -p $seedboxFiles/config/couchpotato_$1/custom_plugins/torrent9
  #t411
  cp -r $tmpFolder/frenchproviders/t411 $seedboxFiles/config/couchpotato_$1/custom_plugins/t411
  #torrent9
  cp $tmpFolder/torrent9/*.py $seedboxFiles/config/couchpotato_$1/custom_plugins/torrent9
  
}
if [ "$jackett" = "true" ]; then
 url="$(grep BasePathOverride $seedboxFiles/config/jackett/Jackett/ServerConfig.json)"
 if [ "$url" != '  "BasePathOverride": "/jackett"' ]; then
   sed -i 's|'"$url"'|  "BasePathOverride": "/jackett"|g' $seedboxFiles/config/jackett/Jackett/ServerConfig.json
  fi
fi
if [ "$mylar" = "true" ]; then
 url="$(grep http_root $seedboxFiles/config/mylar/mylar/config.ini)"
 if [ "$url" != "http_root = /mylar" ]; then
   sed -i 's|'"$url"'|http_root = /mylar|g' $seedboxFiles/config/mylar/mylar/config.ini
  fi
fi
if [ "$radarr" = "true" ]; then
 url="$(grep UrlBase $seedboxFiles/config/radar/config.xml)"
 if [ "$url" != "  <UrlBase>/radarr</UrlBase>" ]; then
   sed -i 's|'"$url"'|  <UrlBase>/radarr</UrlBase>|g' $seedboxFiles/config/radar/config.xml
  fi
fi
if [ "$ubooquity" = "true" ]; then
 url="$(grep reverseProxyPrefix $seedboxFiles/config/ubooquity/preference.xml)"
 if [ "$url" != "    <reverseProxyPrefix>ubooquity</reverseProxyPrefix>" ]; then
   sed -i 's|'"$url"'|    <reverseProxyPrefix>ubooquity</reverseProxyPrefix>|g' $seedboxFiles/config/ubooquity/preference.xml
  fi
fi

restartSick="false"
if [ "$couchpotato" = "true" ]; then
 echo "downloading customn plugins for couchpotato"
 git clone --depth=1 https://github.com/djoole/couchpotato.provider.t411.git $tmpFolder/frenchproviders 
 git clone --depth=1 https://github.com/TimmyOtool/torrent9 $tmpFolder/torrent9 
 git clone --depth=1 https://github.com/TimmyOtool/namer_check $tmpFolder/namer_check 
fi
while IFS='' read -r line || [[ -n "$line" ]]; do
 #echo "Text read from file: $line"
 IFS=':' read -r userName string <<< "$line"
 if [ "$couchpotato" = "true" ]; then
  docker cp $tmpFolder/namer_check/namer_check.py seedboxdocker_couchpotato_$userName:/opt/couchpotato/couchpotato/core/helpers/namer_check.py
  addCustomProviders $userName
  url="$(grep url_base $seedboxFiles/config/couchpotato_$userName/settings.conf)"
  if [ "$url" != "url_base = /couchpotato" ]; then
   sed -i 's|'"$url"'|url_base = /couchpotato|g' $seedboxFiles/config/couchpotato_$userName/settings.conf
  fi
  echo "restarting $userName's couchpotato"
  docker restart seedboxdocker_couchpotato_$userName
 fi
 if [ "$sickrage" = "true" ]; then
   url="$(grep web_root $seedboxFiles/config/sickrage/sickrage/$userName/config.ini)"
   if [ "$url" != 'web_root = "/sickrage"' ]; then
    docker stop seedboxdocker_sickrage
    restartSick="true"
    sed -i 's|'"$url"'|web_root = "/sickrage"|g' $seedboxFiles/config/sickrage/sickrage/$userName/config.ini
  fi
 fi
done < "$users"
if [ "$couchpotato" = "true" ]; then
  rm -rf $tmpFolder/frenchproviders
  rm -rf $tmpFolder/torrent9
  rm -rf $tmpFolder/namer_check
fi
if [ "$restartSick" = "true" ]; then
 echo "restarting sickrage"
 docker start seedboxdocker_sickrage
fi
 