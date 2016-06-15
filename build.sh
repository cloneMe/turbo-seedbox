#!/usr/bin/env bash
# MAINTAINER https://github.com/cloneMe

# run "docker-machine ip default" or set your domain name
server_name=192.168.99.100
# (Not yet implemented) letsEncrypt or self or provided
# letsEncrypt: Let's Encrypt is a free, automated, and open certificate authority brought to you
# self: generate a self-signed certificate
# provided: you have to provide following certificates: nginx.crt, nginx.key OR privkey.pem, fullchain.pem, dhparams.pem in the ssl generated folder.
useHttps=false
#for https
EMAIL="seedbox@yopmail.com"
#see http://php.net/manual/en/timezones.php
TZ="Europe/Paris"
SUBDOMAINS="files,rtorrent,sickrage,couchpotato,plex,explorer"

############### SERVER
# All servers with the property at true will be deployed.
fail2ban=true
# https://hub.docker.com/r/timhaak/plex/
plex=true
sickrage=true
couchPotato=true
rtorrent=true
# https://hub.docker.com/r/kylemanna/openvpn/
# createVpnFor.sh will be generated automatically. 
# Run './createVpnFor.sh foo' to create foo.ovpn
openvpn=f
# https://hub.docker.com/r/devalx/docker-teamspeak3/
teamspeak=f
# https://hub.docker.com/r/stilliard/pure-ftpd/
pureftpd=true
# https://github.com/simogeo/Filemanager
filemanager=true
# see https://github.com/soyuka/explorer
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

