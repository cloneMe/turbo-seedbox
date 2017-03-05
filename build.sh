#!/usr/bin/env bash
# MAINTAINER https://github.com/cloneMe

# run "docker-machine ip default" or set your domain name
server_name=127.0.0.1
# (Not yet implemented) letsEncrypt or self or provided
# letsEncrypt: Let's Encrypt is a free, automated, and open certificate authority brought to you
# self: generate a self-signed certificate
# provided: you have to provide following certificates: nginx.crt, nginx.key OR privkey.pem, fullchain.pem, dhparams.pem in the ssl generated folder.
useHttps=false
#for https
EMAIL="seedbox@yopmail.com"
#see http://php.net/manual/en/timezones.php
TZ="Europe/Paris"
#using letsEncrypt, delete subdomains not defined on DNS side
SUBDOMAINS="files,rtorrent,sickrage,couchpotato,plex,explorer,headphones,media,emby,muximux,glances,syncthing,plexpy,cloud"



############### SERVER
# All servers with the property at true will be deployed.
fail2ban=true

# https://hub.docker.com/r/timhaak/plex/
plex=true
plexUser=PlexUser
plexPass="PlexPass"
# Plex Usage tracker https://github.com/linuxserver/docker-plexpy
plexpy=f
# another home media server https://github.com/MediaBrowser/Emby 
emby=f
# another home media server, http://limbomedia.net/ login: admin / admin
limbomedia=f

sickrage=true
couchpotato=true
rtorrent=true
# https://mondedie.fr/viewtopic.php?id=7475
# not yet multi users
headphones=f

# Lightweight portal to your webapps https://github.com/mescon/Muximux
muximux=true

# monitoring tool https://nicolargo.github.io/glances/
glances=f

# https://hub.docker.com/r/kylemanna/openvpn/
# createVpnFor.sh will be generated automatically.
# Run './createVpnFor.sh foo' to create foo.ovpn
openvpn=f
# https://hub.docker.com/r/devalx/docker-teamspeak3/
teamspeak=f


# FTP (not secured?) https://hub.docker.com/r/stilliard/pure-ftpd/
pureftpd=f

#Best file explorer https://github.com/Studio-42/elFinder
elfinder=f
#### others file explorer
# https://github.com/simogeo/Filemanager
filemanager=f
# see https://github.com/soyuka/explorer
# enter : admin/admin then configure and update the home to /torrents
explorer=f
#file explorer http://cloudcmd.io/
cloud=f
####


# https://docs.syncthing.net/ https://hub.docker.com/r/linuxserver/syncthing/
syncthing=f

#docker web ui manager
portainer=f

#subliminal subtitle auto download
subliminal=f

#a web terminal
butterfly=f

#END SERVER

#set "#" if you have the following Error:
#Unable to set up server: sqlite3_statement_backend::prepare: disk I/O error for SQL: PRAGMA cache_size=4000
plex_config=""
#set "#" if necessary
emby_config=""
#set "#" if you cannot connect to headphones
headphones_config=""
mux_config=""

#where find nginx.conf, htpasswd.txt, ...
here=`pwd`
# where save following folders: config, downloads, log
#By default, get the parent directory of current directory
# another path: "/home/seedbox/seedBoxFiles"
seedboxFiles="$(dirname "$here")"


#launch scripts
INCLUDE="include"
. "$INCLUDE"/main.sh

read -p "To launch servers, enter y: " response
if [[ "$response" = "y" || "$response" = "Y" ]]; then
 docker-compose up -d
 read -p "To update couchPotato, sickrage,... enter y: " response
 if [[ "$response" = "y" || "$response" = "Y" ]]; then
  . "$INCLUDE"/update.sh
 fi
fi

# docker-compose up -d  --remove-orphans
# docker restart seedboxdocker_front_1
# stop & remove containers
# docker-compose down --remove-orphans
