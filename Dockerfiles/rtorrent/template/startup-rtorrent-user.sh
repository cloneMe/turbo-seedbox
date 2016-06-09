#!/bin/bash

set -x

# set rtorrent user and group id

useradd -d /home/#user# -m -s /bin/bash #user#
usermod -aG share #user#
# arrange dirs and configs
mkdir -p /config/rtorrent/#user#/session 
mkdir -p /downloads/rtorrent/#user#/watch
mkdir -p /downloads/rtorrent/#user#/serie
mkdir -p /downloads/rtorrent/#user#/film

rm -f /downloads/rtorrent/#user#/.rtorrent.rc
ln -s /home/#user#/.rtorrent.rc /downloads/rtorrent/#user#/
chown -R #user#:share /downloads/rtorrent/#user#
chown -R #user#:share /config/rtorrent/#user#
chown -R #user#:share /home/#user#

rm -f /config/rtorrent/#user#/session/rtorrent.lock

# run
su --login --command="TERM=xterm rtorrent" #user#