#!/usr/bin/env bash
# MAINTAINER https://github.com/cloneMe

# run "docker-machine ip default" or set your domain name
server_name=192.168.1.13
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
SUBDOMAINS="rtorrent,sickrage,couchpotato,plex,headphones,media,emby,muximux,glances,syncthing,plexpy,cloud,portainer"


############### SERVER
# All servers with the property at true will be deployed.
fail2ban=true

# https://hub.docker.com/r/timhaak/plex/
plex=true
plexUser=PlexUser
plexPass="PlexPass"

emby=f
# login with admin / admin 
limbomedia=f

sickrage=true
couchpotato=true
rtorrent=true
# https://mondedie.fr/viewtopic.php?id=7475
# not yet multi users
headphones=f

# https://hub.docker.com/r/kylemanna/openvpn/
# createVpnFor.sh will be generated automatically. 
# Run './createVpnFor.sh foo' to create foo.ovpn
openvpn=f
# https://hub.docker.com/r/devalx/docker-teamspeak3/
teamspeak=f
# https://hub.docker.com/r/stilliard/pure-ftpd/
pureftpd=true

#file explorer http://cloudcmd.io/
cloud=f

#another better file explorer https://github.com/Studio-42/elFinder
elfinder=true

# linuxserver/muximux
muximux=true

# docker.io/nicolargo/glances
glances=true

# linuxserver/syncthing
syncthing=true

#linuxserver/plexpy
plexpy=true

#docker web ui manager
portainer=true

#subliminal subtitle auto download
subliminal=true

#END SERVER

#set "#" if you have the following Error: 
#Unable to set up server: sqlite3_statement_backend::prepare: disk I/O error for SQL: PRAGMA cache_size=4000
plex_config=""
#set "#" if necessary
emby_config=""
#set "#" if you cannot connect to headphones
headphones_config=""

#where find nginx.conf, htpasswd.txt, ...
here=`pwd`
# where save following folders: config, downloads, log
#By default, get the parent directory of current directory
seedboxFiles="/home/seedbox/seedBoxFiles"


#launch scripts
INCLUDE="include"
. "$INCLUDE"/main.sh

