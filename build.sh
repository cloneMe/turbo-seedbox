#!/usr/bin/env bash
# MAINTAINER https://github.com/cloneMe

# run "docker-machine ip default" or set your domain name
server_name=192.168.99.100
# (Not yet implemented) letsEncrypt or self
# letsEncrypt: Let's Encrypt is a free, automated, and open certificate authority brought to you
# self: generate a self-signed certificate
useHttps=false
#for https
EMAIL="seedbox@yopmail.com"
#see http://php.net/manual/en/timezones.php
TZ="Europe/Paris"
SUBDOMAINS="files,rtorrent,sickrage,couchpotato,plex,explorer"

#SERVER
# All servers with the property at true will be deployed.
fail2ban=true
plex=true
sickrage=true
couchPotato=true
rtorrent=true
openvpn=f
teamspeak=f
pureftpd=true
filemanager=true
# enter : admin/admin then configure and update the home to /torrents
explorer=f

#END SERVER

#use "#" if you have the following Error: 
#Unable to set up server: sqlite3_statement_backend::prepare: disk I/O error for SQL: PRAGMA cache_size=4000
plex_config=""

#where find nginx.conf, htpasswd.txt, ...
here=`pwd`
# where save following folders: config, downloads, log
#By default, get the parent directory of current directory
seedboxFiles="$(dirname "$here")"

#docker option, see https://docs.docker.com/engine/reference/commandline/build/, for example: q 
mode=""

#launch scripts
INCLUDE="include"
. "$INCLUDE"/main.sh

