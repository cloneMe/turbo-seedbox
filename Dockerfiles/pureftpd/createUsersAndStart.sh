#!/bin/bash


# clear existing file
echo "" > /etc/pure-ftpd/pureftpd.passwd

#for each user

while IFS='' read -r line || [[ -n "$line" ]]; do

	echo "$line:1000:1000::/downloads/rtorrent/./::::::::::::" >> /etc/pure-ftpd/pureftpd.passwd
    
done < "$1"

pure-pw mkdb
echo "done"
/usr/sbin/pure-ftpd -c 50 -C 10 -l puredb:/etc/pure-ftpd/pureftpd.pdb -E -j -R -P "$PUBLICHOST" -p 30000:30009

